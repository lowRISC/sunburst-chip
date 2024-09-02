// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`define SYSTEM_HIER top_chip_asic_tb.u_dut.u_top_chip_system
`define MEM_ARRAY_SUB gen_generic.u_impl_generic.mem

`define SRAM_MEM_HIER `SYSTEM_HIER.u_sram.u_ram.`MEM_ARRAY_SUB
`define ROM_MEM_HIER `SYSTEM_HIER.u_rom.u_rom.`MEM_ARRAY_SUB
