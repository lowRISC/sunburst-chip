// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module top_chip_asic (
  inout IO0,
  inout IO1,
  inout IO2,
  inout IO3,
  inout IO4,
  inout IO5,
  inout IO6,
  inout IO7,
  inout IO8,
  inout IO9,
  inout IO10,
  inout IO11,
  inout IO12,
  inout IO13,
  inout IO14,
  inout IO15,
  inout IO16,
  inout IO17,
  inout IO18,
  inout IO19,
  inout IO20,
  inout IO21,
  inout IO22,
  inout IO23,
  inout IO24,
  inout IO25,
  inout IO26,
  inout IO27,
  inout IO28,
  inout IO29,
  inout IO30,
  inout IO31,
  inout IO32,
  inout IO33,
  inout IO34,
  inout IO35,
  inout IO36,
  inout IO37,
  inout IO38,
  inout IO39,
  inout IO40,
  inout IO41,
  inout IO42,
  inout IO43,
  inout IO44,
  inout IO45,
  inout IO46,
  inout IO47,
  inout IO48,
  inout IO49,
  inout IO50,
  inout IO51,
  inout IO52,
  inout IO53,
  inout IO54,
  inout IO55,
  inout IO56,
  inout IO57,
  inout IO58,
  inout IO59,
  inout IO60,
  inout IO61,
  inout IO62,
  inout IO63,

  // Dedicated Pads
  inout USB_P,
  inout USB_N
);
  localparam int NPads = 66;

  localparam int PadUsbP = 64;
  localparam int PadUsbN = 65;

  wire clk_sys, clk_peri, clk_usb, clk_aon;
  wire rst_sys_n, rst_peri_n, rst_usb_n, rst_aon_n;


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

  // GPIO
  logic [31:0] cio_gpio_i;
  logic [31:0] cio_gpio_o;
  logic [31:0] cio_gpio_en_o;
  // I2C 0
  logic cio_i2c0_sda_i;
  logic cio_i2c0_scl_i;
  logic cio_i2c0_sda_o;
  logic cio_i2c0_sda_en_o;
  logic cio_i2c0_scl_o;
  logic cio_i2c0_scl_en_o;

  // I2C 1
  logic cio_i2c1_sda_i;
  logic cio_i2c1_scl_i;
  logic cio_i2c1_sda_o;
  logic cio_i2c1_sda_en_o;
  logic cio_i2c1_scl_o;
  logic cio_i2c1_scl_en_o;

  // Pattgen
  logic cio_pattgen_pda0_tx_o;
  logic cio_pattgen_pda0_tx_en_o;
  logic cio_pattgen_pcl0_tx_o;
  logic cio_pattgen_pcl0_tx_en_o;
  logic cio_pattgen_pda1_tx_o;
  logic cio_pattgen_pda1_tx_en_o;
  logic cio_pattgen_pcl1_tx_o;
  logic cio_pattgen_pcl1_tx_en_o;

  // PWM
  logic [5:0] cio_pwm_o;
  logic [5:0] cio_pwm_en_o;

  // SPI Host 0
  logic [3:0] cio_spi_host0_sd_i;
  logic       cio_spi_host0_sck_o;
  logic       cio_spi_host0_sck_en_o;
  logic       cio_spi_host0_csb_o;
  logic       cio_spi_host0_csb_en_o;
  logic [3:0] cio_spi_host0_sd_o;
  logic [3:0] cio_spi_host0_sd_en_o;

  // SPI Host 1
  logic [3:0] cio_spi_host1_sd_i;
  logic       cio_spi_host1_sck_o;
  logic       cio_spi_host1_sck_en_o;
  logic       cio_spi_host1_csb_o;
  logic       cio_spi_host1_csb_en_o;
  logic [3:0] cio_spi_host1_sd_o;
  logic [3:0] cio_spi_host1_sd_en_o;

  // UART 0
  logic cio_uart0_rx_i;
  logic cio_uart0_tx_o;
  logic cio_uart0_tx_en_o;

  // UART 1
  logic cio_uart1_rx_i;
  logic cio_uart1_tx_o;
  logic cio_uart1_tx_en_o;

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

  clk_rst_gen u_clk_rst_gen (
    .clk_sys_o (clk_sys),
    .clk_peri_o(clk_peri),
    .clk_usb_o (clk_usb),
    .clk_aon_o (clk_aon),

    .rst_sys_n (rst_sys_n),
    .rst_peri_n(rst_peri_n),
    .rst_usb_n (rst_usb_n),
    .rst_aon_n (rst_aon_n)
  );

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

    .cio_gpio_i,
    .cio_gpio_o,
    .cio_gpio_en_o,

    .cio_i2c0_sda_i,
    .cio_i2c0_scl_i,
    .cio_i2c0_sda_o,
    .cio_i2c0_sda_en_o,
    .cio_i2c0_scl_o,
    .cio_i2c0_scl_en_o,

    .cio_i2c1_sda_i,
    .cio_i2c1_scl_i,
    .cio_i2c1_sda_o,
    .cio_i2c1_sda_en_o,
    .cio_i2c1_scl_o,
    .cio_i2c1_scl_en_o,

    .cio_pwm_o,
    .cio_pwm_en_o,

    .cio_pattgen_pda0_tx_o,
    .cio_pattgen_pda0_tx_en_o,
    .cio_pattgen_pcl0_tx_o,
    .cio_pattgen_pcl0_tx_en_o,
    .cio_pattgen_pda1_tx_o,
    .cio_pattgen_pda1_tx_en_o,
    .cio_pattgen_pcl1_tx_o,
    .cio_pattgen_pcl1_tx_en_o,

    .cio_spi_host0_sd_i,
    .cio_spi_host0_sck_o,
    .cio_spi_host0_sck_en_o,
    .cio_spi_host0_csb_o,
    .cio_spi_host0_csb_en_o,
    .cio_spi_host0_sd_o,
    .cio_spi_host0_sd_en_o,

    .cio_spi_host1_sd_i,
    .cio_spi_host1_sck_o,
    .cio_spi_host1_sck_en_o,
    .cio_spi_host1_csb_o,
    .cio_spi_host1_csb_en_o,
    .cio_spi_host1_sd_o,
    .cio_spi_host1_sd_en_o,

    .cio_uart0_rx_i,
    .cio_uart0_tx_o,
    .cio_uart0_tx_en_o,

    .cio_uart1_rx_i,
    .cio_uart1_tx_o,
    .cio_uart1_tx_en_o,

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

  // Differential receiver for USB device; this is required for compliance with the
  // Universal Bus Specification 2.0.
  //
  // The internal logic permits synchronisation with the host controller across a portion of the
  // required frequency range. On FPGA board implementations an external USB transceiver usually
  // performs this function.

  // Calibration and power inputs presently unavailable.
  wire core_pok_h = 1'b0;
  wire [31:0] usb_io_pu_cal = '0;
  // Observability output presently not required.
  logic usb_diff_rx_osb;

  // Note: this differential receiver also applies pullup resistors to the USB DP/DN line(s) to
  //       signal device presence and communication speed to the USB host controller.
  prim_usb_diff_rx #(
    .CalibW(32)
  ) u_prim_usb_diff_rx (
    .input_pi          ( USB_P                  ),
    .input_ni          ( USB_N                  ),
    .input_en_i        ( cio_usbdev_rx_enable_o ),
    .core_pok_h_i      ( core_pok_h             ),
    .pullup_p_en_i     ( cio_usbdev_dp_pullup_o ),
    .pullup_n_en_i     ( cio_usbdev_dn_pullup_o ),
    .calibration_i     ( usb_io_pu_cal          ),
    .usb_diff_rx_obs_o ( usb_diff_rx_obs        ),
    .input_o           ( cio_usbdev_rx_d_i      )
  );

  // Direct differential inputs to the USB device; these are required to detect 'SE0' signalling
  // (e.g. Bus Reset or End Of Packet) even when the above differential receiver is enabled.
  assign cio_usbdev_usb_dp_i = USB_P;
  assign cio_usbdev_usb_dn_i = USB_N;

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

  wire  [NPads-1:0] pad_io;

  logic [NPads-1:0] pad_out;
  logic [NPads-1:0] pad_oe;
  logic [NPads-1:0] pad_in;
  prim_pad_wrapper_pkg::pad_attr_t pad_attr [NPads];

  for (genvar i_pad=0;i_pad < NPads;i_pad++) begin : gen_drive_strength
    // `Strong` drive strength required for USB_P/USB_N to overpower the pullup.
    assign pad_attr[i_pad] = '{drive_strength: (i_pad == PadUsbP || i_pad == PadUsbN), default: '0};
  end

  always_comb begin
    pad_out = '0;
    pad_oe = '0;

    cio_gpio_i    = pad_in[31:0];
    pad_out[31:0] = cio_gpio_o;
    pad_oe[31:0]  = cio_gpio_en_o;

    cio_i2c0_sda_i = pad_in[32];
    cio_i2c0_scl_i = pad_in[33];

    pad_out[34] = cio_i2c0_sda_o;
    pad_oe[34]  = cio_i2c0_sda_en_o;
    pad_out[35] = cio_i2c0_scl_o;
    pad_oe[35]  = cio_i2c0_scl_en_o;

    cio_i2c1_sda_i = pad_in[36];
    cio_i2c1_scl_i = pad_in[37];

    pad_out[38] = cio_i2c1_sda_o;
    pad_oe[38]  = cio_i2c1_sda_en_o;
    pad_out[39] = cio_i2c1_scl_o;
    pad_oe[39]  = cio_i2c1_scl_en_o;

    cio_spi_host0_sd_i = pad_in[42:39];

    pad_out[43]    = cio_spi_host0_sck_o;
    pad_oe[43]     = cio_spi_host0_sck_en_o;
    pad_out[44]    = cio_spi_host0_csb_o;
    pad_oe[44]     = cio_spi_host0_csb_en_o;
    pad_out[48:45] = cio_spi_host0_sd_o;
    pad_oe[48:45]  = cio_spi_host0_sd_en_o;

    cio_spi_host1_sd_i = pad_in[52:49];

    pad_out[53]    = cio_spi_host1_sck_o;
    pad_oe[53]     = cio_spi_host1_sck_en_o;
    pad_out[54]    = cio_spi_host1_csb_o;
    pad_oe[54]     = cio_spi_host1_csb_en_o;
    pad_out[58:55] = cio_spi_host1_sd_o;
    pad_oe[58:55]  = cio_spi_host1_sd_en_o;

    cio_uart0_rx_i = pad_in[59];
    pad_out[60] = cio_uart0_tx_o;
    pad_oe[60]  = cio_uart0_tx_en_o;

    cio_uart1_rx_i = pad_in[61];
    pad_out[62] = cio_uart1_tx_o;
    pad_oe[62]  = cio_uart1_tx_en_o;

    cio_usbdev_sense_i = pad_in[63];
    // no output driver required.

    // USB_P/N may require special treatment beyond the drive strength.
    pad_out[PadUsbP] = cio_usbdev_usb_dp_o;
    pad_oe[PadUsbP]  = cio_usbdev_usb_dp_en_o;
    pad_out[PadUsbN] = cio_usbdev_usb_dn_o;
    pad_oe[PadUsbN]  = cio_usbdev_usb_dn_en_o;
  end

  padring #(.NPads(NPads)) u_padring (
    .clk_scan_i(1'b0),
    .scanmode_i(prim_mubi_pkg::MuBi4False),

    .pad_io ({
      // Dedicated pads.
      USB_N,
      USB_P,

      IO63,
      IO62,
      IO61,
      IO60,
      IO59,
      IO58,
      IO57,
      IO56,
      IO55,
      IO54,
      IO53,
      IO52,
      IO51,
      IO50,
      IO49,
      IO48,
      IO47,
      IO46,
      IO45,
      IO44,
      IO43,
      IO42,
      IO41,
      IO40,
      IO39,
      IO38,
      IO37,
      IO36,
      IO35,
      IO34,
      IO33,
      IO32,
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
    }),

    .pad_out_i (pad_out),
    .pad_oe_i  (pad_oe),
    .pad_in_o  (pad_in),
    .pad_attr_i(pad_attr)
  );
endmodule
