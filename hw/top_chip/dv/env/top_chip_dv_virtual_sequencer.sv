// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class top_chip_dv_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(top_chip_dv_virtual_sequencer)
  `uvm_component_new

  top_chip_dv_env_cfg   cfg;
  top_chip_dv_if_bundle ifs;
endclass
