// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class top_chip_dv_spi_host_tx_rx_vseq extends top_chip_dv_base_vseq;
  `uvm_object_utils(top_chip_dv_spi_host_tx_rx_vseq)

  `uvm_object_new

  rand int spi_host_idx;

  constraint spi_host_idx_c {
    spi_host_idx inside {[0:NSpis-1]};
  }

  task pre_start();
    // Use plusarg '+spi_host_idx' to choose a spi_host instance explicitly
    // if required, otherwise one will be chosen randomly.
    void'($value$plusargs("spi_host_idx=%0d", spi_host_idx));
    `DV_CHECK_FATAL(spi_host_idx inside {[0:NSpis-1]})

    // Select the first Csb for communication.
    p_sequencer.cfg.m_spi_device_agent_cfgs[spi_host_idx].csid = '0;

    // While the selection of this value seems arbitrary, it is not.
    // The spi agent has a concept of "transaction size" that is used by the
    // monitor / driver to determine how it should view the number of collected
    // bytes.
    // The value 4 is chosen because the corresponding C test case does the following:
    // Transmit 4 bytes
    // Transmit and receive N bytes
    // Receive 4 bytes
    // This sequence, when paired with the agent's 4 byte granularity playback,
    // works well as a smoke test case for spi host activity.
    p_sequencer.cfg.m_spi_device_agent_cfgs[spi_host_idx].num_bytes_per_trans_in_mon = 4;

    // Setting the byte order to 0 ensures that the 4 byte transaction sent to
    // the agent from the DUT is played back in exactly the same order, thus
    // making things easy to compare.
    p_sequencer.cfg.m_spi_device_agent_cfgs[spi_host_idx].byte_order = '0;
    super.pre_start();
  endtask


  virtual task body();
    spi_device_seq m_device_seq;
    bit [7:0] spi_host_idx_data[];
    super.body();

    // Wait for reset before configuring
    p_sequencer.ifs.peri_clk_if.wait_for_reset();

    // sw_symbol_backdoor_overwrite takes an array as the input
    spi_host_idx_data = {spi_host_idx};
    sw_symbol_backdoor_overwrite("kSPIHostIdx", spi_host_idx_data);

    `uvm_info(`gfn, $sformatf("Testing with spi host %0d", spi_host_idx), UVM_LOW)

    // enable spi agent
    // Sunburst - no pinmux or DPI model at present so nothing to enable here.

    // create and start the spi_device sequence
    m_device_seq = spi_device_seq::type_id::create("m_device_seq");
    fork m_device_seq.start(p_sequencer.spi_device_sequencer_hs[spi_host_idx]); join_none
  endtask


endclass : top_chip_dv_spi_host_tx_rx_vseq
