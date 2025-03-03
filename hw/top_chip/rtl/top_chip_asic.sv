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

  // Dedicated Pads
  inout USB_P,
  inout USB_N
);
  localparam int NPads = 59;

  localparam int PadI2c0Sda = 32;
  localparam int PadI2c0Scl = 33;
  localparam int PadI2c1Sda = 34;
  localparam int PadI2c1Scl = 35;
  localparam int PadUsbP = 57;
  localparam int PadUsbN = 58;

  wire clk_sys, clk_peri, clk_usb, clk_aon;
  wire rst_sys_n, rst_peri_n, rst_usb_n, rst_aon_n;

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

    .usbdev_aon_wkup_req_o(),

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

  wire  [NPads-1:0] pad_io;

  logic [NPads-1:0] pad_out;
  logic [NPads-1:0] pad_oe;
  logic [NPads-1:0] pad_in;
  prim_pad_wrapper_pkg::pad_attr_t pad_attr [NPads];

  for (genvar i_pad=0;i_pad < NPads;i_pad++) begin : gen_drive_strength
    assign pad_attr[i_pad] = '{
      // `Strong` drive strength required for USB_P/USB_N to overpower the pullup.
      drive_strength: (i_pad == PadUsbP || i_pad == PadUsbN),
      // // Enable pull-ups for I^2C lines.
      // pull_en: (i_pad == PadI2c0Sda || i_pad == PadI2c0Scl ||
      //           i_pad == PadI2c1Sda || i_pad == PadI2c1Scl),
      // pull_select: 1,
      default: '0
    };
  end

  always_comb begin
    pad_out = '0;
    pad_oe = '0;

    // gpio
    cio_gpio_i    = pad_in[31:0];
    pad_out[31:0] = cio_gpio_o;
    pad_oe[31:0]  = cio_gpio_en_o;

    // i2c0
    cio_i2c0_sda_i = pad_in[32];
    pad_out[32] = cio_i2c0_sda_o;
    pad_oe[32]  = cio_i2c0_sda_en_o;

    cio_i2c0_scl_i = pad_in[33];
    pad_out[33] = cio_i2c0_scl_o;
    pad_oe[33]  = cio_i2c0_scl_en_o;

    // i2c1
    cio_i2c1_sda_i = pad_in[34];
    pad_out[34] = cio_i2c1_sda_o;
    pad_oe[34]  = cio_i2c1_sda_en_o;

    cio_i2c1_scl_i = pad_in[35];
    pad_out[35] = cio_i2c1_scl_o;
    pad_oe[35]  = cio_i2c1_scl_en_o;

    // spi0
    cio_spi_host0_sd_i = pad_in[39:36];
    pad_out[39:36] = cio_spi_host0_sd_o;
    pad_oe[39:36]  = cio_spi_host0_sd_en_o;

    pad_out[40]    = cio_spi_host0_sck_o;
    pad_oe[40]     = cio_spi_host0_sck_en_o;

    pad_out[41]    = cio_spi_host0_csb_o;
    pad_oe[41]     = cio_spi_host0_csb_en_o;

    // spi1
    cio_spi_host1_sd_i = pad_in[45:42];
    pad_out[45:42] = cio_spi_host1_sd_o;
    pad_oe[45:42]  = cio_spi_host1_sd_en_o;

    pad_out[46]    = cio_spi_host1_sck_o;
    pad_oe[46]     = cio_spi_host1_sck_en_o;

    pad_out[47]    = cio_spi_host1_csb_o;
    pad_oe[47]     = cio_spi_host1_csb_en_o;

    // uart0
    cio_uart0_rx_i = pad_in[48];

    pad_out[49] = cio_uart0_tx_o;
    pad_oe[49]  = cio_uart0_tx_en_o;

    // uart1
    cio_uart1_rx_i = pad_in[50];

    pad_out[51] = cio_uart1_tx_o;
    pad_oe[51]  = cio_uart1_tx_en_o;

    // pattgen
    pad_out[52] = cio_pattgen_pda0_tx_o;
    pad_oe[52]  = cio_pattgen_pda0_tx_en_o;

    pad_out[53] = cio_pattgen_pcl0_tx_o;
    pad_oe[53]  = cio_pattgen_pcl0_tx_en_o;

    pad_out[54] = cio_pattgen_pda1_tx_o;
    pad_oe[54]  = cio_pattgen_pda1_tx_en_o;

    pad_out[55] = cio_pattgen_pcl1_tx_o;
    pad_oe[55]  = cio_pattgen_pcl1_tx_en_o;

    // usbdev
    cio_usbdev_sense_i = pad_in[56];
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
