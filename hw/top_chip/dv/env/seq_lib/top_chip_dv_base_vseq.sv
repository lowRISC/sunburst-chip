// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class top_chip_dv_base_vseq extends uvm_sequence;
  `uvm_object_utils(top_chip_dv_base_vseq)
  `uvm_declare_p_sequencer(top_chip_dv_virtual_sequencer)

  `uvm_object_new

  task body();
    // Empty body for base virtual sequence, required to avoid UVM warning
  endtask

  task post_start();
    super.post_start();

    wait_for_sw_test_done();
  endtask

  virtual task wait_for_sw_test_done();
    `uvm_info(`gfn, "Waiting for software to signal test end", UVM_LOW);
    fork
      begin: isolation_thread
        fork
          begin
            // Nice case - test status interface completion signal
            wait(p_sequencer.cfg.sw_test_status_vif.sw_test_done);
            // Pass/Fail message output by sw_test_status_vif
          end
          begin
            // Legacy case - GPIO completion signal
            wait(p_sequencer.ifs.gpio_pins_vif.pins == 32'hDEADBEEF);
            `uvm_info(`gfn, "TEST PASSED! Completion signal seen from software", UVM_LOW);
          end
        join_any
        disable fork;
      end: isolation_thread
    join

  endtask
endclass
