// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/arch/device.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/dif/dif_base.h"
#include "sw/device/lib/dif/dif_i2c.h"
#include "sw/device/lib/dif/dif_pinmux.h"
#include "sw/device/lib/dif/dif_rv_plic.h"
#include "sw/device/lib/runtime/hart.h"
#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/runtime/irq.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/i2c_testutils.h"
#include "sw/device/lib/testing/rand_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"
#include "sw/device/lib/testing/test_framework/status.h"

#include "hw/top_chip/sw/autogen/top_chip.h"
#include "sw/device/lib/testing/autogen/isr_testutils.h"

// TODO #14111, remove it once pinout configuration is provided
#include "i2c_regs.h"

static dif_i2c_t i2c;
static dif_pinmux_t pinmux;
static dif_rv_plic_t plic;

OTTF_DEFINE_TEST_CONFIG();

/**
 * This symbol is meant to be backdoor loaded by the testbench.
 * The testbench will inform the test the rough speed of the clock
 * used by the I2C modules.
 *
 * The I2C Device state machine does depend on the I2C timing configuration
 */
static volatile const uint8_t kClockPeriodNanos = 0;
static volatile const uint8_t kI2cRiseFallNanos = 0;
static volatile const uint32_t kI2cClockPeriodNanos = 0;

/**
 * This symbol is meant to be backdoor loaded by the testbench.
 * to indicate which I2c is actually under test.
 */
static volatile const uint8_t kI2cIdx = 0;

/**
 * This set of symbols is meant to be backdoor loaded by the testbench.
 * to indicate the address that will be listened to by the device.
 */
static volatile const uint8_t kI2cDeviceAddress0 = 0x55;
static volatile const uint8_t kI2cDeviceMask0 = 0x7f;
static volatile const uint8_t kI2cDeviceAddress1 = 0x7f;  // disable match on
                                                          // second address
static volatile const uint8_t kI2cDeviceMask1 = 0x7f;

/**
 * This symbol is meant to be backdoor loaded by the testbench.
 * to indicate the number of bytes that should be sent.
 *
 * Because the test doesn't manage the FIFO during transaction, there's a limit
 * to the number of bytes we can loopback in the test. I2C_PARAM_FIFO_DEPTH - 4
 */
static volatile const uint8_t kI2cByteCount = 0;

static volatile bool tx_empty_irq_seen = false;
static volatile bool cmd_complete_irq_seen = false;
static volatile bool acq_fifo_threshold_irq_seen = false;

/**
 * This constant indicates the number of interrupt requests.
 */
enum {
  kNumI2cIrqs = 5,
};

typedef struct i2c_conf {
  const int unsigned base_addr;
  const top_chip_plic_irq_id_t plic_irq;
  const top_chip_plic_peripheral_t peripheral_id;
} i2c_conf_t;

const i2c_conf_t i2c_configuration[] = {
    {.base_addr = TOP_CHIP_I2C0_BASE_ADDR,
     .plic_irq = kTopChipPlicIrqIdI2c0,
     .peripheral_id = kTopChipPlicPeripheralI2c0},
    {.base_addr = TOP_CHIP_I2C1_BASE_ADDR,
     .plic_irq = kTopChipPlicIrqIdI2c1,
     .peripheral_id = kTopChipPlicPeripheralI2c1}};

/**
 * Provides external irq handling for this test.
 *
 * This function overrides the default OTTF external ISR.
 */
