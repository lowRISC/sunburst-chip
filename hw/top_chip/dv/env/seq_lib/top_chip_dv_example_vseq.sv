// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class top_chip_dv_example_vseq extends top_chip_dv_base_vseq;
  `uvm_object_utils(top_chip_dv_example_vseq)
  `uvm_object_new

  task body();
    bit [31:0] expected_gpio_pattern = 32'hAAAAAAAA;
    for (int i = 0;i < 10; i++) begin
      `uvm_info(`gfn, $sformatf("Waiting for GPIO pattern #%02d: %x", i, expected_gpio_pattern),
          UVM_MEDIUM);

      wait(p_sequencer.ifs.gpio_pins_vif.pins == expected_gpio_pattern);

      `uvm_info(`gfn, "Expected pattern seen!", UVM_MEDIUM);

      expected_gpio_pattern = ~expected_gpio_pattern;
    end

    `uvm_info(`gfn, "All expected GPIO patterns have been seen", UVM_LOW);
  endtask
endclass
