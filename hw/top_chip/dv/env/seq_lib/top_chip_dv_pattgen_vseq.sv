// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class top_chip_dv_pattgen_vseq extends top_chip_dv_base_vseq;
  `uvm_object_utils(top_chip_dv_pattgen_vseq)
  `uvm_object_new

  typedef struct packed {
    // polarity:
    //    0 : sample rising edge
    //    1 : sample falling edge
    bit          polarity;
    bit [31:0]   clk_div;
    bit [31:0]   patt_lower;
    bit [31:0]   patt_upper;
    // range has +1 value of register
    // to match dif implementation

    // range : [1:64]
    bit [7:0]    len;
    // range : [1, 1024]
    bit [15:0]   rep;
  } pattgen_chan_cfg_t;

  // expected channel config
  pattgen_chan_cfg_t exp_cfg[NUM_PATTGEN_CHANNELS];

  // expected 64-bit pattern
  bit [63:0] exp_pat[NUM_PATTGEN_CHANNELS];

  rand pattgen_chan_cfg_t rand_chan_cfg;
  rand bit[1:0] chan_en;

  constraint chan_cfg_c {
    // Keep clock divisor and repetitions low to avoid chip-level tests
    // taking an excessively long time to run.
    rand_chan_cfg.clk_div dist { 0 := 4, [1:15] := 1};
    rand_chan_cfg.len inside {[1:64]};
    rand_chan_cfg.rep inside {[1:5]};
  }

  constraint chan_en_c {
    // At least one channel should be enabled.
    chan_en != 2'b0;
  }

  // TODO: delete these fixed constraints when the SW backdoor mechanism
  // has been ported/implemented.
  constraint fixed_c {
    // Force the test parameters to match those used in pattgen_check.cc
    // while we have no SW backdoor mechanism to allow us to affect them.
    // Unfortunately, this means both channels must have identical params
    // (without changing how this vseq constrains & randomises).
    rand_chan_cfg.clk_div == 2;
    rand_chan_cfg.len == 64;
    rand_chan_cfg.rep == 4;
    rand_chan_cfg.patt_lower == 32'hf0f0f0f0;
    rand_chan_cfg.patt_upper == 32'h11111111;
    rand_chan_cfg.polarity == 0;
    chan_en == 2'b11;
  }

  // TODO: delete the dummy function below when the SW backdoor mechanism
  // has been ported/implemented.
  function void sw_symbol_backdoor_overwrite(input string symbol, input bit [7:0] data[]);
  endfunction

  task body();
    bit[7:0] byte_arr[];
    super.body();

    // Wait for reset to be asserted and de-asserted before trying to set
    // config parameters, otherwise they may be reset too.
    p_sequencer.ifs.peri_clk_if.wait_for_reset();

    p_sequencer.cfg.m_pattgen_agent_cfg.en_monitor = 0;

    // TODO: delete the warning message below when the SW backdoor mechanism
    // has been ported/implemented.
    `uvm_info(`gfn, "WARNING: TEST PARAMETERS ARE FIXED! Need to implement SW Backdoor to allow randomisation", UVM_NONE)

    byte_arr = {chan_en};
    sw_symbol_backdoor_overwrite("kChannelEnableDV", byte_arr);
    `uvm_info(`gfn, $sformatf("PATTGEN CHAN_EN: %2b", chan_en), UVM_MEDIUM)

    for (int i = 0; i < NUM_PATTGEN_CHANNELS; i++) begin
      exp_cfg[i] = rand_chan_cfg;
      p_sequencer.cfg.m_pattgen_agent_cfg.polarity[i] = exp_cfg[i].polarity;
      p_sequencer.cfg.m_pattgen_agent_cfg.length[i] = exp_cfg[i].len * exp_cfg[i].rep;
      p_sequencer.cfg.m_pattgen_agent_cfg.div[i] = 2 * (exp_cfg[i].clk_div + 1);
      exp_pat[i] = {exp_cfg[i].patt_upper, exp_cfg[i].patt_lower};
      `DV_CHECK_MEMBER_RANDOMIZE_FATAL(rand_chan_cfg)
    end

    byte_arr = {exp_cfg[0].polarity};
    sw_symbol_backdoor_overwrite("kPattPol0DV", byte_arr);
    byte_arr = {<<8{{<<32{exp_cfg[0].clk_div}}}};
    sw_symbol_backdoor_overwrite("kPattDiv0DV", byte_arr);
    byte_arr = {<<8{{<<32{exp_cfg[0].patt_lower}}}};
    sw_symbol_backdoor_overwrite("kPattLower0DV", byte_arr);
    byte_arr = {<<8{{<<32{exp_cfg[0].patt_upper}}}};
    sw_symbol_backdoor_overwrite("kPattUpper0DV", byte_arr);
    byte_arr = {exp_cfg[0].len};
    sw_symbol_backdoor_overwrite("kPattLen0DV", byte_arr);
    byte_arr = {<<8{{<<16{exp_cfg[0].rep}}}};
    sw_symbol_backdoor_overwrite("kPattRep0DV", byte_arr);

    if (chan_en[0]) begin
      `uvm_info(`gfn, $sformatf("PATT_IOS CH0: cfg %p", exp_cfg[0]), UVM_MEDIUM)
    end

    byte_arr = {exp_cfg[1].polarity};
    sw_symbol_backdoor_overwrite("kPattPol1DV", byte_arr);
    byte_arr = {<<8{{<<32{exp_cfg[1].clk_div}}}};
    sw_symbol_backdoor_overwrite("kPattDiv1DV", byte_arr);
    byte_arr = {<<8{{<<32{exp_cfg[1].patt_lower}}}};
    sw_symbol_backdoor_overwrite("kPattLower1DV", byte_arr);
    byte_arr = {<<8{{<<32{exp_cfg[1].patt_upper}}}};
    sw_symbol_backdoor_overwrite("kPattUpper1DV", byte_arr);
    byte_arr = {exp_cfg[1].len};
    sw_symbol_backdoor_overwrite("kPattLen1DV", byte_arr);
    byte_arr = {<<8{{<<16{exp_cfg[1].rep}}}};
    sw_symbol_backdoor_overwrite("kPattRep1DV", byte_arr);
    if (chan_en[1]) begin
      `uvm_info(`gfn, $sformatf("PATT_IOS CH1: cfg %p", exp_cfg[1]), UVM_MEDIUM)
    end

    p_sequencer.cfg.m_pattgen_agent_cfg.en_monitor = 1;
    p_sequencer.cfg.m_pattgen_agent_cfg.chk_prediv = chan_en;

    // Start background checking of data from the monitor in pattgen_agent
    foreach (p_sequencer.pattgen_rx_fifo[i]) begin
      automatic int j = i;
      fork begin
        forever process_pattgen_data(j);
      end join_none
    end

    // Wait for the software to tell us the pattgen has finished outputting
    wait_for_sw_test_done();
    p_sequencer.cfg.m_pattgen_agent_cfg.channel_done = chan_en;

    `uvm_info(`gfn, "TEST: body done", UVM_HIGH)
  endtask

  // Collect pattgen_item from pattgen agent and check with expected pattern.
  // expected channel config length 'exp_cfg[].len' and repeat value 'exp_cfg[].rep' are used
  // to compare proper size of pattern.
  virtual task process_pattgen_data(int channel);
    pattgen_item item;
    int iter;

    p_sequencer.pattgen_rx_fifo[channel].get(item);

    `uvm_info(`gfn, $sformatf("PATTGEN_CH%0d: got pktlen:%0d",
                              channel, item.data_q.size()), UVM_LOW)
    repeat (exp_cfg[channel].rep) begin
      int bit_cnt = 0;
      while (bit_cnt < exp_cfg[channel].len) begin
        `DV_CHECK_EQ(item.data_q[bit_cnt], exp_pat[channel][bit_cnt],
                     $sformatf("Rep %0d bit_cnt:%0d mismatch", iter, bit_cnt))
        bit_cnt++;
      end
      iter++;
    end
  endtask

  // Override `post_start()` from base class to avoid calling
  // `wait_for_sw_test_done()` twice.
  virtual task post_start();
  endtask
endclass // top_chip_dv_pattgen_vseq