void ottf_external_isr(uint32_t *exc_info) {
  // Find which interrupt fired at PLIC by claiming it.
  dif_rv_plic_irq_id_t plic_irq_id;
  CHECK_DIF_OK(
      dif_rv_plic_irq_claim(&plic, kTopChipPlicTargetIbex0, &plic_irq_id));

  // Check if it is the right peripheral.
  top_chip_plic_peripheral_t peripheral = (top_chip_plic_peripheral_t)
      top_chip_plic_interrupt_for_peripheral[plic_irq_id];
  CHECK(peripheral == i2c_configuration[kI2cIdx].peripheral_id,
        "Interrupt from unexpected peripheral: %d", peripheral);

  // Sunburst - Determine interrupt cause by reading the interrupt registers of
  //            the peripheral itself rather than the reduced-precision PLIC.
  dif_i2c_irq_state_snapshot_t state_snapshot;
  dif_i2c_irq_enable_snapshot_t enable_snapshot;
  dif_i2c_irq_state_snapshot_t pending_enabled;
  // Note - peripheral interrupt state (INTR_STATE) is not enable-masked.
  CHECK_DIF_OK(dif_i2c_irq_get_state(&i2c, &state_snapshot));
  // Note - at present the only way to get all interrupt enables (INTR_ENABLE)
  //        from a peripheral is to use the ...irq_disable_all function.
  CHECK_DIF_OK(dif_i2c_irq_disable_all(&i2c, &enable_snapshot));
  CHECK_DIF_OK(dif_i2c_irq_restore_all(&i2c, &enable_snapshot));
  // Combine peripheral interrupt state bits with interrupt enable mask
  // for an approximation of interrupts fired.
  pending_enabled = state_snapshot & enable_snapshot;

  dif_i2c_irq_t i2c_irq = 0;
  bool disable = false;
  if (bitfield_bit32_read(pending_enabled, kDifI2cIrqTxStretch)) {
    tx_empty_irq_seen = true;
    i2c_irq = kDifI2cIrqTxStretch;
  } else if (bitfield_bit32_read(pending_enabled, kDifI2cIrqCmdComplete)) {
    cmd_complete_irq_seen = true;
    i2c_irq = kDifI2cIrqCmdComplete;
  } else if (bitfield_bit32_read(pending_enabled, kDifI2cIrqAcqThreshold)) {
    acq_fifo_threshold_irq_seen = true;
    i2c_irq = kDifI2cIrqAcqThreshold;
    disable = true;
  } else {
    LOG_ERROR("Unexpected interrupts (at I2C): %x (%x & %x)",
              pending_enabled, state_snapshot, enable_snapshot);
    test_status_set(kTestStatusFailed);
  }

  if (disable) {
    // Status type interrupt must be disabled since it cannot be cleared
    CHECK_DIF_OK(dif_i2c_irq_set_enabled(&i2c, i2c_irq, kDifToggleDisabled));
  }

  // Clear the interrupt at I^2C block.
  CHECK_DIF_OK(dif_i2c_irq_acknowledge(&i2c, i2c_irq));

  // Complete the IRQ at PLIC.
  CHECK_DIF_OK(dif_rv_plic_irq_complete(&plic, kTopChipPlicTargetIbex0,
                                        plic_irq_id));
}

void check_addr(uint8_t addr, dif_i2c_id_t id0, dif_i2c_id_t id1) {
  CHECK(((addr & id0.mask) == id0.address) ||
        ((addr & id1.mask) == id1.address));
}

