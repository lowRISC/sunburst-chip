// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class top_chip_dv_env extends uvm_env;
  `uvm_component_utils(top_chip_dv_env)
  `uvm_component_new

  top_chip_dv_env_cfg cfg;
  top_chip_dv_if_bundle ifs;

  top_chip_dv_virtual_sequencer virtual_sequencer;

  mem_bkdr_util mem_bkdr_util_h[chip_mem_e];

  // Agents
  i2c_agent     m_i2c_agents[NI2cs];
  jtag_agent    m_jtag_agent;
  pattgen_agent m_pattgen_agent;
  spi_agent     m_spi_device_agents[NSpis];
  uart_agent    m_uart_agents[NUarts];

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    for (chip_mem_e mem = mem.first(), int i = 0; i < mem.num(); mem = mem.next(), i++) begin
      string inst = $sformatf("mem_bkdr_util[%0s]", mem.name());

      if (!uvm_config_db#(mem_bkdr_util)::get(this, "", inst, mem_bkdr_util_h[mem])) begin
        `uvm_fatal(`gfn, {"failed to get ", inst, " from uvm_config_db"})
      end
    end

    // Get the handle to the SW log monitor (for compatible SW images)
    if (!uvm_config_db#(virtual sw_logger_if)::get(this, "", "sw_logger_vif", cfg.sw_logger_vif)) begin
      `uvm_fatal(`gfn, "failed to get sw_logger_vif from uvm_config_db")
    end
    // Initialize the sw logger interface.
    foreach (cfg.mem_image_files[i]) begin
      if (i inside {ChipMemSRAM, ChipMemROM}) begin
        cfg.sw_logger_vif.add_sw_log_db(cfg.mem_image_files[i]);
      end
    end
    cfg.sw_logger_vif.ready();

    // Get the handle to the SW test status monitor
    if (!uvm_config_db#(virtual sw_test_status_if)::get(this, "", "sw_test_status_vif", cfg.sw_test_status_vif)) begin
      `uvm_fatal(`gfn, "failed to get sw_test_status_vif from uvm_config_db")
    end

    ifs = top_chip_dv_if_bundle::type_id::create("ifs", this);

    if (!uvm_config_db#(virtual clk_rst_if)::get(this, "", "sys_clk_if", ifs.sys_clk_vif)) begin
      `uvm_fatal(`gfn, "Cannot get sys_clk_vif")
    end

    if (!uvm_config_db#(virtual clk_rst_if)::get(this, "", "peri_clk_if", ifs.peri_clk_if)) begin
      `uvm_fatal(`gfn, "Cannot get peri_clk_if")
    end

    if (!uvm_config_db#(virtual pins_if#(NGpioPins))::get(null, "", "gpio_pins_vif", ifs.gpio_pins_vif)) begin
      `uvm_fatal(`gfn, "Cannot get gpio_pins_vif")
    end

    // Instantiate I^2C agents
    foreach (m_i2c_agents[i]) begin
      m_i2c_agents[i] = i2c_agent::type_id::create($sformatf("m_i2c_agent%0d", i), this);
      uvm_config_db#(i2c_agent_cfg)::set(this, $sformatf("m_i2c_agent%0d*", i), "cfg", cfg.m_i2c_agent_cfgs[i]);
    end

    // Instantiate JTAG agent
    m_jtag_agent = jtag_agent::type_id::create("m_jtag_agent", this);
    uvm_config_db#(jtag_agent_cfg)::set(this, "m_jtag_agent*", "cfg", cfg.m_jtag_agent_cfg);

    // Instantiate pattgen agent
    m_pattgen_agent = pattgen_agent::type_id::create("m_pattgen_agent", this);
    uvm_config_db#(pattgen_agent_cfg)::set(this, "m_pattgen_agent*", "cfg", cfg.m_pattgen_agent_cfg);

    // Instantiate SPI device agents (for connecting to SPI hosts)
    foreach (m_spi_device_agents[i]) begin
      m_spi_device_agents[i] = spi_agent::type_id::create($sformatf("m_spi_device_agents%0d", i), this);
      uvm_config_db#(spi_agent_cfg)::set(this, $sformatf("m_spi_device_agents%0d*", i), "cfg",
                                         cfg.m_spi_device_agent_cfgs[i]);
    end

    // Instantiate uart agents
    foreach (m_uart_agents[i]) begin
      m_uart_agents[i] = uart_agent::type_id::create($sformatf("m_uart_agent%0d", i), this);
      uvm_config_db#(uart_agent_cfg)::set(this, $sformatf("m_uart_agent%0d*", i), "cfg", cfg.m_uart_agent_cfgs[i]);
    end

    uvm_config_db#(top_chip_dv_env_cfg)::set(this, "", "cfg", cfg);
    uvm_config_db#(top_chip_dv_if_bundle)::set(this, "", "ifs", ifs);

    virtual_sequencer = top_chip_dv_virtual_sequencer::type_id::create("virtual_sequencer", this);
    virtual_sequencer.cfg = cfg;
    virtual_sequencer.ifs = ifs;
    virtual_sequencer.mem_bkdr_util_h = mem_bkdr_util_h;
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Track specific agent sequencers in the virtual sequencer.
    // Allows virtual sequences to use the agents to drive RX items.
    foreach (m_i2c_agents[i]) begin
      virtual_sequencer.i2c_sequencer_hs[i] = m_i2c_agents[i].sequencer;
    end
    virtual_sequencer.jtag_sequencer_hs = m_jtag_agent.sequencer;
    foreach (m_spi_device_agents[i]) begin
      virtual_sequencer.spi_device_sequencer_hs[i] = m_spi_device_agents[i].sequencer;
    end
    foreach (m_uart_agents[i]) begin
      virtual_sequencer.uart_sequencer_hs[i] = m_uart_agents[i].sequencer;
    end

    // Connect monitor outputs to matching FIFOs in the virtual sequencer.
    // Allows virtual sequences to check TX items.
    foreach (m_i2c_agents[i]) begin
      m_i2c_agents[i].monitor.controller_mode_rd_item_port.connect(virtual_sequencer.i2c_rd_fifos[i].analysis_export);
    end
    m_jtag_agent.monitor.analysis_port.connect(virtual_sequencer.jtag_rx_fifo.analysis_export);
    for (int i = 0; i < NUM_PATTGEN_CHANNELS; i++) begin
      m_pattgen_agent.monitor.item_port[i].connect(virtual_sequencer.pattgen_rx_fifo[i].analysis_export);
    end
    foreach (m_uart_agents[i]) begin
      m_uart_agents[i].monitor.tx_analysis_port.connect(virtual_sequencer.uart_tx_fifos[i].analysis_export);
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    load_memories();
  endtask

  task load_memories();
    foreach (cfg.mem_image_files[m]) begin
      if (cfg.mem_image_files[m] != "") begin
        `uvm_info(`gfn, $sformatf("Initializing memory %s with image %s", m.name(),
          cfg.mem_image_files[m]), UVM_LOW)

        mem_bkdr_util_h[m].load_mem_from_file(cfg.mem_image_files[m]);
      end
    end
  endtask
endclass
