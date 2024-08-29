// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module top_chip_system #(
  // parameters for gpio
  parameter bit GpioGpioAsyncOn = 1,
  // parameters for i2c0
  parameter int I2c0InputDelayCycles = 0,
  // parameters for i2c1
  parameter int I2c1InputDelayCycles = 0
) (
  // Clock & reset
  input clk_sys_i,
  input clk_peri_i,
  input clk_aon_i,

  input rst_sys_ni,
  input rst_peri_ni,
  input rst_aon_ni,

  // Ibex interrupts in
  input  logic        ibex_irq_software_i,
  input  logic        ibex_irq_timer_i,
  input  logic        ibex_irq_external_i,
  input  logic [14:0] ibex_irq_fast_i,
  input  logic        ibex_irq_nm_i,

  // Peripheral interrupts out (clock domain dependent upon the peripheral the interrupt is from)
  output [31:0] gpio_intr_o,

  output top_chip_system_pkg::aon_timer_intr_t aon_timer_intr_o,
  output logic                                 aon_timer_nmi_wdog_timer_bark_o,

  output logic rv_timer_intr_o,

  output top_chip_system_pkg::i2c_intr_t i2c0_intr_o,
  output top_chip_system_pkg::i2c_intr_t i2c1_intr_o,

  output top_chip_system_pkg::spi_host_intr_t spi_host0_intr_o,
  output top_chip_system_pkg::spi_host_intr_t spi_host1_intr_o,

  output top_chip_system_pkg::uart_intr_t uart0_intr_o,
  output top_chip_system_pkg::uart_intr_t uart1_intr_o,

  // Pad I/O
  // GPIO
  input        [31:0] cio_gpio_i,
  output logic [31:0] cio_gpio_o,
  output logic [31:0] cio_gpio_en_o,
  // I2C 0
  input  logic cio_i2c0_sda_i,
  input  logic cio_i2c0_scl_i,
  output logic cio_i2c0_sda_o,
  output logic cio_i2c0_sda_en_o,
  output logic cio_i2c0_scl_o,
  output logic cio_i2c0_scl_en_o,

  // I2C 1
  input  logic cio_i2c1_sda_i,
  input  logic cio_i2c1_scl_i,
  output logic cio_i2c1_sda_o,
  output logic cio_i2c1_sda_en_o,
  output logic cio_i2c1_scl_o,
  output logic cio_i2c1_scl_en_o,

  // SPI Host 0
  input  logic [3:0] cio_spi_host0_sd_i,
  output logic       cio_spi_host0_sck_o,
  output logic       cio_spi_host0_sck_en_o,
  output logic       cio_spi_host0_csb_o,
  output logic       cio_spi_host0_csb_en_o,
  output logic [3:0] cio_spi_host0_sd_o,
  output logic [3:0] cio_spi_host0_sd_en_o,

  // SPI Host 1
  input  logic [3:0] cio_spi_host1_sd_i,
  output logic       cio_spi_host1_sck_o,
  output logic       cio_spi_host1_sck_en_o,
  output logic       cio_spi_host1_csb_o,
  output logic       cio_spi_host1_csb_en_o,
  output logic [3:0] cio_spi_host1_sd_o,
  output logic [3:0] cio_spi_host1_sd_en_o,

  // UART 0
  input  logic cio_uart0_rx_i,
  output logic cio_uart0_tx_o,
  output logic cio_uart0_tx_en_o,

  // UART 1
  input  logic cio_uart1_rx_i,
  output logic cio_uart1_tx_o,
  output logic cio_uart1_tx_en_o,

  // AON timer wakeup and reset requests (clk_aon_i domain)
  output logic aon_timer_wkup_req_o,
  output logic aon_timer_rst_req_o,

  // Misc
  input prim_mubi_pkg::mubi4_t        scanmode_i,
  input prim_ram_1p_pkg::ram_1p_cfg_t ram_1p_cfg_i,
  input prim_ram_2p_pkg::ram_2p_cfg_t ram_2p_cfg_i,
  input prim_rom_pkg::rom_cfg_t       rom_cfg_i
);
  import top_chip_system_pkg::*;
  import tl_main_pkg::*;
  import tl_peri_pkg::*;
  import prim_mubi_pkg::*;

  tlul_pkg::tl_h2d_t tl_rv_core_ibex__corei_h2d;
  tlul_pkg::tl_d2h_t tl_rv_core_ibex__corei_d2h;
  tlul_pkg::tl_h2d_t tl_rv_core_ibex__cored_h2d;
  tlul_pkg::tl_d2h_t tl_rv_core_ibex__cored_d2h;

  tlul_pkg::tl_h2d_t tl_sram_h2d;
  tlul_pkg::tl_d2h_t tl_sram_d2h;
  tlul_pkg::tl_h2d_t tl_rom_h2d;
  tlul_pkg::tl_d2h_t tl_rom_d2h;
  tlul_pkg::tl_h2d_t tl_revocation_ram_h2d;
  tlul_pkg::tl_d2h_t tl_revocation_ram_d2h;
  tlul_pkg::tl_h2d_t tl_peri_h2d;
  tlul_pkg::tl_d2h_t tl_peri_d2h;

  xbar_main u_xbar_main (
    .clk_sys_i,
    .clk_peri_i,
    .rst_sys_ni,
    .rst_peri_ni,

    // Host interfaces
    .tl_rv_core_ibex__corei_i(tl_rv_core_ibex__corei_h2d),
    .tl_rv_core_ibex__corei_o(tl_rv_core_ibex__corei_d2h),
    .tl_rv_core_ibex__cored_i(tl_rv_core_ibex__cored_h2d),
    .tl_rv_core_ibex__cored_o(tl_rv_core_ibex__cored_d2h),

     // Device interfaces
    .tl_sram_o          (tl_sram_h2d),
    .tl_sram_i          (tl_sram_d2h),
    .tl_rom_o           (tl_rom_h2d),
    .tl_rom_i           (tl_rom_d2h),
    .tl_revocation_ram_o(tl_revocation_ram_h2d),
    .tl_revocation_ram_i(tl_revocation_ram_d2h),
    .tl_peri_o          (tl_peri_h2d),
    .tl_peri_i          (tl_peri_d2h),

    .scanmode_i
  );

  core_ibex u_core_ibex (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    .tl_corei_h2d_o(tl_rv_core_ibex__corei_h2d),
    .tl_corei_d2h_i(tl_rv_core_ibex__corei_d2h),
    .tl_cored_h2d_o(tl_rv_core_ibex__cored_h2d),
    .tl_cored_d2h_i(tl_rv_core_ibex__cored_d2h),

    .tl_revocation_ram_h2d_i(tl_revocation_ram_h2d),
    .tl_revocation_ram_d2h_o(tl_revocation_ram_d2h),

    .boot_addr_i(tl_main_pkg::ADDR_SPACE_ROM),

    .irq_software_i(ibex_irq_software_i),
    .irq_timer_i   (ibex_irq_timer_i),
    .irq_external_i(ibex_irq_external_i),
    .irq_fast_i    (ibex_irq_fast_i),
    .irq_nm_i      (ibex_irq_nm_i),

    .ram_2p_cfg_i
  );

  sram #(
    .AddrWidth(SRAMAddrWidth)
  ) u_sram (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    .tl_i(tl_sram_h2d),
    .tl_o(tl_sram_d2h),

    .ram_1p_cfg_i
  );

  rom #(
    .AddrWidth(ROMAddrWidth)
  ) u_rom (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    .tl_i(tl_rom_h2d),
    .tl_o(tl_rom_d2h),

    .rom_cfg_i
  );

  tlul_pkg::tl_h2d_t tl_aon_timer_h2d;
  tlul_pkg::tl_d2h_t tl_aon_timer_d2h;
  tlul_pkg::tl_h2d_t tl_rv_timer_h2d;
  tlul_pkg::tl_d2h_t tl_rv_timer_d2h;
  tlul_pkg::tl_h2d_t tl_gpio_h2d;
  tlul_pkg::tl_d2h_t tl_gpio_d2h;
  tlul_pkg::tl_h2d_t tl_i2c0_h2d;
  tlul_pkg::tl_d2h_t tl_i2c0_d2h;
  tlul_pkg::tl_h2d_t tl_i2c1_h2d;
  tlul_pkg::tl_d2h_t tl_i2c1_d2h;
  tlul_pkg::tl_h2d_t tl_spi_host0_h2d;
  tlul_pkg::tl_d2h_t tl_spi_host0_d2h;
  tlul_pkg::tl_h2d_t tl_spi_host1_h2d;
  tlul_pkg::tl_d2h_t tl_spi_host1_d2h;
  tlul_pkg::tl_h2d_t tl_uart0_h2d;
  tlul_pkg::tl_d2h_t tl_uart0_d2h;
  tlul_pkg::tl_h2d_t tl_uart1_h2d;
  tlul_pkg::tl_d2h_t tl_uart1_d2h;

  xbar_peri u_xbar_peri (
    .clk_peri_i,
    .rst_peri_ni,

    // Host interfaces
    .tl_main_i(tl_peri_h2d),
    .tl_main_o(tl_peri_d2h),

    // Device interfaces
    .tl_aon_timer_o(tl_aon_timer_h2d),
    .tl_aon_timer_i(tl_aon_timer_d2h),
    .tl_rv_timer_o (tl_rv_timer_h2d),
    .tl_rv_timer_i (tl_rv_timer_d2h),
    .tl_gpio_o     (tl_gpio_h2d),
    .tl_gpio_i     (tl_gpio_d2h),
    .tl_i2c0_o     (tl_i2c0_h2d),
    .tl_i2c0_i     (tl_i2c0_d2h),
    .tl_i2c1_o     (tl_i2c1_h2d),
    .tl_i2c1_i     (tl_i2c1_d2h),
    .tl_spi_host0_o(tl_spi_host0_h2d),
    .tl_spi_host0_i(tl_spi_host0_d2h),
    .tl_spi_host1_o(tl_spi_host1_h2d),
    .tl_spi_host1_i(tl_spi_host1_d2h),
    .tl_uart0_o    (tl_uart0_h2d),
    .tl_uart0_i    (tl_uart0_d2h),
    .tl_uart1_o    (tl_uart1_h2d),
    .tl_uart1_i    (tl_uart1_d2h),

    .scanmode_i
  );

  aon_timer u_aon_timer_aon (
    // Interrupt
    .intr_wkup_timer_expired_o(aon_timer_intr_o.wkup_timer_expired),
    .intr_wdog_timer_bark_o   (aon_timer_intr_o.wdog_timer_bark),
    .nmi_wdog_timer_bark_o    (aon_timer_nmi_wdog_timer_bark_o),

    // aon domain signals
    .wkup_req_o         (aon_timer_wkup_req_o),
    .aon_timer_rst_req_o(aon_timer_rst_req_o),

    .sleep_mode_i(1'b0),

    // Tilelink
    .tl_i(tl_aon_timer_h2d),
    .tl_o(tl_aon_timer_d2h),

    // Clock and reset connections
    .clk_i     (clk_peri_i),
    .clk_aon_i (clk_aon_i),
    .rst_ni    (rst_peri_ni),
    .rst_aon_ni(rst_aon_ni)
  );

  rv_timer u_rv_timer (
    // Interrupt
    .intr_timer_expired_hart0_timer0_o(rv_timer_intr_o),

    // Inter-module signals
    .tl_i(tl_rv_timer_h2d),
    .tl_o(tl_rv_timer_d2h),

    // Clock and reset connections
    .clk_i (clk_peri_i),
    .rst_ni(rst_peri_ni)
  );

  gpio #(
    .GpioAsyncOn(GpioGpioAsyncOn)
  ) u_gpio (
    // Input
    .cio_gpio_i   (cio_gpio_i),

    // Output
    .cio_gpio_o   (cio_gpio_o),
    .cio_gpio_en_o(cio_gpio_en_o),

    // Interrupt
    .intr_gpio_o(gpio_intr_o),

    // Inter-module signals
    .tl_i(tl_gpio_h2d),
    .tl_o(tl_gpio_d2h),

    // Clock and reset connections
    .clk_i (clk_peri_i),
    .rst_ni(rst_peri_ni)
  );

  i2c #(
    .InputDelayCycles(I2c0InputDelayCycles)
  ) u_i2c0 (
    // Input
    .cio_sda_i   (cio_i2c0_sda_i),
    .cio_scl_i   (cio_i2c0_scl_i),

    // Output
    .cio_sda_o   (cio_i2c0_sda_o),
    .cio_sda_en_o(cio_i2c0_sda_en_o),
    .cio_scl_o   (cio_i2c0_scl_o),
    .cio_scl_en_o(cio_i2c0_scl_en_o),

    // Interrupt
    .intr_fmt_threshold_o   (i2c0_intr_o.fmt_threshold),
    .intr_rx_threshold_o    (i2c0_intr_o.rx_threshold),
    .intr_acq_threshold_o   (i2c0_intr_o.acq_threshold),
    .intr_rx_overflow_o     (i2c0_intr_o.rx_overflow),
    .intr_controller_halt_o (i2c0_intr_o.controller_halt),
    .intr_scl_interference_o(i2c0_intr_o.scl_interference),
    .intr_sda_interference_o(i2c0_intr_o.sda_interference),
    .intr_stretch_timeout_o (i2c0_intr_o.stretch_timeout),
    .intr_sda_unstable_o    (i2c0_intr_o.sda_unstable),
    .intr_cmd_complete_o    (i2c0_intr_o.cmd_complete),
    .intr_tx_stretch_o      (i2c0_intr_o.tx_stretch),
    .intr_tx_threshold_o    (i2c0_intr_o.tx_threshold),
    .intr_acq_stretch_o     (i2c0_intr_o.acq_stretch),
    .intr_unexp_stop_o      (i2c0_intr_o.unexp_stop),
    .intr_host_timeout_o    (i2c0_intr_o.host_timeout),

    // Tilelink
    .tl_i(tl_i2c0_h2d),
    .tl_o(tl_i2c0_d2h),

    // Clock and reset connections
    .clk_i (clk_peri_i),
    .rst_ni(rst_peri_ni),

    // Misc
    .ram_cfg_i(ram_1p_cfg_i)
  );

  i2c #(
    .InputDelayCycles(I2c1InputDelayCycles)
  ) u_i2c1 (
    // Input
    .cio_sda_i   (cio_i2c1_sda_i),
    .cio_scl_i   (cio_i2c1_scl_i),

    // Output
    .cio_sda_o   (cio_i2c1_sda_o),
    .cio_sda_en_o(cio_i2c1_sda_en_o),
    .cio_scl_o   (cio_i2c1_scl_o),
    .cio_scl_en_o(cio_i2c1_scl_en_o),

    // Interrupt
    .intr_fmt_threshold_o   (i2c1_intr_o.fmt_threshold),
    .intr_rx_threshold_o    (i2c1_intr_o.rx_threshold),
    .intr_acq_threshold_o   (i2c1_intr_o.acq_threshold),
    .intr_rx_overflow_o     (i2c1_intr_o.rx_overflow),
    .intr_controller_halt_o (i2c1_intr_o.controller_halt),
    .intr_scl_interference_o(i2c1_intr_o.scl_interference),
    .intr_sda_interference_o(i2c1_intr_o.sda_interference),
    .intr_stretch_timeout_o (i2c1_intr_o.stretch_timeout),
    .intr_sda_unstable_o    (i2c1_intr_o.sda_unstable),
    .intr_cmd_complete_o    (i2c1_intr_o.cmd_complete),
    .intr_tx_stretch_o      (i2c1_intr_o.tx_stretch),
    .intr_tx_threshold_o    (i2c1_intr_o.tx_threshold),
    .intr_acq_stretch_o     (i2c1_intr_o.acq_stretch),
    .intr_unexp_stop_o      (i2c1_intr_o.unexp_stop),
    .intr_host_timeout_o    (i2c1_intr_o.host_timeout),

    // Tilelink
    .tl_i(tl_i2c1_h2d),
    .tl_o(tl_i2c1_d2h),

    // Clock and reset connections
    .clk_i (clk_peri_i),
    .rst_ni(rst_peri_ni),

    // Misc
    .ram_cfg_i(ram_1p_cfg_i)
  );

  spi_host u_spi_host0 (
    // Input
    .cio_sd_i    (cio_spi_host0_sd_i),

    // Output
    .cio_sck_o   (cio_spi_host0_sck_o),
    .cio_sck_en_o(cio_spi_host0_sck_en_o),
    .cio_csb_o   (cio_spi_host0_csb_o),
    .cio_csb_en_o(cio_spi_host0_csb_en_o),
    .cio_sd_o    (cio_spi_host0_sd_o),
    .cio_sd_en_o (cio_spi_host0_sd_en_o),

    // Interrupt
    .intr_error_o    (spi_host0_intr_o.error),
    .intr_spi_event_o(spi_host0_intr_o.spi_event),

    // Tilelink
    .tl_i(tl_spi_host0_h2d),
    .tl_o(tl_spi_host0_d2h),

    // Clock and reset connections
    .clk_i (clk_peri_i),
    .rst_ni(rst_peri_ni)
  );

  spi_host u_spi_host1 (
    // Input
    .cio_sd_i    (cio_spi_host1_sd_i),

    // Output
    .cio_sck_o   (cio_spi_host1_sck_o),
    .cio_sck_en_o(cio_spi_host1_sck_en_o),
    .cio_csb_o   (cio_spi_host1_csb_o),
    .cio_csb_en_o(cio_spi_host1_csb_en_o),
    .cio_sd_o    (cio_spi_host1_sd_o),
    .cio_sd_en_o (cio_spi_host1_sd_en_o),

    // Interrupt
    .intr_error_o    (spi_host1_intr_o.error),
    .intr_spi_event_o(spi_host1_intr_o.spi_event),

    // Tilelink
    .tl_i(tl_spi_host1_h2d),
    .tl_o(tl_spi_host1_d2h),

    // Clock and reset connections
    .clk_i (clk_peri_i),
    .rst_ni(rst_peri_ni)
  );

  uart u_uart0 (
    // Input
    .cio_rx_i   (cio_uart0_rx_i),

    // Output
    .cio_tx_o   (cio_uart0_tx_o),
    .cio_tx_en_o(cio_uart0_tx_en_o),

    // Interrupt
    .intr_tx_watermark_o (uart0_intr_o.tx_watermark),
    .intr_rx_watermark_o (uart0_intr_o.rx_watermark),
    .intr_tx_done_o      (uart0_intr_o.tx_done),
    .intr_rx_overflow_o  (uart0_intr_o.rx_overflow),
    .intr_rx_frame_err_o (uart0_intr_o.rx_frame_err),
    .intr_rx_break_err_o (uart0_intr_o.rx_break_err),
    .intr_rx_timeout_o   (uart0_intr_o.rx_timeout),
    .intr_rx_parity_err_o(uart0_intr_o.rx_parity_err),
    .intr_tx_empty_o     (uart0_intr_o.tx_empty),

    // Inter-module signals
    .tl_i(tl_uart0_h2d),
    .tl_o(tl_uart0_d2h),

    // Clock and reset connections
    .clk_i (clk_peri_i),
    .rst_ni(rst_peri_ni)
  );

  uart u_uart1 (
    // Input
    .cio_rx_i   (cio_uart1_rx_i),

    // Output
    .cio_tx_o   (cio_uart1_tx_o),
    .cio_tx_en_o(cio_uart1_tx_en_o),

    // Interrupt
    .intr_tx_watermark_o (uart1_intr_o.tx_watermark),
    .intr_rx_watermark_o (uart1_intr_o.rx_watermark),
    .intr_tx_done_o      (uart1_intr_o.tx_done),
    .intr_rx_overflow_o  (uart1_intr_o.rx_overflow),
    .intr_rx_frame_err_o (uart1_intr_o.rx_frame_err),
    .intr_rx_break_err_o (uart1_intr_o.rx_break_err),
    .intr_rx_timeout_o   (uart1_intr_o.rx_timeout),
    .intr_rx_parity_err_o(uart1_intr_o.rx_parity_err),
    .intr_tx_empty_o     (uart1_intr_o.tx_empty),

    // Inter-module signals
    .tl_i(tl_uart1_h2d),
    .tl_o(tl_uart1_d2h),

    // Clock and reset connections
    .clk_i (clk_peri_i),
    .rst_ni(rst_peri_ni)
  );
endmodule
