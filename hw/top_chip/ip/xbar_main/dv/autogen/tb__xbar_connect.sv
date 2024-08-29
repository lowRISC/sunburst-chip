// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// tb__xbar_connect generated by `tlgen.py` tool

xbar_main dut();

`DRIVE_CLK(clk_sys_i)
`DRIVE_CLK(clk_peri_i)

initial force dut.clk_sys_i = clk_sys_i;
initial force dut.clk_peri_i = clk_peri_i;

// TODO, all resets tie together
initial force dut.rst_sys_ni = rst_n;
initial force dut.rst_peri_ni = rst_n;

// Host TileLink interface connections
`CONNECT_TL_HOST_IF(rv_core_ibex__corei, dut, clk_sys_i, rst_n)
`CONNECT_TL_HOST_IF(rv_core_ibex__cored, dut, clk_sys_i, rst_n)

// Device TileLink interface connections
`CONNECT_TL_DEVICE_IF(rom, dut, clk_sys_i, rst_n)
`CONNECT_TL_DEVICE_IF(sram, dut, clk_sys_i, rst_n)
`CONNECT_TL_DEVICE_IF(revocation_ram, dut, clk_sys_i, rst_n)
`CONNECT_TL_DEVICE_IF(peri, dut, clk_peri_i, rst_n)
