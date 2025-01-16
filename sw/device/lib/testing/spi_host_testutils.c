// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/testing/spi_host_testutils.h"

#include "sw/device/lib/dif/dif_pinmux.h"
#include "sw/device/lib/testing/pinmux_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"

#include "hw/top_chip/sw/autogen/top_chip.h"

/**
 * Define an spi pinmux configuration.
 */
typedef struct spi_host1_pinmux_pins {
  pinmux_testutils_mio_pin_t clk;
  pinmux_testutils_mio_pin_t sd0;
  pinmux_testutils_mio_pin_t sd1;
  pinmux_testutils_mio_pin_t sd2;
  pinmux_testutils_mio_pin_t sd3;
} spi_host1_pinmux_pins_t;

/**
 * This table store spi host 1 pin mappings of different platforms.
 * This is used to connect spi host 1 to mio pins based on the platform.
 */
static const spi_host1_pinmux_pins_t kSpiHost1PinmuxMap[] = {
    [kSpiPinmuxPlatformIdCw310] =
        {
            .clk =
                {
                    .insel = kTopChipPinmuxInselConstantZero,
                    .mio_out = kTopChipPinmuxMioOutIoa3,
                },
            .sd0 =
                {
                    .insel = kTopChipPinmuxInselIoa5,
                    .mio_out = kTopChipPinmuxMioOutIoa5,
                },
            .sd1 =
                {
                    .insel = kTopChipPinmuxInselIoa4,
                    .mio_out = kTopChipPinmuxMioOutIoa4,
                },
            .sd2 =
                {
                    .insel = kTopChipPinmuxInselIoa8,
                    .mio_out = kTopChipPinmuxMioOutIoa8,
                },
            .sd3 =
                {
                    .insel = kTopChipPinmuxInselIoa7,
                    .mio_out = kTopChipPinmuxMioOutIoa7,
                },
        },
    [kSpiPinmuxPlatformIdCw340] =
        {
            .clk =
                {
                    .insel = kTopChipPinmuxInselConstantZero,
                    .mio_out = kTopChipPinmuxMioOutIoa3,
                },
            .sd0 =
                {
                    .insel = kTopChipPinmuxInselIoa5,
                    .mio_out = kTopChipPinmuxMioOutIoa5,
                },
            .sd1 =
                {
                    .insel = kTopChipPinmuxInselIoa4,
                    .mio_out = kTopChipPinmuxMioOutIoa4,
                },
            .sd2 =
                {
                    .insel = kTopChipPinmuxInselIoa8,
                    .mio_out = kTopChipPinmuxMioOutIoa8,
                },
            .sd3 =
                {
                    .insel = kTopChipPinmuxInselIoa7,
                    .mio_out = kTopChipPinmuxMioOutIoa7,
                },
        },
    [kSpiPinmuxPlatformIdTeacup] =
        {
            .clk =
                {
                    .insel = kTopChipPinmuxInselConstantZero,
                    .mio_out = kTopChipPinmuxMioOutIoa3,
                },
            .sd0 =
                {
                    .insel = kTopChipPinmuxInselIoa4,
                    .mio_out = kTopChipPinmuxMioOutIoa4,
                },
            .sd1 =
                {
                    .insel = kTopChipPinmuxInselIoa5,
                    .mio_out = kTopChipPinmuxMioOutIoa5,
                },
            .sd2 =
                {
                    .insel = kTopChipPinmuxInselIoa8,
                    .mio_out = kTopChipPinmuxMioOutIoa8,
                },
            .sd3 =
                {
                    .insel = kTopChipPinmuxInselIoa7,
                    .mio_out = kTopChipPinmuxMioOutIoa7,
                },
        },
};

// `extern` declarations to give the inline functions in the
// corresponding header a link location.
extern status_t spi_host_testutils_is_active(dif_spi_host_t *spi_host);

status_t spi_host_testutils_flush(dif_spi_host_t *spi_host) {
  dif_spi_host_status_t status;
  uint8_t dummy[sizeof(uint32_t)];
  TRY(dif_spi_host_get_status(spi_host, &status));
  while (!status.rx_empty) {
    TRY(dif_spi_host_fifo_read(spi_host, &dummy, sizeof(dummy)));
    TRY(dif_spi_host_get_status(spi_host, &status));
  }
  return OK_STATUS();
}

status_t spi_host1_pinmux_connect_to_bob(const dif_pinmux_t *pinmux,
                                         dif_pinmux_index_t csb_outsel,
                                         spi_pinmux_platform_id_t platform_id) {
  TRY_CHECK(platform_id < kSpiPinmuxPlatformIdCount);
  const spi_host1_pinmux_pins_t *platform = &kSpiHost1PinmuxMap[platform_id];

  // CSB.
  TRY(dif_pinmux_output_select(pinmux, csb_outsel,
                               kTopChipPinmuxOutselSpiHost1Csb));
  // SCLK.
  TRY(dif_pinmux_output_select(pinmux, platform->clk.mio_out,
                               kTopChipPinmuxOutselSpiHost1Sck));
  // SD0.
  TRY(dif_pinmux_input_select(pinmux, kTopChipPinmuxPeripheralInSpiHost1Sd0,
                              platform->sd0.insel));
  TRY(dif_pinmux_output_select(pinmux, platform->sd0.mio_out,
                               kTopChipPinmuxOutselSpiHost1Sd0));

  // SD1.
  TRY(dif_pinmux_input_select(pinmux, kTopChipPinmuxPeripheralInSpiHost1Sd1,
                              platform->sd1.insel));
  TRY(dif_pinmux_output_select(pinmux, platform->sd1.mio_out,
                               kTopChipPinmuxOutselSpiHost1Sd1));
  // SD2.
  TRY(dif_pinmux_input_select(pinmux, kTopChipPinmuxPeripheralInSpiHost1Sd2,
                              platform->sd2.insel));
  TRY(dif_pinmux_output_select(pinmux, platform->sd2.mio_out,
                               kTopChipPinmuxOutselSpiHost1Sd2));
  // SD3.
  TRY(dif_pinmux_input_select(pinmux, kTopChipPinmuxPeripheralInSpiHost1Sd3,
                              platform->sd3.insel));
  TRY(dif_pinmux_output_select(pinmux, platform->sd3.mio_out,
                               kTopChipPinmuxOutselSpiHost1Sd3));
  return OK_STATUS();
}
