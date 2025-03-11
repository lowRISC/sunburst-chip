// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`define SYSTEM_HIER top_chip_asic_tb.u_dut.u_top_chip_system
`define CPU_HIER `SYSTEM_HIER.u_core_ibex
`define MEM_ARRAY_SUB gen_generic.u_impl_generic.mem

`define SRAM_MEM_HIER `SYSTEM_HIER.u_sram.u_ram.`MEM_ARRAY_SUB
`define SRAM_CAP_MEM_HIER `SYSTEM_HIER.u_sram.u_cap_ram.`MEM_ARRAY_SUB
`define ROM_MEM_HIER `SYSTEM_HIER.u_rom.u_rom.`MEM_ARRAY_SUB
`define USBDEV_BUF_HIER `SYSTEM_HIER.u_usbdev.gen_no_stubbed_memory.u_memory_1p.u_mem.`MEM_ARRAY_SUB
