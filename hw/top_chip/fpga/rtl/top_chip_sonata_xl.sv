// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Sonata system top level for the Sonata PCB
module top_chip_sonata_xl
  import top_chip_sonata_xl_pkg::*;
(
  input  logic mainClk, // board clock
  input  logic nrst, // on-board reset button

  // LEDs
  output logic usrLed0,
  output logic usrLed1,
  output logic usrLed2,
  output logic usrLed3,
  output logic usrLed4,
  output logic usrLed5,
  output logic usrLed6,
  output logic usrLed7,
  output logic led_bootok,
  output logic led_halted,
  output logic led_cheri,
  output logic led_legacy,
  output logic cheriErr0,
  output logic cheriErr1,
  output logic cheriErr2,
  output logic cheriErr3,
  output logic cheriErr4,
  output logic cheriErr5,
  output logic cheriErr6,
  output logic cheriErr7,
  output logic cheriErr8,

  // Joystick
  input  logic navSw_0,
  input  logic navSw_1,
  input  logic navSw_2,
  input  logic navSw_3,
  input  logic navSw_4,
  // DIP switches
  input  logic usrSw0,
  input  logic usrSw1,
  input  logic usrSw2,
  input  logic usrSw3,
  input  logic usrSw4,
  input  logic usrSw5,
  input  logic usrSw6,
  input  logic usrSw7,
  // SW App selector switch
  input  logic selSw0,
  input  logic selSw1,
  input  logic selSw2,

  output logic lcd_rst,
  output logic lcd_dc,
  output logic lcd_copi,
  output logic lcd_clk,
  output logic lcd_cs,
  output logic lcd_backlight,

  output logic ethmac_rst,
  output logic ethmac_copi,
  output logic ethmac_sclk,
  input  logic ethmac_cipo,
  input  logic ethmac_intr,
  output logic ethmac_cs,

  output logic rgbled0,
  output logic rgbled_en,

  // UART 0
  output logic ser0_tx,
  input  logic ser0_rx,

  // UART 1
  output logic ser1_tx,
  input  logic ser1_rx,

  // RS-232
  output logic rs232_tx,
  input  logic rs232_rx,

  // RS-485
  input  logic rs485_ro,
  output logic rs485_de,
  output logic rs485_ren,
  output logic rs485_di,

  // QWIIC (Sparkfun) buses
  inout  logic scl0,  // qwiic0 and Arduino Header
  inout  logic sda0,

  inout  logic scl1,  // qwiic1
  inout  logic sda1,

  // R-Pi header I2C buses
  inout  logic rph_g3_scl,  // SCL1/GPIO3 on Header
  inout  logic rph_g2_sda,  // SDA1/GPIO2

  inout  logic rph_g1,  // ID_SC for HAT ID EEPROM
  inout  logic rph_g0,  // ID_SD

  // R-Pi header SPI buses
  inout  logic rph_g11_sclk, // SPI0
  inout  logic rph_g10_copi, // SPI0
  inout  logic rph_g9_cipo,  // SPI0
  inout  logic rph_g8_ce0,   // SPI0
  inout  logic rph_g7_ce1,   // SPI0

  inout  logic rph_g21_sclk, // SPI1
  inout  logic rph_g20_copi, // SPI1
  inout  logic rph_g19_cipo, // SPI1
  inout  logic rph_g18,      // SPI1 CE0
  inout  logic rph_g17,      // SPI1 CE1
  inout  logic rph_g16_ce2,  // SPI1

  // R-Pi header UART
  inout  logic rph_txd0,
  inout  logic rph_rxd0,

  // R-Pi header GPIO
  inout  logic rph_g27,
  inout  logic rph_g26,
  inout  logic rph_g25,
  inout  logic rph_g24,
  inout  logic rph_g23,
  inout  logic rph_g22,
  inout  logic rph_g13,
  inout  logic rph_g12,
  inout  logic rph_g6,
  inout  logic rph_g5,
  inout  logic rph_g4,

  // Arduino shield GPIO
  inout  logic ah_tmpio0,
  inout  logic ah_tmpio1,
  inout  logic ah_tmpio2,
  inout  logic ah_tmpio3,
  inout  logic ah_tmpio4,
  inout  logic ah_tmpio5,
  inout  logic ah_tmpio6,
  inout  logic ah_tmpio7,
  inout  logic ah_tmpio8,
  inout  logic ah_tmpio9,

  // Arduino shield SPI bus
  inout  logic ah_tmpio10, // Chip select
  inout  logic ah_tmpio11, // COPI
  inout  logic ah_tmpio12, // CIPO or GP
  inout  logic ah_tmpio13, // SCLK

  // Arduino/AVR In-Circuit Serial Programming (ICSP) header
  // (useful for outputting debug signals)
  output logic      ah_tmpio14, // CIPO
  output logic      ah_tmpio15, // SCK
  output logic      ah_tmpio16, // COPI
  output logic      ah_tmpio17, // IO (a.k.a. RST)

  // Arduino shield analog(ue) pins digital inputs
  input logic analog0_digital,
  input logic analog1_digital,
  input logic analog2_digital,
  input logic analog3_digital,
  input logic analog4_digital,
  input logic analog5_digital,

  // Arduino shield analog(ue) pins actual analog(ue) input pairs
  input wire  analog0_p,
  input wire  analog0_n,
  input wire  analog1_p,
  input wire  analog1_n,
  input wire  analog2_p,
  input wire  analog2_n,
  input wire  analog3_p,
  input wire  analog3_n,
  input wire  analog4_p,
  input wire  analog4_n,
  input wire  analog5_p,
  input wire  analog5_n,

  // mikroBUS Click other
  output logic mb10, // PWM
  input  logic mb9,  // Interrupt
  output logic mb0,  // Reset

  // mikroBUS Click UART
  input  logic mb8,  // RX
  output logic mb7,  // TX

  // mikroBUS Click I2C bus
  inout  logic mb6,  // SCL
  inout  logic mb5,  // SDA

  // mikroBUS Click SPI
  output logic mb4,  // COPI
  input  logic mb3,  // CIPO
  output logic mb2,  // SCK
  output logic mb1,  // Chip select

  // PMOD0
  inout  logic pmod0_1,
  inout  logic pmod0_2,
  inout  logic pmod0_3,
  inout  logic pmod0_4,
  inout  logic pmod0_5,
  inout  logic pmod0_6,
  inout  logic pmod0_7,
  inout  logic pmod0_8,
  // PMODC (the pins between PMOD0 and PMOD1)
  inout  logic pmodc_1,
  inout  logic pmodc_2,
  inout  logic pmodc_3,
  inout  logic pmodc_4,
  inout  logic pmodc_5,
  inout  logic pmodc_6,
  // PMOD1
  inout  logic pmod1_1,
  inout  logic pmod1_2,
  inout  logic pmod1_3,
  inout  logic pmod1_4,
  inout  logic pmod1_5,
  inout  logic pmod1_6,
  inout  logic pmod1_7,
  inout  logic pmod1_8,

  // Status input from USB transceiver
  input  logic usrusb_vbusdetect,

  // Control of USB transceiver
  output logic usrusb_softcn,
  // Configure the USB transceiver for Full Speed operation.
  output logic usrusb_spd,

  // Reception from USB host via transceiver
  input  logic usrusb_v_p,
  input  logic usrusb_v_n,
  input  logic usrusb_rcv,

  // Transmission to USB host via transceiver
  output logic usrusb_vpo,
  output logic usrusb_vmo,

  // Always driven configuration signals to the USB transceiver.
  output logic usrusb_oe,
  output logic usrusb_sus,

  // User JTAG
  input  logic tck_i,
  input  logic tms_i,
  input  logic td_i,
  output logic td_o,

  // SPI flash interface
  output logic appspi_clk,
  output logic appspi_d0, // COPI (controller output peripheral input)
  input  logic appspi_d1, // CIPO (controller input peripheral output)
  output logic appspi_d2, // WP_N (write protect negated)
  output logic appspi_d3, // HOLD_N or RESET_N
  output logic appspi_cs, // Chip select negated

  // MicroSD card slot
  output logic microsd_clk,  // SPI mode: SCLK
  input  logic microsd_dat0, // SPI mode: CIPO
//input  logic microsd_dat1, // SPI mode: NC
//input  logic microsd_dat2, // SPI mode: NC
  output logic microsd_dat3, // SPI mode: CS_N
  output logic microsd_cmd,  // SPI mode: COPI
  input  logic microsd_det,   // Card insertion detection

  // XL expansion headers
  inout  logic ex0_0,
  inout  logic ex0_1,
  inout  logic ex0_2,
  inout  logic ex0_3,
  inout  logic ex0_4,
  inout  logic ex0_5,
  inout  logic ex0_6,
  inout  logic ex0_7,
  inout  logic ex0_8,
  inout  logic ex0_9,
  inout  logic ex0_10,
  inout  logic ex0_11,
  inout  logic ex0_12,
  inout  logic ex0_13,
  inout  logic ex0_14,
  inout  logic ex0_15,
  inout  logic ex0_16,
  inout  logic ex0_17,
  inout  logic ex0_18,
  inout  logic ex0_19,
  inout  logic ex0_20,
  inout  logic ex0_21,
  inout  logic ex0_22,
  inout  logic ex0_23,
  inout  logic ex0_24,
  inout  logic ex0_25,
  inout  logic ex0_26,
  inout  logic ex0_27,
  inout  logic ex0_28,
  inout  logic ex0_29,
  inout  logic ex0_30,
  inout  logic ex0_31,
  inout  logic ex0_32,
  inout  logic ex0_33,
  inout  logic ex0_34,
  inout  logic ex0_35,
  inout  logic ex0_36,
  inout  logic ex0_37,
  inout  logic ex0_38,
  inout  logic ex0_39,
  inout  logic ex0_40,
  inout  logic ex0_41,
  inout  logic ex0_42,
  inout  logic ex0_43,
  inout  logic ex0_44,
  inout  logic ex0_45,
  inout  logic ex0_46,
  inout  logic ex0_47,
  inout  logic ex0_48,
  inout  logic ex0_49,
  inout  logic ex0_50,
  inout  logic ex0_51,
  inout  logic ex0_52,
  inout  logic ex0_53,
  inout  logic ex0_54,
  inout  logic ex0_55,
  inout  logic ex0_56,
  inout  logic ex0_57,
  inout  logic ex0_58,
  inout  logic ex0_59,
  inout  logic ex0_60,
  inout  logic ex0_61,
  inout  logic ex0_62,
  inout  logic ex0_63,
  inout  logic ex1_0,
  inout  logic ex1_1,
  inout  logic ex1_2,
  inout  logic ex1_3,
  inout  logic ex1_4,
  inout  logic ex1_5,
  inout  logic ex1_6,
  inout  logic ex1_7,
  inout  logic ex1_8,
  inout  logic ex1_9,
  inout  logic ex1_10,
  inout  logic ex1_11,
  inout  logic ex1_12,
  inout  logic ex1_13,
  inout  logic ex1_14,
  inout  logic ex1_15,
  inout  logic ex1_16,
  inout  logic ex1_17,
  inout  logic ex1_18,
  inout  logic ex1_19,
  inout  logic ex1_20,
  inout  logic ex1_21,
  inout  logic ex1_22,
  inout  logic ex1_23,
  inout  logic ex1_24,
  inout  logic ex1_25,
  inout  logic ex1_26,
  inout  logic ex1_27,
  inout  logic ex1_28,
  inout  logic ex1_29,
  inout  logic ex1_30,
  inout  logic ex1_31,
  inout  logic ex1_32,
  inout  logic ex1_33,
  inout  logic ex1_34,
  inout  logic ex1_35,
  inout  logic ex1_36,
  inout  logic ex1_37,
  inout  logic ex1_38,
  inout  logic ex1_39,
  inout  logic ex1_40,
  inout  logic ex1_41,
  inout  logic ex1_42,
  inout  logic ex1_43,
  inout  logic ex1_44,
  inout  logic ex1_45,
  inout  logic ex1_46,
  inout  logic ex1_47,
  inout  logic ex1_48,
  inout  logic ex1_49,
  inout  logic ex1_50,
  inout  logic ex1_51,
  inout  logic ex1_52,
  inout  logic ex1_53,
  inout  logic ex1_54,
  inout  logic ex1_55,
  inout  logic ex1_56,
  inout  logic ex1_57,
  inout  logic ex1_58,
  inout  logic ex1_59,
  inout  logic ex1_60,
  inout  logic ex1_61,
  inout  logic ex1_62,
  inout  logic ex1_63
);

  // TODO: Remove SRAMInitFile when have an alt way to load programs into FPGA
  parameter SRAMInitFile = "";

  // System clock and reset
  logic clk_sys;
  logic rst_sys_n;

  // Peripheral clock and reset
  logic clk_peri;
  logic rst_peri_n;

  // USB device clock and reset
  logic clk_usb;
  logic rst_usb_n;

  // Always-ON clock and reset
  logic clk_aon;
  logic rst_aon_n;

  // Output enable signals for output-only ports not going via padring
  logic pwm_raw, pwm_en;
  logic pattgen_pda0_raw, pattgen_pda0_en;
  logic pattgen_pcl0_raw, pattgen_pcl0_en;
  logic pattgen_pda1_raw, pattgen_pda1_en;
  logic pattgen_pcl1_raw, pattgen_pcl1_en;
  logic spi0_sck_raw, spi0_sck_en;
  logic spi0_csb_raw, spi0_csb_en;
  logic [3:0] spi0_sdo_raw, spi0_sdo_en;
  logic spi1_sck_raw, spi1_sck_en;
  logic spi1_csb_raw, spi1_csb_en;
  logic [3:0] spi1_sdo_raw, spi1_sdo_en;
  logic uart0_tx_raw, uart0_tx_en;
  logic uart1_tx_raw, uart1_tx_en;

  logic _unused_out;

  logic dp_en_d2p;
  logic rx_enable_d2p;

  sonata_xl_inout_pins_t inout_from_pins, inout_to_pins, inout_to_pins_en;

  top_chip_system #(
    .SRAMInitFile(SRAMInitFile)
  ) u_top_chip_system (
    .clk_sys_i  (clk_sys),
    .clk_peri_i (clk_peri),
    .clk_usb_i  (clk_usb),
    .clk_aon_i  (clk_aon),

    .rst_sys_ni   (rst_sys_n),
    .rst_peri_ni  (rst_peri_n),
    .rst_usb_ni   (rst_usb_n),
    .rst_aon_ni   (rst_aon_n),

    // GPIO over PMOD and RPi header
    .cio_gpio_i     (inout_from_pins[INOUT_PIN_GPIO_END : INOUT_PIN_GPIO_START]),
    .cio_gpio_o     (inout_to_pins[INOUT_PIN_GPIO_END : INOUT_PIN_GPIO_START]),
    .cio_gpio_en_o  (inout_to_pins_en[INOUT_PIN_GPIO_END : INOUT_PIN_GPIO_START]),

    // PMOD1
    .cio_i2c0_sda_i     (inout_from_pins[INOUT_PIN_SDA0]),
    .cio_i2c0_scl_i     (inout_from_pins[INOUT_PIN_SCL0]),
    .cio_i2c0_sda_o     (inout_to_pins[INOUT_PIN_SDA0]),
    .cio_i2c0_scl_o     (inout_to_pins[INOUT_PIN_SCL0]),
    .cio_i2c0_sda_en_o  (inout_to_pins_en[INOUT_PIN_SDA0]),
    .cio_i2c0_scl_en_o  (inout_to_pins_en[INOUT_PIN_SCL0]),

    // QWIIC1 I^2C
    .cio_i2c1_sda_i     (inout_from_pins[INOUT_PIN_SDA1]),
    .cio_i2c1_scl_i     (inout_from_pins[INOUT_PIN_SCL1]),
    .cio_i2c1_sda_o     (inout_to_pins[INOUT_PIN_SDA1]),
    .cio_i2c1_scl_o     (inout_to_pins[INOUT_PIN_SCL1]),
    .cio_i2c1_sda_en_o  (inout_to_pins_en[INOUT_PIN_SDA1]),
    .cio_i2c1_scl_en_o  (inout_to_pins_en[INOUT_PIN_SCL1]),

    // mikroBUS header PWM
    .cio_pwm_o    (pwm_raw),
    .cio_pwm_en_o (pwm_en),

    // Pattgen output over Arduino D0-D3 pins
    .cio_pattgen_pda0_tx_o(pattgen_pda0_raw),
    .cio_pattgen_pcl0_tx_o(pattgen_pcl0_raw),
    .cio_pattgen_pda1_tx_o(pattgen_pda1_raw),
    .cio_pattgen_pcl1_tx_o(pattgen_pcl1_raw),
    .cio_pattgen_pda0_tx_en_o(pattgen_pda0_en),
    .cio_pattgen_pcl0_tx_en_o(pattgen_pcl0_en),
    .cio_pattgen_pda1_tx_en_o(pattgen_pda1_en),
    .cio_pattgen_pcl1_tx_en_o(pattgen_pcl1_en),

    // PMOD0 SPI.
    // Only using one data-bit per direction.
    .cio_spi_host0_sd_i     ({3'b000, pmod0_3}),
    .cio_spi_host0_sck_o    (spi0_sck_raw),
    .cio_spi_host0_csb_o    (spi0_csb_raw),
    .cio_spi_host0_sd_o     (spi0_sdo_raw),
    .cio_spi_host0_sck_en_o (spi0_sck_en),
    .cio_spi_host0_csb_en_o (spi0_csb_en),
    .cio_spi_host0_sd_en_o  (spi0_sdo_en),

    // mikroBUS header SPI.
    // Only using one data-bit per direction.
    .cio_spi_host1_sd_i     ({3'b000, mb3}),
    .cio_spi_host1_sck_o    (spi1_sck_raw),
    .cio_spi_host1_csb_o    (spi1_csb_raw),
    .cio_spi_host1_sd_o     (spi1_sdo_raw),
    .cio_spi_host1_sck_en_o (spi1_sck_en),
    .cio_spi_host1_csb_en_o (spi1_csb_en),
    .cio_spi_host1_sd_en_o  (spi1_sdo_en),

    // ser0 for FTDI channel-C UART (via jumpers)
    .cio_uart0_rx_i     (ser0_rx),
    .cio_uart0_tx_o     (uart0_tx_raw),
    .cio_uart0_tx_en_o  (uart0_tx_en),

    // mikroBUS header TX/RX
    .cio_uart1_rx_i     (mb8),
    .cio_uart1_tx_o     (uart1_tx_raw),
    .cio_uart1_tx_en_o  (uart1_tx_en),

    // USB transceiver
    .cio_usbdev_sense_i         (usrusb_vbusdetect),
    .cio_usbdev_usb_dp_i        (usrusb_v_p),
    .cio_usbdev_usb_dn_i        (usrusb_v_n),
    .cio_usbdev_rx_d_i          (usrusb_rcv),
    .cio_usbdev_usb_dp_o        (usrusb_vpo),
    .cio_usbdev_usb_dp_en_o     (dp_en_d2p),
    .cio_usbdev_usb_dn_o        (usrusb_vmo),
    .cio_usbdev_usb_dn_en_o     (),
    .cio_usbdev_tx_d_o          (),
    .cio_usbdev_tx_se0_o        (),
    .cio_usbdev_tx_use_d_se0_o  (),
    .cio_usbdev_dp_pullup_o     (usrusb_softcn),
    .cio_usbdev_dn_pullup_o     (),
    .cio_usbdev_rx_enable_o     (rx_enable_d2p),

    // TODO: Connect aon timer to sleep and reset managers (when present)
    .aon_timer_wkup_req_o(),
    .aon_timer_rst_req_o (),

    .scanmode_i  (prim_mubi_pkg::MuBi4False),
    .ram_1p_cfg_i('0),
    .ram_2p_cfg_i('0),
    .rom_cfg_i   ('0)
  );

  // Enable logic for output-only ports
  assign mb10 = pwm_raw & pwm_en;    // PWM (external header copy)
  assign usrLed0 = pwm_raw & pwm_en; // PWM (on-board LED copy)
  assign ah_tmpio0 = pattgen_pda0_raw & pattgen_pda0_en; // pattgen ch0
  assign ah_tmpio1 = pattgen_pcl0_raw & pattgen_pcl0_en; // pattgen ch0
  assign ah_tmpio2 = pattgen_pda1_raw & pattgen_pda1_en; // pattgen ch1
  assign ah_tmpio3 = pattgen_pcl1_raw & pattgen_pcl1_en; // pattgen ch1
  assign pmod0_4 = spi0_sck_raw & spi0_sck_en; // SPI0
  assign pmod0_1 = spi0_csb_raw & spi0_csb_en; // SPI0
  assign pmod0_2 = spi0_sdo_raw[0] & spi0_sdo_en[0]; // SPI0
  assign mb2 = spi1_sck_raw & spi1_sck_en; // SPI1
  assign mb1 = spi1_csb_raw & spi1_csb_en; // SPI1
  assign mb4 = spi1_sdo_raw[0] & spi1_sdo_en[0]; // SPI1
  assign ser0_tx = uart0_tx_raw & uart0_tx_en; // UART0
  assign mb7 = uart1_tx_raw & uart1_tx_en; // UART1

  assign _unused_out = ^{spi0_sdo_raw[3:1],
                         spi0_sdo_en[3:1],
                         spi1_sdo_raw[3:1],
                         spi1_sdo_en[3:1]};

  assign usrusb_spd = 1'b1;  // Full Speed operation.

  assign usrusb_oe  = !dp_en_d2p;  // Active low Output Enable.
  assign usrusb_sus = !rx_enable_d2p;

  // Tie flash wp_n and hold_n to 1 as they're active low and we don't need either signal
  assign appspi_d2 = 1'b1;
  assign appspi_d3 = 1'b1;

  // Use core reset signal as a boot indicator
  assign led_bootok = rst_sys_n;

  // Always running with CHERI
  assign led_cheri = 1'b1;
  assign led_legacy = 1'b0;
  assign led_halted = 1'b0;

  // Keep error LEDs off, as we have no core integration to drive them
  assign cheriErr0 = 1'b0;
  assign cheriErr1 = 1'b0;
  assign cheriErr2 = 1'b0;
  assign cheriErr3 = 1'b0;
  assign cheriErr4 = 1'b0;
  assign cheriErr5 = 1'b0;
  assign cheriErr6 = 1'b0;
  assign cheriErr7 = 1'b0;
  assign cheriErr8 = 1'b0;

  // Keep RGB LEDs disabled while we have no hardware to talk to them
  assign rgbled_en = 1'b0;

  // mikroBUS Click boards mostly use this pin as an active low reset signal but some
  // boards use it as an active low Read Enable (RE) pin; presently this pin is not
  // under software control so some boards are not supported.
  assign mb0 = 1'b1;

  // Produce system clocks and matching de-assert synchronous resets
  // from 25 MHz Sonata XL board clock.
  clk_rst_gen_sonata_xl u_clk_rst_gen(
    .rst_btn_ni   (nrst),
    .clk_board_i  (mainClk),
    .clk_sys_o    (clk_sys),
    .clk_peri_o   (clk_peri),
    .clk_usb_o    (clk_usb),
    .clk_aon_o    (clk_aon),
    .rst_sys_no   (rst_sys_n),
    .rst_peri_no  (rst_peri_n),
    .rst_usb_no   (rst_usb_n),
    .rst_aon_no   (rst_aon_n)
  );

  // Inout Pins
  padring #(
    .InoutNumber(INOUT_PIN_NUM)
  ) u_padring (
    .inout_to_pins_i   (inout_to_pins   ),
    .inout_to_pins_en_i(inout_to_pins_en),
    .inout_from_pins_o (inout_from_pins ),
    .inout_pins_io({
      // Notice: Please update INOUT_PIN_* definitions in top_chip_sonata_xl_pkg
      //         to match any changes of purpose to the list of ports below.
      pmod1_3, // INOUT_PIN_SCL0
      pmod1_4, // INOUT_PIN_SDA0
      scl1, // INOUT_PIN_SCL1
      sda1, // INOUT_PIN_SDA1
      // INOUT_PIN_GPIO_START
      rph_g0, // GPIO 0
      rph_g1,
      rph_g2_sda,
      rph_g3_scl,
      rph_g4,
      rph_g5,
      rph_g6,
      rph_g7_ce1,
      rph_g8_ce0,
      rph_g9_cipo,
      rph_g10_copi,
      rph_g11_sclk,
      rph_g12,
      rph_g13,
      rph_txd0, // g14
      rph_rxd0, // g15
      rph_g16_ce2,
      rph_g17,
      rph_g18,
      rph_g19_cipo,
      rph_g20_copi,
      rph_g21_sclk,
      rph_g22,
      rph_g23,
      rph_g24,
      rph_g25,
      rph_g26,
      rph_g27, // GPIO 27
      pmod0_5, // GPIO 28
      pmod0_6, // GPIO 29
      pmod0_7, // GPIO 30
      pmod0_8  // GPIO 31
      // INOUT_PIN_GPIO_END
    })
  );

  // Debug signals for viewing on external logic analyser via P11 header.
  logic [3:0] dbg;
  always_comb begin : dbg_case
    case ({usrSw3, usrSw2, usrSw1, usrSw0})
      4'b0000: begin
        dbg[0] = u_clk_rst_gen.clk_board_buf;
        dbg[1] = u_clk_rst_gen.pll_locked;
        dbg[2] = u_clk_rst_gen.rst_btn_buf_n;
        dbg[3] = u_clk_rst_gen.rst_btn_sync_n;
      end
      4'b0001: begin
        dbg[0] = u_clk_rst_gen.pll_locked;
        dbg[1] = u_clk_rst_gen.rst_btn;
        dbg[2] = u_clk_rst_gen.rst_board_n;
        dbg[3] = u_clk_rst_gen.rst_sys_no;
      end
      4'b0010: begin
        dbg[0] = clk_sys;
        dbg[1] = clk_peri;
        dbg[2] = clk_usb;
        dbg[3] = clk_aon;
      end
      4'b0011: begin
        dbg[0] = rst_sys_n;
        dbg[1] = rst_peri_n;
        dbg[2] = rst_usb_n;
        dbg[3] = rst_aon_n;
      end
      4'b0100: begin
        dbg[0] = clk_sys;
        dbg[1] = rst_sys_n;
        dbg[2] = u_top_chip_system.u_core_ibex.core_instr_req;
        dbg[3] = u_top_chip_system.u_core_ibex.core_instr_gnt;
      end
      4'b0101: begin
        dbg[0] = clk_sys;
        dbg[1] = rst_sys_n;
        dbg[2] = u_top_chip_system.u_core_ibex.core_instr_rvalid;
        dbg[3] = u_top_chip_system.u_core_ibex.core_instr_err;
      end
      4'b1000: begin
        dbg[0] = u_top_chip_system.u_sram.u_ram.rdata_o[0];
        dbg[1] = u_top_chip_system.u_sram.u_ram.rdata_o[1];
        dbg[2] = u_top_chip_system.u_sram.u_ram.rdata_o[2];
        dbg[3] = u_top_chip_system.u_sram.u_ram.rdata_o[3];
      end
      4'b1001: begin
        dbg[0] = u_top_chip_system.u_sram.u_ram.rdata_o[4];
        dbg[1] = u_top_chip_system.u_sram.u_ram.rdata_o[5];
        dbg[2] = u_top_chip_system.u_sram.u_ram.rdata_o[6];
        dbg[3] = u_top_chip_system.u_sram.u_ram.rdata_o[7];
      end
      4'b1010: begin
        dbg[0] = u_top_chip_system.u_sram.u_ram.rdata_o[8];
        dbg[1] = u_top_chip_system.u_sram.u_ram.rdata_o[9];
        dbg[2] = u_top_chip_system.u_sram.u_ram.rdata_o[10];
        dbg[3] = u_top_chip_system.u_sram.u_ram.rdata_o[11];
      end
      4'b1011: begin
        dbg[0] = u_top_chip_system.u_sram.u_ram.rdata_o[12];
        dbg[1] = u_top_chip_system.u_sram.u_ram.rdata_o[13];
        dbg[2] = u_top_chip_system.u_sram.u_ram.rdata_o[14];
        dbg[3] = u_top_chip_system.u_sram.u_ram.rdata_o[15];
      end
      4'b1100: begin
        dbg[0] = u_top_chip_system.u_sram.u_ram.rdata_o[16];
        dbg[1] = u_top_chip_system.u_sram.u_ram.rdata_o[17];
        dbg[2] = u_top_chip_system.u_sram.u_ram.rdata_o[18];
        dbg[3] = u_top_chip_system.u_sram.u_ram.rdata_o[19];
      end
      4'b1101: begin
        dbg[0] = u_top_chip_system.u_sram.u_ram.rdata_o[20];
        dbg[1] = u_top_chip_system.u_sram.u_ram.rdata_o[21];
        dbg[2] = u_top_chip_system.u_sram.u_ram.rdata_o[22];
        dbg[3] = u_top_chip_system.u_sram.u_ram.rdata_o[23];
      end
      4'b1110: begin
        dbg[0] = u_top_chip_system.u_sram.u_ram.rdata_o[24];
        dbg[1] = u_top_chip_system.u_sram.u_ram.rdata_o[25];
        dbg[2] = u_top_chip_system.u_sram.u_ram.rdata_o[26];
        dbg[3] = u_top_chip_system.u_sram.u_ram.rdata_o[27];
      end
      4'b1111: begin
        dbg[0] = u_top_chip_system.u_sram.u_ram.rdata_o[28];
        dbg[1] = u_top_chip_system.u_sram.u_ram.rdata_o[29];
        dbg[2] = u_top_chip_system.u_sram.u_ram.rdata_o[30];
        dbg[3] = u_top_chip_system.u_sram.u_ram.rdata_o[31];
      end
      default:
        dbg = 'd1111;
    endcase
  end
  // Explicitly instantiate output buffers to avoid the signals being renamed.
  OBUF u_ah_tmpio14_buf ( .O(ah_tmpio14), .I(dbg[0]) );
  OBUF u_ah_tmpio15_buf ( .O(ah_tmpio15), .I(dbg[1]) );
  OBUF u_ah_tmpio16_buf ( .O(ah_tmpio16), .I(dbg[2]) );
  OBUF u_ah_tmpio17_buf ( .O(ah_tmpio17), .I(dbg[3]) );

endmodule : top_chip_sonata_xl
