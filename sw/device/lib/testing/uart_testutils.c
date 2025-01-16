// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/testing/uart_testutils.h"

#include <assert.h>
#include <stdbool.h>
#include <stdint.h>

#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/dif/dif_pinmux.h"
#include "sw/device/lib/dif/dif_uart.h"
#include "sw/device/lib/runtime/hart.h"
#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/pinmux_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"

#include "hw/top_chip/sw/autogen/top_chip.h"
#include "uart_regs.h"  // Generated.

#define MODULE_ID MAKE_MODULE_ID('u', 't', 'u')

/**
 * This table stores the pins for all UART instances of Earlgrey.
 */
static const pinmux_testutils_peripheral_pin_t kUartPinmuxPins[] = {
    // UART0.
    {
        .peripheral_in = kTopChipPinmuxPeripheralInUart0Rx,
        .outsel = kTopChipPinmuxOutselUart0Tx,
    },
    // UART1.
    {
        .peripheral_in = kTopChipPinmuxPeripheralInUart1Rx,
        .outsel = kTopChipPinmuxOutselUart1Tx,
    },
    // UART2.
    {
        .peripheral_in = kTopChipPinmuxPeripheralInUart2Rx,
        .outsel = kTopChipPinmuxOutselUart2Tx,
    },
    // UART3.
    {
        .peripheral_in = kTopChipPinmuxPeripheralInUart3Rx,
        .outsel = kTopChipPinmuxOutselUart3Tx,
    },
};

/**
 * This table stores UART pin mappings for synthesized platforms.
 */
static const pinmux_testutils_mio_pin_t
    kUartSynthPins[kUartPinmuxChannelCount] = {
        [kUartPinmuxChannelConsole] =
            {
                .mio_out = kTopChipPinmuxMioOutIoc4,
                .insel = kTopChipPinmuxInselIoc3,
            },
        [kUartPinmuxChannelDut] = {
            .mio_out = kTopChipPinmuxMioOutIob5,
            .insel = kTopChipPinmuxInselIob4,
        }};

/**
 * The DV platform is handled separately at the moment: all four UARTs have
 * their own channels that they map to rather than using one channel for the
 * console and second for the DUT.
 */
static const pinmux_testutils_mio_pin_t kUartDvPins[4] = {
    // UART0.
    {
        .mio_out = kTopChipPinmuxMioOutIoc4,
        .insel = kTopChipPinmuxInselIoc3,
    },
    // UART1.
    {
        .mio_out = kTopChipPinmuxMioOutIob5,
        .insel = kTopChipPinmuxInselIob4,
    },
    // UART2.
    {
        .mio_out = kTopChipPinmuxMioOutIoa5,
        .insel = kTopChipPinmuxInselIoa4,
    },
    // UART3.
    {
        .mio_out = kTopChipPinmuxMioOutIoa1,
        .insel = kTopChipPinmuxInselIoa0,
    }};

