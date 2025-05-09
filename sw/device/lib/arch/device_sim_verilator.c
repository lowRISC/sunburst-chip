// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <assert.h>
#include <stdbool.h>

#include "sw/device/lib/arch/device.h"

#include "hw/top_chip/sw/autogen/top_chip.h"
// TODO: Decide what functionality we require in the core_ibex wrapper.
//#include "rv_core_ibex_regs.h"
#include "uart_regs.h"

/**
 * @file
 * @brief Device-specific symbol definitions for the Verilator device.
 */

const device_type_t kDeviceType = kDeviceSimVerilator;

// Changes to the clock frequency or UART baud rate must also be reflected at
// `hw/top_chip/dv/verilator/top_chip_verilator.sv`.
#define CPU_FREQ_HZ 500 * 1000
const uint64_t kClockFreqCpuHz = CPU_FREQ_HZ;  // 500kHz

// This function is specific for the frequency above. Notice since the cycle
// time is 2 us we round up.
uint64_t to_cpu_cycles(uint64_t usec) {
  static_assert(CPU_FREQ_HZ == 500 * 1000,
                "The verilator to_cpu_cycles function needs refactoring.");
  return (usec + 1) / 2;
}

// Sunburst - no high speed peripheral clock, use normal peripheral clock freq
const uint64_t kClockFreqHiSpeedPeripheralHz = 125 * 1000;  // 125kHz

const uint64_t kClockFreqPeripheralHz = 125 * 1000;  // 125kHz

const uint64_t kClockFreqUsbHz = 500 * 1000;  // 500kHz

const uint64_t kClockFreqAonHz = 125 * 1000;  // 125kHz

const uint64_t kUartBaudrate = 3750;  // kClockFreqPeripheralHz / (1.5Mbaud / 50MHz)

const uint32_t kUartNCOValue =
    CALCULATE_UART_NCO(kUartBaudrate, kClockFreqPeripheralHz);

const uint32_t kUartBaud115K =
    CALCULATE_UART_NCO(115200, kClockFreqPeripheralHz);
const uint32_t kUartBaud230K =
    CALCULATE_UART_NCO(115200 * 2, kClockFreqPeripheralHz);
const uint32_t kUartBaud460K =
    CALCULATE_UART_NCO(115200 * 4, kClockFreqPeripheralHz);
const uint32_t kUartBaud921K =
    CALCULATE_UART_NCO(115200 * 8, kClockFreqPeripheralHz);
const uint32_t kUartBaud1M33 =
    CALCULATE_UART_NCO(1333333, kClockFreqPeripheralHz);
const uint32_t kUartBaud1M50 =
    CALCULATE_UART_NCO(1500000, kClockFreqPeripheralHz);

const uint32_t kUartTxFifoCpuCycles = CALCULATE_UART_TX_FIFO_CPU_CYCLES(
    kUartBaudrate, kClockFreqCpuHz, UART_PARAM_TX_FIFO_DEPTH);

const uint32_t kAstCheckPollCpuCycles =
    CALCULATE_AST_CHECK_POLL_CPU_CYCLES(kClockFreqCpuHz);

const uintptr_t kDeviceTestStatusAddress =
    TOP_CHIP_RV_CORE_IBEX_CFG_BASE_ADDR +
    RV_CORE_IBEX_DV_SIM_WINDOW_REG_OFFSET;

const uintptr_t kDeviceLogBypassUartAddress = 0;

void device_fpga_version_print(void) {}
