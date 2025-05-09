// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class top_chip_dv_i2c_tx_rx_vseq extends top_chip_dv_base_vseq;

  ///////////////
  // VARIABLES //
  ///////////////

  // TODO(OpenTitan#23920) Figure out a better way to calculate this based on testbench clock frequency
  int clock_period_nanos = 41;
  int i2c_clock_period_nanos = 1000;
  int rise_fall_nanos = 10;
  int rise_cycles = ((rise_fall_nanos - 1) / clock_period_nanos) + 1;
  int fall_cycles = ((rise_fall_nanos - 1) / clock_period_nanos) + 1;
  int clock_period_cycles = ((i2c_clock_period_nanos - 1) / clock_period_nanos) + 1;
  int half_period_cycles = ((i2c_clock_period_nanos/2 - 1) / clock_period_nanos) + 1;

  // Keep a count of the total number of read data bytes we expect the agent to read from the DUT.
  int sent_rd_byte[NI2cs] = '{NI2cs{ 0 }};

  `uvm_object_utils_begin(top_chip_dv_i2c_tx_rx_vseq)
    `uvm_field_int(clock_period_nanos,     UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(i2c_clock_period_nanos, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(rise_fall_nanos,        UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(rise_cycles,            UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(fall_cycles,            UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(clock_period_cycles,    UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(half_period_cycles,     UVM_DEFAULT | UVM_DEC)
  `uvm_object_utils_end

  `uvm_object_new

  /////////////
  // METHODS //
  /////////////

  virtual task body();
    super.body();

    // Wait for reset to be asserted and de-asserted before trying to set
    // config parameters and enable the monitor, otherwise the monitor may
    // bork the sequence item already received by the sequence.
    p_sequencer.ifs.peri_clk_if.wait_for_reset();
  endtask

  function void print_i2c_timing_cfg(uint i2c_idx);
    string str;
    str = {str, $sformatf("\n    timing_cfg.tSetupStart       : %d",
              p_sequencer.cfg.m_i2c_agent_cfgs[i2c_idx].timing_cfg.tSetupStart)};
    str = {str, $sformatf("\n    timing_cfg.tHoldStart        : %d",
              p_sequencer.cfg.m_i2c_agent_cfgs[i2c_idx].timing_cfg.tHoldStart)};
    str = {str, $sformatf("\n    timing_cfg.tClockStart       : %d",
              p_sequencer.cfg.m_i2c_agent_cfgs[i2c_idx].timing_cfg.tClockStart)};
    str = {str, $sformatf("\n    timing_cfg.tClockLow         : %d",
              p_sequencer.cfg.m_i2c_agent_cfgs[i2c_idx].timing_cfg.tClockLow)};
    str = {str, $sformatf("\n    timing_cfg.tSetupBit         : %d",
              p_sequencer.cfg.m_i2c_agent_cfgs[i2c_idx].timing_cfg.tSetupBit)};
    str = {str, $sformatf("\n    timing_cfg.tClockPulse       : %d",
              p_sequencer.cfg.m_i2c_agent_cfgs[i2c_idx].timing_cfg.tClockPulse)};
    str = {str, $sformatf("\n    timing_cfg.tHoldBit          : %d",
              p_sequencer.cfg.m_i2c_agent_cfgs[i2c_idx].timing_cfg.tHoldBit)};
    str = {str, $sformatf("\n    timing_cfg.tClockStop        : %d",
              p_sequencer.cfg.m_i2c_agent_cfgs[i2c_idx].timing_cfg.tClockStop)};
    str = {str, $sformatf("\n    timing_cfg.tSetupStop        : %d",
              p_sequencer.cfg.m_i2c_agent_cfgs[i2c_idx].timing_cfg.tSetupStop)};
    str = {str, $sformatf("\n    timing_cfg.tHoldStop         : %d",
              p_sequencer.cfg.m_i2c_agent_cfgs[i2c_idx].timing_cfg.tHoldStop)};
    str = {str, $sformatf("\n    timing_cfg.tTimeOut          : %d",
              p_sequencer.cfg.m_i2c_agent_cfgs[i2c_idx].timing_cfg.tTimeOut)};
    str = {str, $sformatf("\n    timing_cfg.enbTimeOut        : %d",
              p_sequencer.cfg.m_i2c_agent_cfgs[i2c_idx].timing_cfg.enbTimeOut)};
    str = {str, $sformatf("\n    timing_cfg.tStretchHostClock : %d",
              p_sequencer.cfg.m_i2c_agent_cfgs[i2c_idx].timing_cfg.tStretchHostClock)};
    str = {str, $sformatf("\n    timing_cfg.tSdaUnstable      : %d",
              p_sequencer.cfg.m_i2c_agent_cfgs[i2c_idx].timing_cfg.tSdaUnstable)};
    str = {str, $sformatf("\n    timing_cfg.tSdaInterference  : %d",
              p_sequencer.cfg.m_i2c_agent_cfgs[i2c_idx].timing_cfg.tSdaInterference)};
    str = {str, $sformatf("\n    timing_cfg.tSclInterference  : %d",
              p_sequencer.cfg.m_i2c_agent_cfgs[i2c_idx].timing_cfg.tSclInterference)};
    `uvm_info(`gfn, $sformatf("%s", str), UVM_MEDIUM);
  endfunction

endclass : top_chip_dv_i2c_tx_rx_vseq