static const uart_cfg_params_t kUartCfgParams[4] = {
    (uart_cfg_params_t){
        .base_addr = TOP_CHIP_UART0_BASE_ADDR,
        .peripheral_id = kTopChipPlicPeripheralUart0,
        .irq_tx_watermark_id = kTopChipPlicIrqIdUart0TxWatermark,
        .irq_tx_empty_id = kTopChipPlicIrqIdUart0TxEmpty,
        .irq_rx_watermark_id = kTopChipPlicIrqIdUart0RxWatermark,
        .irq_tx_done_id = kTopChipPlicIrqIdUart0TxDone,
        .irq_rx_overflow_id = kTopChipPlicIrqIdUart0RxOverflow,
        .irq_rx_frame_err_id = kTopChipPlicIrqIdUart0RxFrameErr,
        .irq_rx_break_err_id = kTopChipPlicIrqIdUart0RxBreakErr,
        .irq_rx_timeout_id = kTopChipPlicIrqIdUart0RxTimeout,
        .irq_rx_parity_err_id = kTopChipPlicIrqIdUart0RxParityErr,
    },
    (uart_cfg_params_t){
        .base_addr = TOP_CHIP_UART1_BASE_ADDR,
        .peripheral_id = kTopChipPlicPeripheralUart1,
        .irq_tx_watermark_id = kTopChipPlicIrqIdUart1TxWatermark,
        .irq_tx_empty_id = kTopChipPlicIrqIdUart1TxEmpty,
        .irq_rx_watermark_id = kTopChipPlicIrqIdUart1RxWatermark,
        .irq_tx_done_id = kTopChipPlicIrqIdUart1TxDone,
        .irq_rx_overflow_id = kTopChipPlicIrqIdUart1RxOverflow,
        .irq_rx_frame_err_id = kTopChipPlicIrqIdUart1RxFrameErr,
        .irq_rx_break_err_id = kTopChipPlicIrqIdUart1RxBreakErr,
        .irq_rx_timeout_id = kTopChipPlicIrqIdUart1RxTimeout,
        .irq_rx_parity_err_id = kTopChipPlicIrqIdUart1RxParityErr,
    },
    (uart_cfg_params_t){
        .base_addr = TOP_CHIP_UART2_BASE_ADDR,
        .peripheral_id = kTopChipPlicPeripheralUart2,
        .irq_tx_watermark_id = kTopChipPlicIrqIdUart2TxWatermark,
        .irq_tx_empty_id = kTopChipPlicIrqIdUart2TxEmpty,
        .irq_rx_watermark_id = kTopChipPlicIrqIdUart2RxWatermark,
        .irq_tx_done_id = kTopChipPlicIrqIdUart2TxDone,
        .irq_rx_overflow_id = kTopChipPlicIrqIdUart2RxOverflow,
        .irq_rx_frame_err_id = kTopChipPlicIrqIdUart2RxFrameErr,
        .irq_rx_break_err_id = kTopChipPlicIrqIdUart2RxBreakErr,
        .irq_rx_timeout_id = kTopChipPlicIrqIdUart2RxTimeout,
        .irq_rx_parity_err_id = kTopChipPlicIrqIdUart2RxParityErr,
    },
    (uart_cfg_params_t){
        .base_addr = TOP_CHIP_UART3_BASE_ADDR,
        .peripheral_id = kTopChipPlicPeripheralUart3,
        .irq_tx_watermark_id = kTopChipPlicIrqIdUart3TxWatermark,
        .irq_tx_empty_id = kTopChipPlicIrqIdUart3TxEmpty,
        .irq_rx_watermark_id = kTopChipPlicIrqIdUart3RxWatermark,
        .irq_tx_done_id = kTopChipPlicIrqIdUart3TxDone,
        .irq_rx_overflow_id = kTopChipPlicIrqIdUart3RxOverflow,
        .irq_rx_frame_err_id = kTopChipPlicIrqIdUart3RxFrameErr,
        .irq_rx_break_err_id = kTopChipPlicIrqIdUart3RxBreakErr,
        .irq_rx_timeout_id = kTopChipPlicIrqIdUart3RxTimeout,
        .irq_rx_parity_err_id = kTopChipPlicIrqIdUart3RxParityErr,
    }};

status_t uart_testutils_select_pinmux(const dif_pinmux_t *pinmux,
                                      uint8_t uart_idx,
                                      uart_pinmux_channel_t channel) {
  TRY_CHECK(channel < kUartPinmuxChannelCount &&
                uart_idx < ARRAYSIZE(kUartPinmuxPins),
            "Index out of bounds");

  pinmux_testutils_mio_pin_t mio_pin = kDeviceType == kDeviceSimDV
                                           ? kUartDvPins[uart_idx]
                                           : kUartSynthPins[channel];

  TRY(dif_pinmux_input_select(pinmux, kUartPinmuxPins[uart_idx].peripheral_in,
                              mio_pin.insel));
  TRY(dif_pinmux_output_select(pinmux, mio_pin.mio_out,
                               kUartPinmuxPins[uart_idx].outsel));

  return OK_STATUS();
}

status_t uart_testutils_detach_pinmux(const dif_pinmux_t *pinmux,
                                      uint8_t uart_idx) {
  TRY_CHECK(uart_idx < ARRAYSIZE(kUartPinmuxPins), "Index out of bounds");

  TRY(dif_pinmux_input_select(pinmux, kUartPinmuxPins[uart_idx].peripheral_in,
                              kTopChipPinmuxInselConstantZero));

  return OK_STATUS();
}

status_t uart_testutils_cfg_params(uint8_t uart_idx,
                                   uart_cfg_params_t *params) {
  TRY_CHECK(uart_idx < ARRAYSIZE(kUartCfgParams), "Index out of bounds");

  *params = kUartCfgParams[uart_idx];

  return OK_STATUS();
}
