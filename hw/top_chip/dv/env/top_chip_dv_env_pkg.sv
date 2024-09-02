// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

package top_chip_dv_env_pkg;
  import uvm_pkg::*;
  import dv_utils_pkg::*;
  import mem_bkdr_util_pkg::*;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  typedef enum {
    ChipMemSRAM,
    ChipMemROM
  } chip_mem_e;

  localparam int unsigned NGpioPins = 32;
  localparam int unsigned UartDpiBaud = 921_600;

  `include "top_chip_dv_env_cfg.sv"
  `include "top_chip_dv_env.sv"

endpackage
