// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stdbool.h>

#include "sw/device/lib/arch/device.h"

#include "hw/top_chip/sw/autogen/top_chip.h"
// TODO: Decide what functionality we require in the core_ibex wrapper.
//#include "rv_core_ibex_regs.h"
#include "uart_regs.h"

/**
 * Device-specific symbol definitions for the DV simulation device.
 */

const device_type_t kDeviceType = kDeviceSimDV;

// TODO: DV testbench completely randomizes these. Need to add code to
// retrieve these from a preloaded memory location set by the testbench.

const uint64_t kClockFreqCpuMhz = 250;

const uint64_t kClockFreqCpuHz = kClockFreqCpuMhz * 1000 * 1000;

uint64_t to_cpu_cycles(uint64_t usec) { return usec * kClockFreqCpuMhz; }

// Sunburst - no high speed peripheral clock, use normal peripheral clock freq
const uint64_t kClockFreqHiSpeedPeripheralHz = 50 * 1000 * 1000;  // 50MHz

const uint64_t kClockFreqPeripheralHz = 50 * 1000 * 1000;  // 50MHz

const uint64_t kClockFreqUsbHz = 48 * 1000 * 1000;  // 48MHz

const uint64_t kClockFreqAonHz = 400 * 1000;  // 400kHz

const uint64_t kUartBaudrate = 1500 * 1000;  // 1.5Mbaud

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

// TODO: We presently have no debug registers in core_ibex to mirror those present in rv_core_ibex
#if 0
const uintptr_t kDeviceTestStatusAddress =
    TOP_CHIP_RV_CORE_IBEX_CFG_BASE_ADDR +
    RV_CORE_IBEX_DV_SIM_WINDOW_REG_OFFSET;

const uintptr_t kDeviceLogBypassUartAddress =
    TOP_CHIP_RV_CORE_IBEX_CFG_BASE_ADDR +
    RV_CORE_IBEX_DV_SIM_WINDOW_REG_OFFSET + 0x04;
#else
// TODO: Although we do have sw test status monitoring, it overlays the ROM presently.
const uintptr_t kDeviceTestStatusAddress = TOP_CHIP_ROM_CTRL_ROM_BASE_ADDR;
const uintptr_t kDeviceLogBypassUartAddress = 0u;  // Use simulated UART for
#endif

void device_fpga_version_print(void) {}
