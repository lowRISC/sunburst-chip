// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class top_chip_dv_uart_base_vseq extends top_chip_dv_base_vseq;
  `uvm_object_utils(top_chip_dv_uart_base_vseq)
  `uvm_object_new

  int uart_idx;

  // Local queue for holding received UART TX data.
  byte uart_tx_data_q[$];

  task pre_start();
    void'($value$plusargs("uart_idx=%0d", uart_idx));
    `DV_CHECK_FATAL(uart_idx inside {[0:NUarts-1]})
    super.pre_start();
  endtask

  // Configures and connects the UART agent for driving data over RX and receiving data on TX.
  //
  // Note that to fetch packets over the TX port, the get_uart_tx_items() task needs to be called
  // separately as a forked thread in the test sequence.
  //
  // uart_idx: The UART instance.
  // enable: 1: enable (configures and connects), 0: disable (disables sampling and disconnects)
  // enable_tx_monitor: Enable sampling data on the TX port (default on).
  // enable_rx_monitor: Enable sampling data on the RX port (default off).
  // en_parity: Enable parity when driving RX traffic.
  // odd_parity: Compute odd parity when driving RX traffic.
  // baud_rate: The baud rate.
  virtual function void configure_uart_agent(int uart_idx,
                                             bit enable,
                                             bit enable_tx_monitor = 1'b1,
                                             bit enable_rx_monitor = 1'b0,
                                             bit en_parity = 1'b0,
                                             bit odd_parity = 1'b0,
                                             baud_rate_e baud_rate = BaudRate1Mbps);
    if (enable) begin
      `uvm_info(`gfn, $sformatf("Configuring and connecting UART%0d", uart_idx), UVM_LOW)
     p_sequencer.cfg.m_uart_agent_cfgs[uart_idx].set_parity(en_parity, odd_parity);
     p_sequencer.cfg.m_uart_agent_cfgs[uart_idx].set_baud_rate(baud_rate);
     p_sequencer.cfg.m_uart_agent_cfgs[uart_idx].en_tx_monitor = enable_tx_monitor;
     p_sequencer.cfg.m_uart_agent_cfgs[uart_idx].en_rx_monitor = enable_rx_monitor;
     p_sequencer.cfg.m_uart_agent_cfgs[uart_idx].vif.enable = 1;
    end else begin
      `uvm_info(`gfn, $sformatf("Disconnecting UART%0d", uart_idx), UVM_LOW)
     p_sequencer.cfg.m_uart_agent_cfgs[uart_idx].en_tx_monitor = 0;
     p_sequencer.cfg.m_uart_agent_cfgs[uart_idx].en_rx_monitor = 0;
     p_sequencer.cfg.m_uart_agent_cfgs[uart_idx].vif.enable = 0;
    end
  endfunction

    // Grab packets sent by the DUT over the UART TX port.
  virtual task get_uart_tx_items(int uart_idx = 0);
    uart_item item;
    forever begin
      p_sequencer.uart_tx_fifos[uart_idx].get(item);
      `uvm_info(`gfn, $sformatf("Received UART data over TX:\n%0h", item.data), UVM_HIGH)
      uart_tx_data_q.push_back(item.data);
    end
  endtask

  virtual task body();
    super.body();

    // Wait for reset to be asserted and de-asserted before trying to set
    // config parameters, otherwise they may be reset too.
    p_sequencer.ifs.peri_clk_if.wait_for_reset();

    // `DV_WAIT(cfg.sw_test_status_vif.sw_test_status == SwTestStatusInTest);

    configure_uart_agent(.uart_idx(uart_idx), .enable(1), .enable_rx_monitor(1));
  endtask

endclass : top_chip_dv_uart_base_vseq
