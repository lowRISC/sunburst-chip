// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// This is the top level that connects the system to the virtual devices.
module top_chip_verilator (input logic clk_i, rst_ni);
  // Clock frequencies aren't really relevant in the current verilator simulation setup (everything
  // is running on one clock), this frequency is just needed for the uart DPI.
  localparam UartClockFrequency = 50_000_000;
  localparam BaudRate           = 921_600;

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

  logic        ibex_irq_software;
  logic        ibex_irq_timer;
  logic        ibex_irq_external;
  logic [14:0] ibex_irq_fast;
  logic        ibex_irq_nm;

  logic [31:0] gpio_intr;

  top_chip_system_pkg::aon_timer_intr_t aon_timer_intr;
  logic                                 aon_timer_nmi_wdog_timer_bark;

  logic rv_timer_intr;

  top_chip_system_pkg::i2c_intr_t i2c0_intr;
  top_chip_system_pkg::i2c_intr_t i2c1_intr;

  top_chip_system_pkg::pattgen_intr_t pattgen_intr;

  top_chip_system_pkg::spi_host_intr_t spi_host0_intr;
  top_chip_system_pkg::spi_host_intr_t spi_host1_intr;

  top_chip_system_pkg::uart_intr_t uart0_intr;
  top_chip_system_pkg::uart_intr_t uart1_intr;

  top_chip_system_pkg::usbdev_intr_t usbdev_intr;

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

    .ibex_irq_software_i(ibex_irq_software),
    .ibex_irq_timer_i   (ibex_irq_timer),
    .ibex_irq_external_i(ibex_irq_external),
    .ibex_irq_fast_i    (ibex_irq_fast),
    .ibex_irq_nm_i      (ibex_irq_nm),

    .gpio_intr_o(gpio_intr),

    .aon_timer_intr_o               (aon_timer_intr),
    .aon_timer_nmi_wdog_timer_bark_o(aon_timer_nmi_wdog_timer_bark),

    .rv_timer_intr_o(rv_timer_intr),

    .i2c0_intr_o(i2c0_intr),
    .i2c1_intr_o(i2c1_intr),

    .pattgen_intr_o(pattgen_intr),

    .spi_host0_intr_o(spi_host0_intr),
    .spi_host1_intr_o(spi_host1_intr),

    .uart0_intr_o(uart0_intr),
    .uart1_intr_o(uart1_intr),

    .usbdev_intr_o(usbdev_intr),

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

    .scanmode_i  (prim_mubi_pkg::MuBi4False),
    .ram_1p_cfg_i('0),
    .ram_2p_cfg_i('0),
    .rom_cfg_i   ('0)
  );

  intr_ctrl u_intr_ctrl (
    .clk_i (clk_sys),
    .rst_ni(rst_sys_n),

    .ibex_irq_software_o(ibex_irq_software),
    .ibex_irq_timer_o   (ibex_irq_timer),
    .ibex_irq_external_o(ibex_irq_external),
    .ibex_irq_fast_o    (ibex_irq_fast),
    .ibex_irq_nm_o      (ibex_irq_nm),

    .gpio_intr_i(gpio_intr),

    .aon_timer_intr_i               (aon_timer_intr),
    .aon_timer_nmi_wdog_timer_bark_i(aon_timer_nmi_wdog_timer_bark),

    .rv_timer_intr_i(rv_timer_intr),

    .i2c0_intr_i(i2c0_intr),
    .i2c1_intr_i(i2c1_intr),

    .pattgen_intr_i(pattgen_intr),

    .spi_host0_intr_i(spi_host0_intr),
    .spi_host1_intr_i(spi_host1_intr),

    .uart0_intr_i(uart0_intr),
    .uart1_intr_i(uart1_intr),

    .usbdev_intr_i(usbdev_intr)
  );

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
      end else if (gpio_pins == 32'hDEADBEEF) begin
        $display("TEST PASSED! Completion signal seen from software");
        finish_count <= 3'd1;
      end
    end
  end
endmodule
