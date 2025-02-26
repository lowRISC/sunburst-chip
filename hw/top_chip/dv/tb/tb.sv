// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`include "uvm_macros.svh"
`include "dv_macros.svh"
`include "chip_hier_macros.svh"

module top_chip_asic_tb;
  import uvm_pkg::*;
  import top_chip_dv_test_pkg::*;
  import top_chip_dv_env_pkg::*;
  import mem_bkdr_util_pkg::mem_bkdr_util;
  import pattgen_agent_pkg::NUM_PATTGEN_CHANNELS;

  // ------ Signals ------

  // Dedicated pins.
  wire USB_P;
  wire USB_N;

  wire IO0;
  wire IO1;
  wire IO2;
  wire IO3;
  wire IO4;
  wire IO5;
  wire IO6;
  wire IO7;
  wire IO8;
  wire IO9;
  wire IO10;
  wire IO11;
  wire IO12;
  wire IO13;
  wire IO14;
  wire IO15;
  wire IO16;
  wire IO17;
  wire IO18;
  wire IO19;
  wire IO20;
  wire IO21;
  wire IO22;
  wire IO23;
  wire IO24;
  wire IO25;
  wire IO26;
  wire IO27;
  wire IO28;
  wire IO29;
  wire IO30;
  wire IO31;
  wire IO32;
  wire IO33;
  wire IO34;
  wire IO35;
  wire IO36;
  wire IO37;
  wire IO38;
  wire IO39;
  wire IO40;
  wire IO41;
  wire IO42;
  wire IO43;
  wire IO44;
  wire IO45;
  wire IO46;
  wire IO47;
  wire IO48;
  wire IO49;
  wire IO50;
  wire IO51;
  wire IO52;
  wire IO53;
  wire IO54;
  wire IO55;
  wire IO56;

  // ------ DUT ------

  top_chip_asic u_dut(
    .IO0,
    .IO1,
    .IO2,
    .IO3,
    .IO4,
    .IO5,
    .IO6,
    .IO7,
    .IO8,
    .IO9,
    .IO10,
    .IO11,
    .IO12,
    .IO13,
    .IO14,
    .IO15,
    .IO16,
    .IO17,
    .IO18,
    .IO19,
    .IO20,
    .IO21,
    .IO22,
    .IO23,
    .IO24,
    .IO25,
    .IO26,
    .IO27,
    .IO28,
    .IO29,
    .IO30,
    .IO31,
    .IO32,
    .IO33,
    .IO34,
    .IO35,
    .IO36,
    .IO37,
    .IO38,
    .IO39,
    .IO40,
    .IO41,
    .IO42,
    .IO43,
    .IO44,
    .IO45,
    .IO46,
    .IO47,
    .IO48,
    .IO49,
    .IO50,
    .IO51,
    .IO52,
    .IO53,
    .IO54,
    .IO55,
    .IO56,

    .USB_P,
    .USB_N
  );

  // ------ DV Interfaces ------

  clk_rst_if sys_clk_if(.clk(u_dut.clk_sys), .rst_n(u_dut.rst_sys_n));
  clk_rst_if peri_clk_if(.clk(u_dut.clk_peri), .rst_n(u_dut.rst_peri_n));
  clk_rst_if usb_clk_if(.clk(u_dut.clk_usb), .rst_n(u_dut.rst_usb_n));
  clk_rst_if aon_clk_if(.clk(u_dut.clk_aon), .rst_n(u_dut.rst_aon_n));

  pins_if#(NGpioPins) gpio_pins_if({
    IO31,
    IO30,
    IO29,
    IO28,
    IO27,
    IO26,
    IO25,
    IO24,
    IO23,
    IO22,
    IO21,
    IO20,
    IO19,
    IO18,
    IO17,
    IO16,
    IO15,
    IO14,
    IO13,
    IO12,
    IO11,
    IO10,
    IO9,
    IO8,
    IO7,
    IO6,
    IO5,
    IO4,
    IO3,
    IO2,
    IO1,
    IO0
  });

  // Create and connect I^2C agent interfaces.
  // Need to use port connections due to bidirectionality
  i2c_if i2c_if[NI2cs](
    .clk_i(peri_clk_if.clk),    // shared with all instances
    .rst_ni(peri_clk_if.rst_n), // shared with all instances
    .sda_io({IO34, IO32})  // {i2c1, i2c0}
    .scl_io({IO35, IO33}), // {i2c1, i2c0}
  );

  // Create and connect pattgen agent interface
  pattgen_if#(NUM_PATTGEN_CHANNELS) pattgen_if();
  assign pattgen_if.clk_i  = peri_clk_if.clk; // u_dut.u_top_chip_system.u_pattgen.clk_i
  assign pattgen_if.rst_ni = peri_clk_if.rst_n; // u_dut.u_top_chip_system.u_pattgen.rst_ni
  assign pattgen_if.pda_tx = {IO54, IO52}; // {CH1, CH0}
  assign pattgen_if.pcl_tx = {IO55, IO53}; // {CH1, CH0}

  // Create and connect SPI agent interfaces.
  // Full-duplex usage { N/A,   N/A,  CIPO,  COPI }
  // Quad SPI usage    {bidir, bidir, bidir, bidir}
  spi_if spi_device_if[NSpis](
    .rst_n(peri_clk_if.rst_n) // shared with all instances
    .sio({{IO45, IO44, IO43, IO42}, {IO39, IO38, IO37, IO36}}) // {{spi1} {spi0}}
  );
  assign spi_device_if[0].sck = IO40;
  assign spi_device_if[0].csb = IO41;
  assign spi_device_if[1].sck = IO46;
  assign spi_device_if[1].csb = IO47;

  // Create and connect uart agent interfaces. Mux UART0 as it is shared with a DPI model,
  // using the vif enable signal that can be poked by the virtual sequence.
  // Might as well leave UART1 connected all the time.
  uart_if uart_if[NUarts]();
  logic uart0_rx_dpi;
  assign IO48 = uart_if[0].enable ? uart_if[0].uart_rx : uart0_rx_dpi;
  assign uart_if[0].uart_tx = uart_if[0].enable ? IO49 : 1'bz;
  assign IO50 = uart_if[1].uart_rx;
  assign uart_if[1].uart_tx = IO51;

  // ------ Memory ------

  if (`PRIM_DEFAULT_IMPL == prim_pkg::ImplGeneric) begin : gen_generic
    initial begin
      chip_mem_e    mem;
      mem_bkdr_util m_mem_bkdr_util[chip_mem_e];
      mem_clear_util cap_sram_clear;

      m_mem_bkdr_util[ChipMemSRAM] = new(
        .name ("mem_bkdr_util[ChipMemSRAM]"),
        .path (`DV_STRINGIFY(`SRAM_MEM_HIER)),
        .depth ($size(`SRAM_MEM_HIER)),
        .n_bits($bits(`SRAM_MEM_HIER)),
        .err_detection_scheme(mem_bkdr_util_pkg::ErrDetectionNone),
        .system_base_addr    (tl_main_pkg::ADDR_SPACE_SRAM));
      // Zero-initialising the SRAM ensures valid BSS.
      m_mem_bkdr_util[ChipMemSRAM].clear_mem();
      `MEM_BKDR_UTIL_FILE_OP(m_mem_bkdr_util[ChipMemSRAM], `SRAM_MEM_HIER)

      // Zero-initialise the SRAM Capability tags, otherwise TL-UL FIFO assertions will fire;
      // mem_bkdr_util does not handle the geometry of this memory.
      cap_sram_clear = new(
        .name ("cap_sram_clear"),
        .path (`DV_STRINGIFY(`SRAM_CAP_MEM_HIER)),
        .depth ($size(`SRAM_CAP_MEM_HIER)),
        .n_bits ($bits(`SRAM_CAP_MEM_HIER)));
      cap_sram_clear.clear_mem();

      m_mem_bkdr_util[ChipMemROM] = new(
        .name ("mem_bkdr_util[ChipMemROM]"),
        .path (`DV_STRINGIFY(`ROM_MEM_HIER)),
        .depth ($size(`ROM_MEM_HIER)),
        .n_bits($bits(`ROM_MEM_HIER)),
        .err_detection_scheme(mem_bkdr_util_pkg::ErrDetectionNone),
        .system_base_addr    (tl_main_pkg::ADDR_SPACE_ROM));
      `MEM_BKDR_UTIL_FILE_OP(m_mem_bkdr_util[ChipMemROM], `ROM_MEM_HIER)

      `uvm_info("tb.sv", "Creating mem_bkdr_util instance for USBDEV BUFFER", UVM_MEDIUM)
      m_mem_bkdr_util[ChipMemUsbdevBuf] = new(
        .name  ("mem_bkdr_util[ChipMemUsbdevBuf]"),
        .path  (`DV_STRINGIFY(`USBDEV_BUF_HIER)),
        .depth ($size(`USBDEV_BUF_HIER)),
        .n_bits($bits(`USBDEV_BUF_HIER)),
        .err_detection_scheme(mem_bkdr_util_pkg::ErrDetectionNone));
      m_mem_bkdr_util[ChipMemUsbdevBuf].clear_mem();

      mem = mem.first();
      do begin
        uvm_config_db#(mem_bkdr_util)::set(
            null, "*.env", m_mem_bkdr_util[mem].get_name(), m_mem_bkdr_util[mem]);
        mem = mem.next();
      end while (mem != mem.first());
    end
  end : gen_generic

  // Instantiate simulator SRAM for SW DV special writes
  // TODO: Connect the sim_sram to a window in ibex core wrapper register
  // interface (when it exists) instead of hijacking write to the ROM.
  sim_sram u_sim_sram (
    .clk_i    (u_dut.clk_sys),
    .rst_ni   (u_dut.rst_sys_n),
    .tl_in_i  (u_dut.u_top_chip_system.u_rom.tl_i),
    .tl_in_o  (),
    .tl_out_o (),
    .tl_out_i ()
  );

  `define SIM_SRAM_IF u_sim_sram.u_sim_sram_if

  // Bind the SW test status interface directly to the sim SRAM interface.
  bind `SIM_SRAM_IF sw_test_status_if u_sw_test_status_if (
    .addr     (tl_h2d.a_address),
    .data     (tl_h2d.a_data[15:0]),
    .fetch_en (1'b0), // use constant, as there is no pwrmgr-provided CPU fetch enable signal
    .*
  );

  // Bind the SW logger interface directly to the sim SRAM interface.
  bind `SIM_SRAM_IF sw_logger_if u_sw_logger_if (
    .addr (tl_h2d.a_address),
    .data (tl_h2d.a_data),
    .*
  );

  // ------ Initialisation ------

  initial begin
    // Set base of SW DV special write locations
    `SIM_SRAM_IF.start_addr = SW_DV_START_ADDR;
    `SIM_SRAM_IF.u_sw_test_status_if.sw_test_status_addr = SW_DV_TEST_STATUS_ADDR;
    `SIM_SRAM_IF.u_sw_logger_if.sw_log_addr = SW_DV_LOG_ADDR;

    sys_clk_if.set_active(1'b0, 1'b0);
    peri_clk_if.set_active(1'b0, 1'b0);
    usb_clk_if.set_active(1'b0, 1'b0);
    aon_clk_if.set_active(1'b0, 1'b0);

    // Since there is no contention for the USB SENSE pin presently, always enable the USB DPI model
    u_usb20_if.enable_driver(1'b1);

    uvm_config_db#(virtual clk_rst_if)::set(null, "*", "sys_clk_if", sys_clk_if);
    uvm_config_db#(virtual clk_rst_if)::set(null, "*", "peri_clk_if", peri_clk_if);
    uvm_config_db#(virtual clk_rst_if)::set(null, "*", "usb_clk_if", usb_clk_if);
    uvm_config_db#(virtual clk_rst_if)::set(null, "*", "aon_clk_if", aon_clk_if);

        // SW logger and test status interfaces.
    uvm_config_db#(virtual sw_test_status_if)::set(
        null, "*.env", "sw_test_status_vif", `SIM_SRAM_IF.u_sw_test_status_if);
    uvm_config_db#(virtual sw_logger_if)::set(
        null, "*.env", "sw_logger_vif", `SIM_SRAM_IF.u_sw_logger_if);

    // Feed certain I/O signals to matching agents for vseq-specific driving/checking
    uvm_config_db#(virtual pins_if#(NGpioPins))::set(null, "*", "gpio_pins_vif", gpio_pins_if);
    uvm_config_db#(virtual pattgen_if)::set(null, "*.env.m_pattgen_agent*", "vif", pattgen_if);

    run_test();
  end

  for (genvar i = 0; i < NI2cs; i++) begin : gen_i2c_if_set
    initial begin
      uvm_config_db#(virtual i2c_if)::set(null, $sformatf("*.env.m_i2c_agent%0d*", i), "vif", i2c_if[i]);
    end
  end : gen_i2c_if_set

  for (genvar i = 0; i < NSpis; i++) begin : gen_spi_if_set
    initial begin
      uvm_config_db#(virtual spi_if)::set(null, $sformatf("*.env.m_spi_device_agents%0d*", i), "vif", spi_device_if[i]);
    end
  end : gen_spi_if_set

  for (genvar i = 0; i < NUarts; i++) begin : gen_uart_if_set
    initial begin
      uvm_config_db#(virtual uart_if)::set(null, $sformatf("*.env.m_uart_agent%0d*", i), "vif", uart_if[i]);
    end
  end : gen_uart_if_set

  // ------ DPI Models ------

  uartdpi #(
    .BAUD(UartDpiBaud),
    .FREQ(top_chip_system_pkg::PeriClkFreq)
  ) u_uartdpi0 (
    .clk_i(u_dut.clk_peri),
    .rst_ni(u_dut.rst_peri_n),
    .active(!uart_if[0].enable),
    .tx_o(uart0_rx_dpi),
    .rx_i(!uart_if[0].enable ? IO49 : 1'bz)
  );

  // The USB DPI model (simulated host controller) has its own clock and reset signal,
  // since it is asynchronous with the USB device and there is no clock transmission over the USB.
  //
  // TODO: use a clk_rst_if here instead?
  logic clk_usbdpi;
  logic rst_usbdpi_n;

  clk_osc #(.ClkFreq(top_chip_system_pkg::UsbClkFreq)) u_usbdpi_clk_osc (
    .clk_en(1'b1),
    .clk_o(clk_usbdpi)
  );

  rst_gen u_usbdpi_rst_gen (
    .rst_o(rst_usbdpi_n)
  );

  // Interface presently just permits the DPI model to be easily connected and
  // disconnected as required, since the pin count is limited and some deployments
  // may not require USB.
  usb20_if u_usb20_if (
    .clk_i            (clk_usbdpi),
    .rst_ni           (rst_usbdpi_n),

    .usb_vbus         (IO56),
    .usb_p            (USB_P),
    .usb_n            (USB_N)
  );

  // Instantiate & connect the USB DPI model for top-level testing.
  usb20_usbdpi u_usb20_usbdpi (
    .clk_i            (clk_usbdpi),
    .rst_ni           (rst_usbdpi_n),

    .enable           (1'b1),

    // Outputs from the DPI module
    .usb_sense_p2d_o  (u_usb20_if.usb_sense_p2d),
    .usb_dp_en_p2d_o  (u_usb20_if.usb_dp_en_p2d),
    .usb_dn_en_p2d_o  (u_usb20_if.usb_dn_en_p2d),
    .usb_dp_p2d_o     (u_usb20_if.usb_dp_p2d),
    .usb_dn_p2d_o     (u_usb20_if.usb_dn_p2d),

    .usb_p            (USB_P),
    .usb_n            (USB_N)
  );
  endmodule
