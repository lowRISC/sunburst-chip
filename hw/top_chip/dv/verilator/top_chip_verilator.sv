// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// This is the top level that connects the system to the virtual devices.
module top_chip_verilator (input logic clk_i, rst_ni);
  // Clock frequencies aren't really relevant in the current verilator simulation setup (everything
  // is running on one clock), this frequency is just needed for the uart DPI.
  localparam UartClockFrequency = 50_000_000;
  localparam BaudRate           = 1_500_000;

  logic clk_sys, clk_peri, clk_usb, clk_aon;
  logic rst_sys_n, rst_peri_n, rst_usb_n, rst_aon_n;

  // All resets and clocks identical for simplicity in the verilator testbench
  assign clk_sys  = clk_i;
  assign clk_peri = clk_i;
  assign clk_usb  = clk_i;
  assign clk_aon  = clk_i;

  assign rst_sys_n  = rst_ni;
  assign rst_peri_n = rst_ni;
  assign rst_usb_n  = rst_ni;
  assign rst_aon_n  = rst_ni;

  logic uart_sys_tx, uart_sys_tx_raw, uart_sys_tx_en, uart_sys_rx;

  // USBDEV
  logic cio_usbdev_sense_i;
  logic cio_usbdev_usb_dp_i;
  logic cio_usbdev_usb_dn_i;
  logic cio_usbdev_rx_d_i;
  logic cio_usbdev_usb_dp_o;
  logic cio_usbdev_usb_dp_en_o;
  logic cio_usbdev_usb_dn_o;
  logic cio_usbdev_usb_dn_en_o;
  logic cio_usbdev_tx_d_o;
  logic cio_usbdev_tx_se0_o;
  logic cio_usbdev_tx_use_d_se0_o;
  logic cio_usbdev_dp_pullup_o;
  logic cio_usbdev_dn_pullup_o;
  logic cio_usbdev_rx_enable_o;

  logic [31:0] gpio_pins;

  logic [31:0] cio_gpio_o;
  logic [31:0] cio_gpio_en_o;
  assign gpio_pins = cio_gpio_o & cio_gpio_en_o;

  top_chip_system u_top_chip_system (
    .clk_sys_i (clk_sys),
    .clk_peri_i(clk_peri),
    .clk_usb_i (clk_usb),
    .clk_aon_i (clk_aon),

    .rst_sys_ni (rst_sys_n),
    .rst_peri_ni(rst_peri_n),
    .rst_usb_ni (rst_usb_n),
    .rst_aon_ni (rst_aon_n),

    .cio_gpio_i   ('0),
    .cio_gpio_o   (cio_gpio_o),
    .cio_gpio_en_o(cio_gpio_en_o),

    .cio_i2c0_sda_i   ('0),
    .cio_i2c0_scl_i   ('0),
    .cio_i2c0_sda_o   (),
    .cio_i2c0_sda_en_o(),
    .cio_i2c0_scl_o   (),
    .cio_i2c0_scl_en_o(),

    .cio_i2c1_sda_i   ('0),
    .cio_i2c1_scl_i   ('0),
    .cio_i2c1_sda_o   (),
    .cio_i2c1_sda_en_o(),
    .cio_i2c1_scl_o   (),
    .cio_i2c1_scl_en_o(),

    .cio_jtag_tck_i   ('0),
    .cio_jtag_tms_i   ('0),
    .cio_jtag_trst_ni ('0),
    .cio_jtag_td_i    ('0),
    .cio_jtag_td_o    (),

    .cio_pattgen_pda0_tx_o    (),
    .cio_pattgen_pda0_tx_en_o (),
    .cio_pattgen_pcl0_tx_o    (),
    .cio_pattgen_pcl0_tx_en_o (),
    .cio_pattgen_pda1_tx_o    (),
    .cio_pattgen_pda1_tx_en_o (),
    .cio_pattgen_pcl1_tx_o    (),
    .cio_pattgen_pcl1_tx_en_o (),

    .cio_pwm_o        (),
    .cio_pwm_en_o     (),

    .cio_spi_host0_sd_i    ('0),
    .cio_spi_host0_sck_o   (),
    .cio_spi_host0_sck_en_o(),
    .cio_spi_host0_csb_o   (),
    .cio_spi_host0_csb_en_o(),
    .cio_spi_host0_sd_o    (),
    .cio_spi_host0_sd_en_o (),

    .cio_spi_host1_sd_i    (),
    .cio_spi_host1_sck_o   (),
    .cio_spi_host1_sck_en_o(),
    .cio_spi_host1_csb_o   (),
    .cio_spi_host1_csb_en_o(),
    .cio_spi_host1_sd_o    (),
    .cio_spi_host1_sd_en_o (),

    .cio_uart0_rx_i   (uart_sys_rx),
    .cio_uart0_tx_o   (uart_sys_tx_raw),
    .cio_uart0_tx_en_o(uart_sys_tx_en),

    .cio_uart1_rx_i   ('0),
    .cio_uart1_tx_o   (),
    .cio_uart1_tx_en_o(),

    .cio_usbdev_sense_i,
    .cio_usbdev_usb_dp_i,
    .cio_usbdev_usb_dn_i,
    .cio_usbdev_rx_d_i,
    .cio_usbdev_usb_dp_o,
    .cio_usbdev_usb_dp_en_o,
    .cio_usbdev_usb_dn_o,
    .cio_usbdev_usb_dn_en_o,
    .cio_usbdev_tx_d_o,
    .cio_usbdev_tx_se0_o,
    .cio_usbdev_tx_use_d_se0_o,
    .cio_usbdev_dp_pullup_o,
    .cio_usbdev_dn_pullup_o,
    .cio_usbdev_rx_enable_o,

    .aon_timer_wkup_req_o(),
    .aon_timer_rst_req_o (),

    .usbdev_aon_wkup_req_o(),

    .scanmode_i  (prim_mubi_pkg::MuBi4False),
    .ram_1p_cfg_i('0),
    .ram_2p_cfg_i('0),
    .rom_cfg_i   ('0)
  );

  `define CORE_IBEX u_top_chip_system.u_core_ibex
  `define SIM_SRAM_IF u_sim_sram.u_sim_sram_if

  // Instantiate simulator SRAM for SW DV special writes
  sim_sram u_sim_sram (
    .clk_i    (clk_sys),
    .rst_ni   (rst_sys_n),
    .tl_in_i  (tlul_pkg::tl_h2d_t'(`CORE_IBEX.u_tlul_req_buf.out_o)),
    .tl_in_o  (),
    .tl_out_o (),
    .tl_out_i ()
  );

  // Connect the sim SRAM directly inside rv_core_ibex.
  assign `CORE_IBEX.cfg_tl_d_o = u_sim_sram.tl_in_o;

  // Connect the SW test status interface to the sim SRAM interface.
  sw_test_status_if u_sw_test_status_if (
    .clk_i    (`SIM_SRAM_IF.clk_i),
    .rst_ni   (`SIM_SRAM_IF.rst_ni),
    .fetch_en (1'b0),
    .wr_valid (`SIM_SRAM_IF.wr_valid),
    .addr     (`SIM_SRAM_IF.tl_h2d.a_address),
    .data     (`SIM_SRAM_IF.tl_h2d.a_data[15:0])
  );

  // Set the start address of the simulation SRAM.
  // Use offset 0 within the sim SRAM for SW test status indication.
  initial begin
    `SIM_SRAM_IF.start_addr = `VERILATOR_TEST_STATUS_ADDR;
    u_sw_test_status_if.sw_test_status_addr = `SIM_SRAM_IF.start_addr;
  end

  assign uart_sys_tx = uart_sys_tx_raw & uart_sys_tx_en;

  // Virtual UART
  uartdpi #(
    .BAUD(BaudRate),
    .FREQ(UartClockFrequency)
  ) u_uartdpi (
    .clk_i,
    .rst_ni,
    .active(1'b1       ),
    .tx_o  (uart_sys_rx),
    .rx_i  (uart_sys_tx)
  );

  // DPI model of USB host controller.
  usbdpi u_usbdpi (
    .clk_i           (clk_usb),
    .rst_ni          (rst_usb_n),
    .clk_48MHz_i     (clk_usb),
    .enable          (1'b1),
    .dp_en_p2d       (),
    .dp_p2d          (cio_usbdev_usb_dp_i),
    .dp_d2p          (cio_usbdev_usb_dp_o),
    .dp_en_d2p       (cio_usbdev_usb_dp_en_o),
    .dn_en_p2d       (),
    .dn_p2d          (cio_usbdev_usb_dn_i),
    .dn_d2p          (cio_usbdev_usb_dn_o),
    .dn_en_d2p       (cio_usbdev_usb_dn_en_o),
    .d_p2d           (cio_usbdev_rx_d_i),
    .d_d2p           (cio_usbdev_tx_d_o),
    .d_en_d2p        (cio_usbdev_usb_dp_en_o),
    .se0_d2p         (cio_usbdev_tx_se0_o),
    .rx_enable_d2p   (cio_usbdev_rx_enable_o),
    .tx_use_d_se0_d2p(cio_usbdev_tx_use_d_se0_o),

    .sense_p2d       (cio_usbdev_sense_i),
    .pullupdp_d2p    (cio_usbdev_dp_pullup_o),
    .pullupdn_d2p    (cio_usbdev_dn_pullup_o)
  );

  logic [2:0] finish_count;

  always @(posedge clk_sys or negedge rst_sys_n) begin
    if (!rst_sys_n) begin
      finish_count <= '0;
    end else begin
      if (finish_count == 3'd7) begin
        $finish();
      end else if (finish_count > 3'd0) begin
        finish_count <= finish_count + 3'd1;
      end else if (u_sw_test_status_if.sw_test_done) begin
        // Test status interface completion signal.
        // u_sw_test_status_if will output pass/fail message.
        finish_count <= 3'd1;
      end else if (gpio_pins == 32'hDEADBEEF) begin
        // Legacy test completion signal
        $display("TEST PASSED! Completion signal seen from software");
        finish_count <= 3'd1;
      end
    end
  end
endmodule
