// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// TODO: Edited manually until there is a top-level hjson file.
//
// THIS FILE HAS BEEN GENERATED, DO NOT EDIT MANUALLY. COMMAND:
// util/autogen_testutils.py

#include "sw/device/lib/testing/autogen/isr_testutils.h"

#include "sw/device/lib/dif/dif_aon_timer.h"
#include "sw/device/lib/dif/dif_base.h"
#include "sw/device/lib/dif/dif_gpio.h"
#include "sw/device/lib/dif/dif_i2c.h"
#include "sw/device/lib/dif/dif_pattgen.h"
#include "sw/device/lib/dif/dif_rv_plic.h"
#include "sw/device/lib/dif/dif_rv_timer.h"
#include "sw/device/lib/dif/dif_spi_host.h"
#include "sw/device/lib/dif/dif_uart.h"
#include "sw/device/lib/dif/dif_usbdev.h"
#include "sw/device/lib/testing/test_framework/check.h"

#include "hw/top_chip/sw/autogen/top_chip.h"  // Generated.

void isr_testutils_aon_timer_isr(
    plic_isr_ctx_t plic_ctx, aon_timer_isr_ctx_t aon_timer_ctx,
    top_chip_plic_peripheral_t *peripheral_serviced,
    dif_aon_timer_irq_t *irq_serviced) {
  // Claim the IRQ at the PLIC.
  dif_rv_plic_irq_id_t plic_irq_id;
  CHECK_DIF_OK(
      dif_rv_plic_irq_claim(plic_ctx.rv_plic, plic_ctx.hart_id, &plic_irq_id));

  // Get the peripheral the IRQ belongs to.
  *peripheral_serviced = (top_chip_plic_peripheral_t)
      top_chip_plic_interrupt_for_peripheral[plic_irq_id];

  // Get the IRQ that was fired from the PLIC IRQ ID.
  dif_aon_timer_irq_t irq =
      (dif_aon_timer_irq_t)(plic_irq_id -
                            aon_timer_ctx.plic_aon_timer_start_irq_id);
  *irq_serviced = irq;

  // Check if it is supposed to be the only IRQ fired.
  if (aon_timer_ctx.is_only_irq) {
    dif_aon_timer_irq_state_snapshot_t snapshot;
    CHECK_DIF_OK(
        dif_aon_timer_irq_get_state(aon_timer_ctx.aon_timer, &snapshot));
    CHECK(snapshot == (dif_aon_timer_irq_state_snapshot_t)(1 << irq),
          "Only aon_timer IRQ %d expected to fire. Actual IRQ state = %x", irq,
          snapshot);
  }

  // Acknowledge the IRQ at the peripheral if IRQ is of the event type.
  dif_irq_type_t type;
  CHECK_DIF_OK(dif_aon_timer_irq_get_type(aon_timer_ctx.aon_timer, irq, &type));
  if (type == kDifIrqTypeEvent) {
    CHECK_DIF_OK(dif_aon_timer_irq_acknowledge(aon_timer_ctx.aon_timer, irq));
  }

  // Complete the IRQ at the PLIC.
  CHECK_DIF_OK(dif_rv_plic_irq_complete(plic_ctx.rv_plic, plic_ctx.hart_id,
                                        plic_irq_id));
}

void isr_testutils_gpio_isr(plic_isr_ctx_t plic_ctx, gpio_isr_ctx_t gpio_ctx,
                            top_chip_plic_peripheral_t *peripheral_serviced,
                            dif_gpio_irq_t *irq_serviced) {
  // Claim the IRQ at the PLIC.
  dif_rv_plic_irq_id_t plic_irq_id;
  CHECK_DIF_OK(
      dif_rv_plic_irq_claim(plic_ctx.rv_plic, plic_ctx.hart_id, &plic_irq_id));

  // Get the peripheral the IRQ belongs to.
  *peripheral_serviced = (top_chip_plic_peripheral_t)
      top_chip_plic_interrupt_for_peripheral[plic_irq_id];

  // Get the IRQ that was fired from the PLIC IRQ ID.
  dif_gpio_irq_t irq =
      (dif_gpio_irq_t)(plic_irq_id - gpio_ctx.plic_gpio_start_irq_id);
  *irq_serviced = irq;

  // Check if it is supposed to be the only IRQ fired.
  if (gpio_ctx.is_only_irq) {
    dif_gpio_irq_state_snapshot_t snapshot;
    CHECK_DIF_OK(dif_gpio_irq_get_state(gpio_ctx.gpio, &snapshot));
    CHECK(snapshot == (dif_gpio_irq_state_snapshot_t)(1 << irq),
          "Only gpio IRQ %d expected to fire. Actual IRQ state = %x", irq,
          snapshot);
  }

  // Acknowledge the IRQ at the peripheral if IRQ is of the event type.
  dif_irq_type_t type;
  CHECK_DIF_OK(dif_gpio_irq_get_type(gpio_ctx.gpio, irq, &type));
  if (type == kDifIrqTypeEvent) {
    CHECK_DIF_OK(dif_gpio_irq_acknowledge(gpio_ctx.gpio, irq));
  }

  // Complete the IRQ at the PLIC.
  CHECK_DIF_OK(dif_rv_plic_irq_complete(plic_ctx.rv_plic, plic_ctx.hart_id,
                                        plic_irq_id));
}

