// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class top_chip_dv_base_test extends uvm_test;
  top_chip_dv_env env;

  virtual clk_rst_if sys_clk_vif;
  virtual pins_if#(NGpioPins) gpio_pins_vif;

  `uvm_component_utils(top_chip_dv_base_test)
  `uvm_component_new

  virtual function void build_phase(uvm_phase phase);
    dv_report_server m_dv_report_server = new();
    uvm_report_server::set_server(m_dv_report_server);

    super.build_phase(phase);

    env = top_chip_dv_env::type_id::create("env", this);
    env.cfg = top_chip_dv_env_cfg::type_id::create("cfg", this);
    env.cfg.get_mem_image_files_from_plusargs();

    if (!uvm_config_db#(virtual clk_rst_if)::get(null, "", "sys_clk_if", sys_clk_vif)) begin
      `uvm_fatal(`gfn, "Cannot get clk_if")
    end

    if (!uvm_config_db#(virtual pins_if#(NGpioPins))::get(null, "", "gpio_pins_vif", gpio_pins_vif)) begin
      `uvm_fatal(`gfn, "Cannot get gpio_pins_vif")
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    env.load_memories();
    wait_for_test_done();
    phase.drop_objection(this);
  endtask

  virtual task wait_for_test_done();
    fork : isolation_work
      fork
        begin
          // TODO: We likely want a better method for software to signal a test end (and other
          // events) to the testbench. This is a temporary measure til that exists.
          wait(gpio_pins_vif.pins == 32'hDEADBEEF);
          `uvm_info(`gfn, "TEST PASSED! Completion signal seen from software", UVM_LOW);
        end
        begin
          repeat (env.cfg.sys_timeout_cycles) sys_clk_vif.wait_clks(1);
          `uvm_fatal(`gfn, $sformatf("Reached system cycle timeout of %d", env.cfg.sys_timeout_cycles))
        end
      join_any

      disable fork;
    join
  endtask
endclass
