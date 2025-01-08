// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

package top_chip_dv_env_pkg;
  import uvm_pkg::*;
  import dv_utils_pkg::*;
  import mem_bkdr_util_pkg::*;
  import pattgen_agent_pkg::*;
  import uart_agent_pkg::*;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  typedef enum {
    ChipMemSRAM,
    ChipMemROM
  } chip_mem_e;

  localparam int unsigned NGpioPins = 32;
  localparam int unsigned NUarts = 2;
  localparam int unsigned UartDpiBaud = 921_600;

  `include "top_chip_dv_env_cfg.sv"
  `include "top_chip_dv_if_bundle.sv"
  `include "top_chip_dv_virtual_sequencer.sv"
  `include "top_chip_dv_env.sv"
  `include "top_chip_dv_vseq_list.sv"

  `include "mem_clear_util.sv"
endpackage