void isr_testutils_i2c_isr(plic_isr_ctx_t plic_ctx, i2c_isr_ctx_t i2c_ctx,
                           bool mute_status_irq,
                           top_chip_plic_peripheral_t *peripheral_serviced,
                           dif_i2c_irq_t *irq_serviced) {
  // Claim the IRQ at the PLIC.
  dif_rv_plic_irq_id_t plic_irq_id;
  CHECK_DIF_OK(
      dif_rv_plic_irq_claim(plic_ctx.rv_plic, plic_ctx.hart_id, &plic_irq_id));

  // Get the peripheral the IRQ belongs to.
  *peripheral_serviced = (top_chip_plic_peripheral_t)
      top_chip_plic_interrupt_for_peripheral[plic_irq_id];

  // Get the IRQ that was fired from the PLIC IRQ ID.
  dif_i2c_irq_t irq =
      (dif_i2c_irq_t)(plic_irq_id - i2c_ctx.plic_i2c_start_irq_id);
  *irq_serviced = irq;

  // Check if it is supposed to be the only IRQ fired.
  if (i2c_ctx.is_only_irq) {
    dif_i2c_irq_state_snapshot_t snapshot;
    CHECK_DIF_OK(dif_i2c_irq_get_state(i2c_ctx.i2c, &snapshot));
    CHECK(snapshot == (dif_i2c_irq_state_snapshot_t)(1 << irq),
          "Only i2c IRQ %d expected to fire. Actual IRQ state = %x", irq,
          snapshot);
  }

  // Acknowledge the IRQ at the peripheral if IRQ is of the event type.
  dif_irq_type_t type;
  CHECK_DIF_OK(dif_i2c_irq_get_type(i2c_ctx.i2c, irq, &type));
  if (type == kDifIrqTypeEvent) {
    CHECK_DIF_OK(dif_i2c_irq_acknowledge(i2c_ctx.i2c, irq));
  } else if (mute_status_irq) {
    CHECK_DIF_OK(dif_i2c_irq_set_enabled(i2c_ctx.i2c, irq, kDifToggleDisabled));
  }

  // Complete the IRQ at the PLIC.
  CHECK_DIF_OK(dif_rv_plic_irq_complete(plic_ctx.rv_plic, plic_ctx.hart_id,
                                        plic_irq_id));
}

void isr_testutils_pattgen_isr(
    plic_isr_ctx_t plic_ctx, pattgen_isr_ctx_t pattgen_ctx,
    top_chip_plic_peripheral_t *peripheral_serviced,
    dif_pattgen_irq_t *irq_serviced) {
  // Claim the IRQ at the PLIC.
  dif_rv_plic_irq_id_t plic_irq_id;
  CHECK_DIF_OK(
      dif_rv_plic_irq_claim(plic_ctx.rv_plic, plic_ctx.hart_id, &plic_irq_id));

  // Get the peripheral the IRQ belongs to.
  *peripheral_serviced = (top_chip_plic_peripheral_t)
      top_chip_plic_interrupt_for_peripheral[plic_irq_id];

  // Get the IRQ that was fired from the PLIC IRQ ID.
  dif_pattgen_irq_t irq =
      (dif_pattgen_irq_t)(plic_irq_id - pattgen_ctx.plic_pattgen_start_irq_id);
  *irq_serviced = irq;

  // Check if it is supposed to be the only IRQ fired.
  if (pattgen_ctx.is_only_irq) {
    dif_pattgen_irq_state_snapshot_t snapshot;
    CHECK_DIF_OK(dif_pattgen_irq_get_state(pattgen_ctx.pattgen, &snapshot));
    CHECK(snapshot == (dif_pattgen_irq_state_snapshot_t)(1 << irq),
          "Only pattgen IRQ %d expected to fire. Actual IRQ state = %x", irq,
          snapshot);
  }

  // Acknowledge the IRQ at the peripheral if IRQ is of the event type.
  dif_irq_type_t type;
  CHECK_DIF_OK(dif_pattgen_irq_get_type(pattgen_ctx.pattgen, irq, &type));
  if (type == kDifIrqTypeEvent) {
    CHECK_DIF_OK(dif_pattgen_irq_acknowledge(pattgen_ctx.pattgen, irq));
  }

  // Complete the IRQ at the PLIC.
  CHECK_DIF_OK(dif_rv_plic_irq_complete(plic_ctx.rv_plic, plic_ctx.hart_id,
                                        plic_irq_id));
}

