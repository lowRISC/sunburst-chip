// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class top_chip_dv_base_test extends uvm_test;
  top_chip_dv_env env;

  `uvm_component_utils(top_chip_dv_base_test)
  `uvm_component_new

  virtual function void build_phase(uvm_phase phase);
    dv_report_server m_dv_report_server = new();
    uvm_report_server::set_server(m_dv_report_server);

    super.build_phase(phase);

    env = top_chip_dv_env::type_id::create("env", this);
    env.cfg = top_chip_dv_env_cfg::type_id::create("cfg", this);
    env.cfg.initialize();
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    env.load_memories();
    phase.raise_objection(this);
    run_test();
    phase.drop_objection(this);
  endtask

  virtual task run_test();
    string test_seq_s;

    if(!$value$plusargs("UVM_TEST_SEQ=%0s", test_seq_s)) begin
      `uvm_fatal(`gfn, "Sequence name was not provided via +UVM_TEST_SEQ, cannot run test")
    end

    fork : isolation_work
      fork
        begin
          run_seq(test_seq_s);
        end
        begin
          repeat (env.cfg.sys_timeout_cycles) env.ifs.sys_clk_vif.wait_clks(1);
          `uvm_fatal(`gfn, $sformatf("Reached system cycle timeout of %d", env.cfg.sys_timeout_cycles))
        end
      join_any

      disable fork;
    join
  endtask

  virtual task run_seq(string test_seq_s);
    uvm_sequence test_seq = create_seq_by_name(test_seq_s);

    // Setting the sequencer before the sequence is randomized is mandatory. We do this so that the
    // sequence has access to the UVM environment's cfg handle via the p_sequencer handle within the
    // randomization constraints.
    test_seq.set_sequencer(env.virtual_sequencer);
    `DV_CHECK_RANDOMIZE_FATAL(test_seq)

    `uvm_info(`gfn, {"Starting test sequence ", test_seq_s}, UVM_MEDIUM)
    test_seq.start(env.virtual_sequencer);
    `uvm_info(`gfn, {"Finished test sequence ", test_seq_s}, UVM_MEDIUM)
  endtask
endclass
