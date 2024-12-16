// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class top_chip_dv_if_bundle extends uvm_object;
  `uvm_object_utils_begin(top_chip_dv_if_bundle)
  `uvm_object_utils_end

  `uvm_object_new

  virtual clk_rst_if sys_clk_vif;
  virtual clk_rst_if peri_clk_if;
  virtual pins_if#(NGpioPins) gpio_pins_vif;
endclass