void isr_testutils_rv_timer_isr(
    plic_isr_ctx_t plic_ctx, rv_timer_isr_ctx_t rv_timer_ctx,
    top_chip_plic_peripheral_t *peripheral_serviced,
    dif_rv_timer_irq_t *irq_serviced) {
  // Claim the IRQ at the PLIC.
  dif_rv_plic_irq_id_t plic_irq_id;
  CHECK_DIF_OK(
      dif_rv_plic_irq_claim(plic_ctx.rv_plic, plic_ctx.hart_id, &plic_irq_id));

  // Get the peripheral the IRQ belongs to.
  *peripheral_serviced = (top_chip_plic_peripheral_t)
      top_chip_plic_interrupt_for_peripheral[plic_irq_id];

  // Get the IRQ that was fired from the PLIC IRQ ID.
  dif_rv_timer_irq_t irq =
      (dif_rv_timer_irq_t)(plic_irq_id -
                           rv_timer_ctx.plic_rv_timer_start_irq_id);
  *irq_serviced = irq;

  // Check if it is supposed to be the only IRQ fired.
  if (rv_timer_ctx.is_only_irq) {
    dif_rv_timer_irq_state_snapshot_t snapshot;
    CHECK_DIF_OK(dif_rv_timer_irq_get_state(rv_timer_ctx.rv_timer,
                                            plic_ctx.hart_id, &snapshot));
    CHECK(snapshot == (dif_rv_timer_irq_state_snapshot_t)(1 << irq),
          "Only rv_timer IRQ %d expected to fire. Actual IRQ state = %x", irq,
          snapshot);
  }

  // Acknowledge the IRQ at the peripheral if IRQ is of the event type.
  dif_irq_type_t type;
  CHECK_DIF_OK(dif_rv_timer_irq_get_type(rv_timer_ctx.rv_timer, irq, &type));
  if (type == kDifIrqTypeEvent) {
    CHECK_DIF_OK(dif_rv_timer_irq_acknowledge(rv_timer_ctx.rv_timer, irq));
  }

  // Complete the IRQ at the PLIC.
  CHECK_DIF_OK(dif_rv_plic_irq_complete(plic_ctx.rv_plic, plic_ctx.hart_id,
                                        plic_irq_id));
}

void isr_testutils_spi_host_isr(
    plic_isr_ctx_t plic_ctx, spi_host_isr_ctx_t spi_host_ctx,
    bool mute_status_irq, top_chip_plic_peripheral_t *peripheral_serviced,
    dif_spi_host_irq_t *irq_serviced) {
  // Claim the IRQ at the PLIC.
  dif_rv_plic_irq_id_t plic_irq_id;
  CHECK_DIF_OK(
      dif_rv_plic_irq_claim(plic_ctx.rv_plic, plic_ctx.hart_id, &plic_irq_id));

  // Get the peripheral the IRQ belongs to.
  *peripheral_serviced = (top_chip_plic_peripheral_t)
      top_chip_plic_interrupt_for_peripheral[plic_irq_id];

  // Get the IRQ that was fired from the PLIC IRQ ID.
  dif_spi_host_irq_t irq =
      (dif_spi_host_irq_t)(plic_irq_id -
                           spi_host_ctx.plic_spi_host_start_irq_id);
  *irq_serviced = irq;

  // Check if it is supposed to be the only IRQ fired.
  if (spi_host_ctx.is_only_irq) {
    dif_spi_host_irq_state_snapshot_t snapshot;
    CHECK_DIF_OK(dif_spi_host_irq_get_state(spi_host_ctx.spi_host, &snapshot));
    CHECK(snapshot == (dif_spi_host_irq_state_snapshot_t)(1 << irq),
          "Only spi_host IRQ %d expected to fire. Actual IRQ state = %x", irq,
          snapshot);
  }

  // Acknowledge the IRQ at the peripheral if IRQ is of the event type.
  dif_irq_type_t type;
  CHECK_DIF_OK(dif_spi_host_irq_get_type(spi_host_ctx.spi_host, irq, &type));
  if (type == kDifIrqTypeEvent) {
    CHECK_DIF_OK(dif_spi_host_irq_acknowledge(spi_host_ctx.spi_host, irq));
  } else if (mute_status_irq) {
    CHECK_DIF_OK(dif_spi_host_irq_set_enabled(spi_host_ctx.spi_host, irq,
                                              kDifToggleDisabled));
  }

  // Complete the IRQ at the PLIC.
  CHECK_DIF_OK(dif_rv_plic_irq_complete(plic_ctx.rv_plic, plic_ctx.hart_id,
                                        plic_irq_id));
}