bool test_main(void) {
  LOG_INFO("Testing I2C index %d", kI2cIdx);

  if (kI2cByteCount > I2C_PARAM_FIFO_DEPTH - 4) {
    LOG_ERROR(
        "Test cannot fit %d bytes, 2 START records, and 2 STOP records in "
        "buffers of depth %d",
        kI2cByteCount, I2C_PARAM_FIFO_DEPTH);
  }

  CHECK_DIF_OK(dif_i2c_init(
      mmio_region_from_addr(i2c_configuration[kI2cIdx].base_addr), &i2c));

  CHECK_DIF_OK(dif_pinmux_init(
      mmio_region_from_addr(TOP_CHIP_PINMUX_AON_BASE_ADDR), &pinmux));

  CHECK_DIF_OK(dif_rv_plic_init(
      mmio_region_from_addr(TOP_CHIP_RV_PLIC_BASE_ADDR), &plic));

  CHECK_STATUS_OK(
      i2c_testutils_select_pinmux(&pinmux, kI2cIdx, I2cPinmuxPlatformIdDvsim));

  // Enable functional interrupts as well as error interrupts to make sure
  // everything is behaving as expected.
  CHECK_DIF_OK(dif_rv_plic_irq_set_enabled(
      &plic, i2c_configuration[kI2cIdx].plic_irq,
      kTopChipPlicTargetIbex0, kDifToggleEnabled));

  // Assign a default priority
  CHECK_DIF_OK(dif_rv_plic_irq_set_priority(
      &plic, i2c_configuration[kI2cIdx].plic_irq, kDifRvPlicMaxPriority));

  // Enable the external IRQ at Ibex.
  irq_global_ctrl(true);
  irq_external_ctrl(true);

  // I2C speed parameters.
  dif_i2c_timing_config_t timing_config = {
      .lowest_target_device_speed = kDifI2cSpeedFastPlus,
      .clock_period_nanos = kClockPeriodNanos,
      .sda_rise_nanos = kI2cRiseFallNanos,
      .sda_fall_nanos = kI2cRiseFallNanos,
      .scl_period_nanos = kI2cClockPeriodNanos};

  dif_i2c_config_t config;
  CHECK_DIF_OK(dif_i2c_compute_timing(timing_config, &config));
  CHECK_DIF_OK(dif_i2c_configure(&i2c, config));
  dif_i2c_id_t id0 = {.mask = kI2cDeviceMask0, .address = kI2cDeviceAddress0},
               id1 = {.mask = kI2cDeviceMask1, .address = kI2cDeviceAddress1};
  CHECK_DIF_OK(dif_i2c_set_device_id(&i2c, &id0, &id1));
  CHECK_DIF_OK(dif_i2c_device_set_enabled(&i2c, kDifToggleEnabled));

  // Use interrupts to wait for first command
  CHECK_DIF_OK(dif_i2c_set_target_watermarks(&i2c, 0, 1));

  // TODO OpenTitan#15081, transaction complete may not be set by i2c device.
  CHECK(!cmd_complete_irq_seen);

  CHECK_DIF_OK(
      dif_i2c_irq_set_enabled(&i2c, kDifI2cIrqTxStretch, kDifToggleEnabled));
  CHECK_DIF_OK(
      dif_i2c_irq_set_enabled(&i2c, kDifI2cIrqCmdComplete, kDifToggleEnabled));
  CHECK_DIF_OK(
      dif_i2c_irq_set_enabled(&i2c, kDifI2cIrqAcqThreshold, kDifToggleEnabled));

  // Randomize variables.
  uint8_t expected_data[kI2cByteCount];
  LOG_INFO("Loopback %d bytes with addresses %h, %h", kI2cByteCount,
           kI2cDeviceAddress0, kI2cDeviceAddress1);

  // Controlling the randomization from C side is a bit slow, but might be
  // easier for portability to a different setup later.
  for (uint32_t i = 0; i < kI2cByteCount; ++i) {
    expected_data[i] = (uint8_t)rand_testutils_gen32_range(0, 0xff);
  };

  dif_i2c_level_t tx_fifo_lvl;
  CHECK_DIF_OK(dif_i2c_get_fifo_levels(&i2c, NULL, NULL, &tx_fifo_lvl, NULL));
  IBEX_SPIN_FOR(!(tx_fifo_lvl > 0 && tx_empty_irq_seen == false), 100);
  CHECK_STATUS_OK(
      i2c_testutils_target_read(&i2c, kI2cByteCount, expected_data));
  tx_empty_irq_seen = false;

  LOG_INFO("Data written to fifo");

  // Signal to DV environment that we are ready
  test_status_set(kTestStatusInWfi);
  // Wait for command
  CHECK(!acq_fifo_threshold_irq_seen);
  wait_for_interrupt();
  CHECK(acq_fifo_threshold_irq_seen);

  dif_i2c_level_t acq_fifo_lvl;
  CHECK_DIF_OK(
      dif_i2c_get_fifo_levels(&i2c, NULL, NULL, &tx_fifo_lvl, &acq_fifo_lvl));

  CHECK(acq_fifo_lvl >= 2);
  CHECK(tx_fifo_lvl == 0);

  uint8_t addr;
  CHECK_STATUS_OK(i2c_testutils_target_check_read(&i2c, &addr, NULL));
  check_addr(addr, id0, id1);

  // Read data from i2c device.
  CHECK_STATUS_OK(i2c_testutils_target_write(&i2c, kI2cByteCount));
  do {
    CHECK_DIF_OK(
        dif_i2c_get_fifo_levels(&i2c, NULL, NULL, &tx_fifo_lvl, &acq_fifo_lvl));
  } while (acq_fifo_lvl < kI2cByteCount + 2);  // acquired message, address and
                                               // junk

  uint8_t received_data[kI2cByteCount];
  CHECK_STATUS_OK(i2c_testutils_target_check_write(&i2c, kI2cByteCount, &addr,
                                                   received_data, NULL));
  check_addr(addr, id0, id1);

  // Note: moving this status update earlier may affect the test
  // when logging (slowly) over UART.
  test_status_set(kTestStatusInTest);

  for (uint8_t i = 0; i < kI2cByteCount; ++i) {
    CHECK(expected_data[i] == received_data[i]);
  }

  CHECK(cmd_complete_irq_seen);

  return true;
}