void isr_testutils_uart_isr(plic_isr_ctx_t plic_ctx, uart_isr_ctx_t uart_ctx,
                            bool mute_status_irq,
                            top_chip_plic_peripheral_t *peripheral_serviced,
                            dif_uart_irq_t *irq_serviced) {
  // Claim the IRQ at the PLIC.
  dif_rv_plic_irq_id_t plic_irq_id;
  CHECK_DIF_OK(
      dif_rv_plic_irq_claim(plic_ctx.rv_plic, plic_ctx.hart_id, &plic_irq_id));

  // Get the peripheral the IRQ belongs to.
  *peripheral_serviced = (top_chip_plic_peripheral_t)
      top_chip_plic_interrupt_for_peripheral[plic_irq_id];

  // Get the IRQ that was fired from the PLIC IRQ ID.
  dif_uart_irq_t irq =
      (dif_uart_irq_t)(plic_irq_id - uart_ctx.plic_uart_start_irq_id);
  *irq_serviced = irq;

  // Check if it is supposed to be the only IRQ fired.
  if (uart_ctx.is_only_irq) {
    dif_uart_irq_state_snapshot_t snapshot;
    CHECK_DIF_OK(dif_uart_irq_get_state(uart_ctx.uart, &snapshot));
    CHECK(snapshot == (dif_uart_irq_state_snapshot_t)(1 << irq),
          "Only uart IRQ %d expected to fire. Actual IRQ state = %x", irq,
          snapshot);
  }

  // Acknowledge the IRQ at the peripheral if IRQ is of the event type.
  dif_irq_type_t type;
  CHECK_DIF_OK(dif_uart_irq_get_type(uart_ctx.uart, irq, &type));
  if (type == kDifIrqTypeEvent) {
    CHECK_DIF_OK(dif_uart_irq_acknowledge(uart_ctx.uart, irq));
  } else if (mute_status_irq) {
    CHECK_DIF_OK(
        dif_uart_irq_set_enabled(uart_ctx.uart, irq, kDifToggleDisabled));
  }

  // Complete the IRQ at the PLIC.
  CHECK_DIF_OK(dif_rv_plic_irq_complete(plic_ctx.rv_plic, plic_ctx.hart_id,
                                        plic_irq_id));
}

void isr_testutils_usbdev_isr(
    plic_isr_ctx_t plic_ctx, usbdev_isr_ctx_t usbdev_ctx, bool mute_status_irq,
    top_chip_plic_peripheral_t *peripheral_serviced,
    dif_usbdev_irq_t *irq_serviced) {
  // Claim the IRQ at the PLIC.
  dif_rv_plic_irq_id_t plic_irq_id;
  CHECK_DIF_OK(
      dif_rv_plic_irq_claim(plic_ctx.rv_plic, plic_ctx.hart_id, &plic_irq_id));

  // Get the peripheral the IRQ belongs to.
  *peripheral_serviced = (top_chip_plic_peripheral_t)
      top_chip_plic_interrupt_for_peripheral[plic_irq_id];

  // Get the IRQ that was fired from the PLIC IRQ ID.
  dif_usbdev_irq_t irq =
      (dif_usbdev_irq_t)(plic_irq_id - usbdev_ctx.plic_usbdev_start_irq_id);
  *irq_serviced = irq;

  // Check if it is supposed to be the only IRQ fired.
  if (usbdev_ctx.is_only_irq) {
    dif_usbdev_irq_state_snapshot_t snapshot;
    CHECK_DIF_OK(dif_usbdev_irq_get_state(usbdev_ctx.usbdev, &snapshot));
    CHECK(snapshot == (dif_usbdev_irq_state_snapshot_t)(1 << irq),
          "Only usbdev IRQ %d expected to fire. Actual IRQ state = %x", irq,
          snapshot);
  }

  // Acknowledge the IRQ at the peripheral if IRQ is of the event type.
  dif_irq_type_t type;
  CHECK_DIF_OK(dif_usbdev_irq_get_type(usbdev_ctx.usbdev, irq, &type));
  if (type == kDifIrqTypeEvent) {
    CHECK_DIF_OK(dif_usbdev_irq_acknowledge(usbdev_ctx.usbdev, irq));
  } else if (mute_status_irq) {
    CHECK_DIF_OK(
        dif_usbdev_irq_set_enabled(usbdev_ctx.usbdev, irq, kDifToggleDisabled));
  }

  // Complete the IRQ at the PLIC.
  CHECK_DIF_OK(dif_rv_plic_irq_complete(plic_ctx.rv_plic, plic_ctx.hart_id,
                                        plic_irq_id));
}
