// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module top_chip_system #(
  // TODO: Remove SRAMInitFile when have an alt way to load programs into FPGA
  parameter     SRAMInitFile = "",
  // parameters for gpio
  parameter bit GpioGpioAsyncOn = 1,
  // parameters for i2c0
  parameter int I2c0InputDelayCycles = 0,
  // parameters for i2c1
  parameter int I2c1InputDelayCycles = 0,
  // parameters for pwm
  parameter int unsigned PwmNumOutputs = 6
) (
  // Clock & reset
  input clk_sys_i,
  input clk_peri_i,
  input clk_usb_i,
  input clk_aon_i,

  input rst_sys_ni,
  input rst_peri_ni,
  input rst_aon_ni,
  input rst_usb_ni,

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

  // JTAG
  input  logic cio_jtag_tck_i,
  input  logic cio_jtag_tms_i,
  input  logic cio_jtag_trst_ni,
  input  logic cio_jtag_td_i,
  output logic cio_jtag_td_o,
  output logic cio_jtag_td_en_o,

  // Pattgen
  output logic cio_pattgen_pda0_tx_o,
  output logic cio_pattgen_pda0_tx_en_o,
  output logic cio_pattgen_pcl0_tx_o,
  output logic cio_pattgen_pcl0_tx_en_o,
  output logic cio_pattgen_pda1_tx_o,
  output logic cio_pattgen_pda1_tx_en_o,
  output logic cio_pattgen_pcl1_tx_o,
  output logic cio_pattgen_pcl1_tx_en_o,

  // PWM
  output logic [PwmNumOutputs-1:0] cio_pwm_o,
  output logic [PwmNumOutputs-1:0] cio_pwm_en_o,

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

  // USBDEV
  input  logic cio_usbdev_sense_i,
  input  logic cio_usbdev_usb_dp_i,
  input  logic cio_usbdev_usb_dn_i,
  input  logic cio_usbdev_rx_d_i,
  output logic cio_usbdev_usb_dp_o,
  output logic cio_usbdev_usb_dp_en_o,
  output logic cio_usbdev_usb_dn_o,
  output logic cio_usbdev_usb_dn_en_o,
  output logic cio_usbdev_tx_d_o,
  output logic cio_usbdev_tx_se0_o,
  output logic cio_usbdev_tx_use_d_se0_o,
  output logic cio_usbdev_dp_pullup_o,
  output logic cio_usbdev_dn_pullup_o,
  output logic cio_usbdev_rx_enable_o,

  // AON timer wakeup and reset requests (clk_aon_i domain)
  output logic aon_timer_wkup_req_o,
  output logic aon_timer_rst_req_o,

  // USBDEV wakeup request
  output logic usbdev_aon_wkup_req_o,

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

  // Interrupt signals from the peripherals to the PLIC.
  logic [31:0] gpio_intr;

  top_chip_system_pkg::aon_timer_intr_t aon_timer_intr;
  logic aon_timer_nmi_wdog_timer_bark, aon_timer_nmi_wdog_timer_bark_sync;

  logic rv_timer_intr, rv_timer_intr_sync;

  top_chip_system_pkg::i2c_intr_t i2c0_intr;
  top_chip_system_pkg::i2c_intr_t i2c1_intr;

  top_chip_system_pkg::pattgen_intr_t pattgen_intr;

  top_chip_system_pkg::spi_host_intr_t spi_host0_intr;
  top_chip_system_pkg::spi_host_intr_t spi_host1_intr;

  top_chip_system_pkg::uart_intr_t uart0_intr;
  top_chip_system_pkg::uart_intr_t uart1_intr;

  top_chip_system_pkg::usbdev_intr_t usbdev_intr;

  // Inter-module signals between USBDEV and USBDEV AON/Wake module.
  logic         usbdev_dp_pullup;
  logic         usbdev_dn_pullup;
  logic         usbdev_aon_suspend_req;
  logic         usbdev_aon_wake_ack;
  logic         usbdev_aon_bus_reset;
  logic         usbdev_aon_sense_lost;
  logic         usbdev_aon_bus_not_idle;
  logic         usbdev_aon_wake_detect_active;

  // Signals for hardware revoker
  logic [127:0] hardware_revoker_control_reg_rdata;
  logic [63:0]  hardware_revoker_control_reg_wdata;
  logic         hardware_revoker_intr;

  // Interrupt signals from the PLIC to the CPU.
  logic       rv_plic_msip;
  logic       rv_plic_irq;

  logic [31:0] intr_vector;
  assign intr_vector = {
    3'b0,
    |gpio_intr,
    2'b0,
    |spi_host1_intr,
    |spi_host0_intr,
    6'b0,
    |i2c1_intr,
    |i2c0_intr,
    6'b0,
    |uart1_intr,
    |uart0_intr,
    |aon_timer_intr,
    |pattgen_intr,
    2'b0,
    |usbdev_intr,
    1'b0,
    |hardware_revoker_intr,
    1'b0
  };

  tlul_pkg::tl_h2d_t tl_core_ibex__corei_h2d;
  tlul_pkg::tl_d2h_t tl_core_ibex__corei_d2h;
  tlul_pkg::tl_h2d_t tl_core_ibex__cored_h2d;
  tlul_pkg::tl_d2h_t tl_core_ibex__cored_d2h;
  tlul_pkg::tl_h2d_t tl_dbg_h2d;
  tlul_pkg::tl_d2h_t tl_dbg_d2h;

  tlul_pkg::tl_h2d_t tl_sram_h2d;
  tlul_pkg::tl_d2h_t tl_sram_d2h;
  tlul_pkg::tl_h2d_t tl_rom_h2d;
  tlul_pkg::tl_d2h_t tl_rom_d2h;
  tlul_pkg::tl_h2d_t tl_revocation_ram_h2d;
  tlul_pkg::tl_d2h_t tl_revocation_ram_d2h;
  tlul_pkg::tl_h2d_t tl_rev_ctl_h2d;
  tlul_pkg::tl_d2h_t tl_rev_ctl_d2h;
  tlul_pkg::tl_h2d_t tl_rv_plic_h2d;
  tlul_pkg::tl_d2h_t tl_rv_plic_d2h;
  tlul_pkg::tl_h2d_t tl_peri_h2d;
  tlul_pkg::tl_d2h_t tl_peri_d2h;
  tlul_pkg::tl_h2d_t tl_core_ibex__cfg_h2d;
  tlul_pkg::tl_d2h_t tl_core_ibex__cfg_d2h;

  xbar_main u_xbar_main (
    .clk_sys_i,
    .clk_peri_i,
    .rst_sys_ni,
    .rst_peri_ni,

    // Host interfaces
    .tl_core_ibex__corei_i  (tl_core_ibex__corei_h2d),
    .tl_core_ibex__corei_o  (tl_core_ibex__corei_d2h),
    .tl_core_ibex__cored_i  (tl_core_ibex__cored_h2d),
    .tl_core_ibex__cored_o  (tl_core_ibex__cored_d2h),
    .tl_dbg_i           (tl_dbg_h2d),
    .tl_dbg_o           (tl_dbg_d2h),
    
     // Device interfaces
    .tl_sram_o            (tl_sram_h2d),
    .tl_sram_i            (tl_sram_d2h),
    .tl_rom_o             (tl_rom_h2d),
    .tl_rom_i             (tl_rom_d2h),
    .tl_revocation_ram_o  (tl_revocation_ram_h2d),
    .tl_revocation_ram_i  (tl_revocation_ram_d2h),
    .tl_rev_ctl_o         (tl_rev_ctl_h2d),
    .tl_rev_ctl_i         (tl_rev_ctl_d2h),
    .tl_core_ibex__cfg_o  (tl_core_ibex__cfg_h2d),
    .tl_core_ibex__cfg_i  (tl_core_ibex__cfg_d2h),
    .tl_rv_plic_o         (tl_rv_plic_h2d),
    .tl_rv_plic_i         (tl_rv_plic_d2h),
    .tl_peri_o            (tl_peri_h2d),
    .tl_peri_i            (tl_peri_d2h),

    .scanmode_i
  );

  // Debug module top.
  rv_dm #(
    .AlertAsyncOn ( '0), // TODO: Do we need alerts? Shall we remove them all together?
    .IdcodeValue  ( '0)  // TODO: jtag_id_pkg::RV_DM_JTAG_IDCODE )
  ) u_rv_dm (
    .clk_i                     (clk_sys_i ),
    .clk_lc_i                  (clk_sys_i ),
    .rst_ni                    (rst_sys_ni),
    .rst_lc_ni                 (rst_sys_ni),
    .next_dm_addr_i            ('0        ),
    .lc_hw_debug_en_i          (lc_ctrl_pkg::On ), // TODO: Uneducated guess
    .lc_dft_en_i               (lc_ctrl_pkg::Off), // TODO: Uneducated guess
    .pinmux_hw_debug_en_i      (lc_ctrl_pkg::On ), // TODO: Uneducated guess
    .otp_dis_rv_dm_late_debug_i(MuBi8False), // TODO: Uneducated guess
    .scanmode_i                (scanmode_i),
    .scan_rst_ni               (1'b1      ),
    .ndmreset_req_o            (/*unused*/), // TODO: ndmreset_req),
    .dmactive_o                (/*unused*/),
    .debug_req_o               (/*unused*/), // TODO connect to debug_req_i
    .unavailable_i             ('0        ),
    // bus device for comportable CSR access
    .regs_tl_d_i               ('0        ),
    .regs_tl_d_o               (/*unused*/),
    // bus device with debug memory, for an execution based technique
    .mem_tl_d_i                ('0        ),
    .mem_tl_d_o                (/*unused*/),
    // bus host, for system bus accesses
    .sba_tl_h_o                (tl_dbg_h2d),
    .sba_tl_h_i                (tl_dbg_d2h),
    // Alerts
    .alert_rx_i                ('0        ),
    .alert_tx_o                (/*unused*/),
    // JTAG
    .jtag_i                    ({cio_jtag_tck_i, cio_jtag_tms_i, cio_jtag_trst_ni, cio_jtag_td_i}),
    .jtag_o                    ({cio_jtag_td_o, cio_jtag_td_en_o})
  );

  core_ibex u_core_ibex (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    .tl_corei_h2d_o(tl_core_ibex__corei_h2d),
    .tl_corei_d2h_i(tl_core_ibex__corei_d2h),
    .tl_cored_h2d_o(tl_core_ibex__cored_h2d),
    .tl_cored_d2h_i(tl_core_ibex__cored_d2h),

    .tl_revocation_ram_h2d_i(tl_revocation_ram_h2d),
    .tl_revocation_ram_d2h_o(tl_revocation_ram_d2h),

    .hardware_revoker_control_reg_rdata(hardware_revoker_control_reg_rdata),
    .hardware_revoker_control_reg_wdata(hardware_revoker_control_reg_wdata),

    // TODO: Changed by AL for PLIC bringup.
    // .boot_addr_i(tl_main_pkg::ADDR_SPACE_ROM),
    .boot_addr_i(tl_main_pkg::ADDR_SPACE_SRAM),

    .irq_software_i(rv_plic_msip),
    .irq_timer_i   (rv_timer_intr_sync),
    .irq_external_i(rv_plic_irq),
    .irq_fast_i    ('0),
    .irq_nm_i      (aon_timer_nmi_wdog_timer_bark_sync),

    .cfg_tl_d_i    (tl_core_ibex__cfg_h2d),
    .cfg_tl_d_o    (tl_core_ibex__cfg_d2h),

    .ram_2p_cfg_i
  );

  sram #(
    // TODO: Remove SRAMInitFile when have an alt way to load programs into FPGA
    .InitFile(SRAMInitFile),
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

  rev_ctl u_rev_ctl (
    .clk_i         (clk_sys_i),
    .rst_ni        (rst_sys_ni),

    .core_to_ctl_i (hardware_revoker_control_reg_wdata),
    .ctl_to_core_o (hardware_revoker_control_reg_rdata),
    .rev_ctl_irq_o (hardware_revoker_intr),

    .tl_i          (tl_rev_ctl_h2d),
    .tl_o          (tl_rev_ctl_d2h)
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
  tlul_pkg::tl_h2d_t tl_pattgen_h2d;
  tlul_pkg::tl_d2h_t tl_pattgen_d2h;
  tlul_pkg::tl_h2d_t tl_pwm_h2d;
  tlul_pkg::tl_d2h_t tl_pwm_d2h;
  tlul_pkg::tl_h2d_t tl_spi_host0_h2d;
  tlul_pkg::tl_d2h_t tl_spi_host0_d2h;
  tlul_pkg::tl_h2d_t tl_spi_host1_h2d;
  tlul_pkg::tl_d2h_t tl_spi_host1_d2h;
  tlul_pkg::tl_h2d_t tl_uart0_h2d;
  tlul_pkg::tl_d2h_t tl_uart0_d2h;
  tlul_pkg::tl_h2d_t tl_uart1_h2d;
  tlul_pkg::tl_d2h_t tl_uart1_d2h;
  tlul_pkg::tl_h2d_t tl_usbdev_h2d;
  tlul_pkg::tl_d2h_t tl_usbdev_d2h;

  xbar_peri u_xbar_peri (
    .clk_peri_i,
    .clk_usb_i,
    .rst_peri_ni,
    .rst_usb_ni,

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
    .tl_pattgen_o  (tl_pattgen_h2d),
    .tl_pattgen_i  (tl_pattgen_d2h),
    .tl_pwm_o      (tl_pwm_h2d),
    .tl_pwm_i      (tl_pwm_d2h),
    .tl_spi_host0_o(tl_spi_host0_h2d),
    .tl_spi_host0_i(tl_spi_host0_d2h),
    .tl_spi_host1_o(tl_spi_host1_h2d),
    .tl_spi_host1_i(tl_spi_host1_d2h),
    .tl_uart0_o    (tl_uart0_h2d),
    .tl_uart0_i    (tl_uart0_d2h),
    .tl_uart1_o    (tl_uart1_h2d),
    .tl_uart1_i    (tl_uart1_d2h),
    .tl_usbdev_o   (tl_usbdev_h2d),
    .tl_usbdev_i   (tl_usbdev_d2h),

    .scanmode_i
  );

  aon_timer u_aon_timer_aon (
    // Interrupt
    .intr_wkup_timer_expired_o(aon_timer_intr.wkup_timer_expired),
    .intr_wdog_timer_bark_o   (aon_timer_intr.wdog_timer_bark),
    .nmi_wdog_timer_bark_o    (aon_timer_nmi_wdog_timer_bark),

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

  // Synchronize to fast Ibex clock domain
  prim_flop_2sync #(
    .Width(1)
  ) u_wdog_nmi_sync (
    .clk_i(clk_sys_i),
    .rst_ni(rst_sys_ni),
    .d_i(aon_timer_nmi_wdog_timer_bark),
    .q_o(aon_timer_nmi_wdog_timer_bark_sync)
  );

  rv_timer u_rv_timer (
    // Interrupt
    .intr_timer_expired_hart0_timer0_o(rv_timer_intr),

    // Inter-module signals
    .tl_i(tl_rv_timer_h2d),
    .tl_o(tl_rv_timer_d2h),

    // Clock and reset connections
    .clk_i (clk_peri_i),
    .rst_ni(rst_peri_ni)
  );

  // Timer interrupts do not come from rv_plic and may not be synchronous
  // to the ibex core.
  prim_flop_2sync #(
    .Width(1)
  ) u_intr_timer_sync (
    .clk_i(clk_sys_i),
    .rst_ni(rst_sys_ni),
    .d_i(rv_timer_intr),
    .q_o(rv_timer_intr_sync)
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
    .intr_gpio_o(gpio_intr),

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
    .intr_fmt_threshold_o   (i2c0_intr.fmt_threshold),
    .intr_rx_threshold_o    (i2c0_intr.rx_threshold),
    .intr_acq_threshold_o   (i2c0_intr.acq_threshold),
    .intr_rx_overflow_o     (i2c0_intr.rx_overflow),
    .intr_controller_halt_o (i2c0_intr.controller_halt),
    .intr_scl_interference_o(i2c0_intr.scl_interference),
    .intr_sda_interference_o(i2c0_intr.sda_interference),
    .intr_stretch_timeout_o (i2c0_intr.stretch_timeout),
    .intr_sda_unstable_o    (i2c0_intr.sda_unstable),
    .intr_cmd_complete_o    (i2c0_intr.cmd_complete),
    .intr_tx_stretch_o      (i2c0_intr.tx_stretch),
    .intr_tx_threshold_o    (i2c0_intr.tx_threshold),
    .intr_acq_stretch_o     (i2c0_intr.acq_stretch),
    .intr_unexp_stop_o      (i2c0_intr.unexp_stop),
    .intr_host_timeout_o    (i2c0_intr.host_timeout),

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
    .intr_fmt_threshold_o   (i2c1_intr.fmt_threshold),
    .intr_rx_threshold_o    (i2c1_intr.rx_threshold),
    .intr_acq_threshold_o   (i2c1_intr.acq_threshold),
    .intr_rx_overflow_o     (i2c1_intr.rx_overflow),
    .intr_controller_halt_o (i2c1_intr.controller_halt),
    .intr_scl_interference_o(i2c1_intr.scl_interference),
    .intr_sda_interference_o(i2c1_intr.sda_interference),
    .intr_stretch_timeout_o (i2c1_intr.stretch_timeout),
    .intr_sda_unstable_o    (i2c1_intr.sda_unstable),
    .intr_cmd_complete_o    (i2c1_intr.cmd_complete),
    .intr_tx_stretch_o      (i2c1_intr.tx_stretch),
    .intr_tx_threshold_o    (i2c1_intr.tx_threshold),
    .intr_acq_stretch_o     (i2c1_intr.acq_stretch),
    .intr_unexp_stop_o      (i2c1_intr.unexp_stop),
    .intr_host_timeout_o    (i2c1_intr.host_timeout),

    // Tilelink
    .tl_i(tl_i2c1_h2d),
    .tl_o(tl_i2c1_d2h),

    // Clock and reset connections
    .clk_i (clk_peri_i),
    .rst_ni(rst_peri_ni),

    // Misc
    .ram_cfg_i(ram_1p_cfg_i)
  );

  pattgen u_pattgen (
    // Output
    .cio_pda0_tx_o    (cio_pattgen_pda0_tx_o),
    .cio_pda0_tx_en_o (cio_pattgen_pda0_tx_en_o),
    .cio_pcl0_tx_o    (cio_pattgen_pcl0_tx_o),
    .cio_pcl0_tx_en_o (cio_pattgen_pcl0_tx_en_o),
    .cio_pda1_tx_o    (cio_pattgen_pda1_tx_o),
    .cio_pda1_tx_en_o (cio_pattgen_pda1_tx_en_o),
    .cio_pcl1_tx_o    (cio_pattgen_pcl1_tx_o),
    .cio_pcl1_tx_en_o (cio_pattgen_pcl1_tx_en_o),

    // Interrupt
    .intr_done_ch0_o  (pattgen_intr.done_ch0),
    .intr_done_ch1_o  (pattgen_intr.done_ch1),

    // TileLink
    .tl_i             (tl_pattgen_h2d),
    .tl_o             (tl_pattgen_d2h),

    // Clock and reset connections
    .clk_i            (clk_peri_i),
    .rst_ni           (rst_peri_ni)
  );

  pwm u_pwm (
    // Output
    .cio_pwm_o    (cio_pwm_o),
    .cio_pwm_en_o (cio_pwm_en_o),

    // TileLink
    .tl_i         (tl_pwm_h2d),
    .tl_o         (tl_pwm_d2h),

    // Clock and reset connections
    .clk_i        (clk_peri_i),
    .clk_core_i   (clk_sys_i),
    .rst_ni       (rst_peri_ni),
    .rst_core_ni  (rst_sys_ni)
  );

  rv_plic u_rv_plic (
    .msip_o     (rv_plic_msip),

    // Interrupt notification to targets
    .irq_o      (rv_plic_irq),
    .irq_id_o   (),

    // Interrupt Sources
    .intr_src_i (intr_vector),

    // TileLink
    .tl_i       (tl_rv_plic_h2d),
    .tl_o       (tl_rv_plic_d2h),

    // Clock and reset connections
    .clk_i      (clk_sys_i),
    .rst_ni     (rst_sys_ni)
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
    .intr_error_o    (spi_host0_intr.error),
    .intr_spi_event_o(spi_host0_intr.spi_event),

    // DMA signal
    .lsio_trigger_o(),

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
    .intr_error_o    (spi_host1_intr.error),
    .intr_spi_event_o(spi_host1_intr.spi_event),

    // DMA signal
    .lsio_trigger_o(),

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
    .intr_tx_watermark_o (uart0_intr.tx_watermark),
    .intr_rx_watermark_o (uart0_intr.rx_watermark),
    .intr_tx_done_o      (uart0_intr.tx_done),
    .intr_rx_overflow_o  (uart0_intr.rx_overflow),
    .intr_rx_frame_err_o (uart0_intr.rx_frame_err),
    .intr_rx_break_err_o (uart0_intr.rx_break_err),
    .intr_rx_timeout_o   (uart0_intr.rx_timeout),
    .intr_rx_parity_err_o(uart0_intr.rx_parity_err),
    .intr_tx_empty_o     (uart0_intr.tx_empty),

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
    .intr_tx_watermark_o (uart1_intr.tx_watermark),
    .intr_rx_watermark_o (uart1_intr.rx_watermark),
    .intr_tx_done_o      (uart1_intr.tx_done),
    .intr_rx_overflow_o  (uart1_intr.rx_overflow),
    .intr_rx_frame_err_o (uart1_intr.rx_frame_err),
    .intr_rx_break_err_o (uart1_intr.rx_break_err),
    .intr_rx_timeout_o   (uart1_intr.rx_timeout),
    .intr_rx_parity_err_o(uart1_intr.rx_parity_err),
    .intr_tx_empty_o     (uart1_intr.tx_empty),

    // Inter-module signals
    .tl_i(tl_uart1_h2d),
    .tl_o(tl_uart1_d2h),

    // Clock and reset connections
    .clk_i (clk_peri_i),
    .rst_ni(rst_peri_ni)
  );

  usbdev u_usbdev (
    // Input
    .cio_sense_i        (cio_usbdev_sense_i),
    .cio_usb_dp_i       (cio_usbdev_usb_dp_i),
    .cio_usb_dn_i       (cio_usbdev_usb_dn_i),
    .usb_rx_d_i         (cio_usbdev_rx_d_i),

    // Output
    .cio_usb_dp_o       (cio_usbdev_usb_dp_o),
    .cio_usb_dp_en_o    (cio_usbdev_usb_dp_en_o),
    .cio_usb_dn_o       (cio_usbdev_usb_dn_o),
    .cio_usb_dn_en_o    (cio_usbdev_usb_dn_en_o),
    .usb_tx_d_o         (cio_usbdev_tx_d_o),
    .usb_tx_se0_o       (cio_usbdev_tx_se0_o),
    .usb_tx_use_d_se0_o (cio_usbdev_tx_use_d_se0_o),
    .usb_dp_pullup_o    (usbdev_dp_pullup),
    .usb_dn_pullup_o    (usbdev_dn_pullup),
    .usb_rx_enable_o    (cio_usbdev_rx_enable_o),

    // Interrupt
    .intr_pkt_received_o    (usbdev_intr.pkt_received),
    .intr_pkt_sent_o        (usbdev_intr.pkt_sent),
    .intr_disconnected_o    (usbdev_intr.disconnected),
    .intr_host_lost_o       (usbdev_intr.host_lost),
    .intr_link_reset_o      (usbdev_intr.link_reset),
    .intr_link_suspend_o    (usbdev_intr.link_suspend),
    .intr_link_resume_o     (usbdev_intr.link_resume),
    .intr_av_out_empty_o    (usbdev_intr.av_out_empty),
    .intr_rx_full_o         (usbdev_intr.rx_full),
    .intr_av_overflow_o     (usbdev_intr.av_overflow),
    .intr_link_in_err_o     (usbdev_intr.link_in_err),
    .intr_rx_crc_err_o      (usbdev_intr.rx_crc_err),
    .intr_rx_pid_err_o      (usbdev_intr.rx_pid_err),
    .intr_rx_bitstuff_err_o (usbdev_intr.rx_bitstuff_err),
    .intr_frame_o           (usbdev_intr.frame),
    .intr_powered_o         (usbdev_intr.powered),
    .intr_link_out_err_o    (usbdev_intr.link_out_err),
    .intr_av_setup_empty_o  (usbdev_intr.av_setup_empty),

    // Inter-module signals
    .usb_ref_val_o          (), //usbdev_usb_ref_val_o),
    .usb_ref_pulse_o        (), //usbdev_usb_ref_pulse_o),

    // AON/Wake functionality not included.
    .usb_aon_suspend_req_o        (usbdev_aon_suspend_req),
    .usb_aon_wake_ack_o           (usbdev_aon_wake_ack),
    .usb_aon_bus_reset_i          (usbdev_aon_bus_reset),
    .usb_aon_sense_lost_i         (usbdev_aon_sense_lost),
    .usb_aon_bus_not_idle_i       (usbdev_aon_bus_not_idle),
    .usb_aon_wake_detect_active_i (usbdev_aon_wake_detect_active),

    // Tilelink
    .tl_i       (tl_usbdev_h2d),
    .tl_o       (tl_usbdev_d2h),

    // Clock and reset connections
    .clk_i      (clk_usb_i),
    .clk_aon_i  (clk_aon_i),
    .rst_ni     (rst_usb_ni),
    .rst_aon_ni (rst_aon_ni),

    // Misc
    .ram_cfg_i  (ram_1p_cfg_i)
  );

  usbdev_aon_wake u_usbdev_aon_wake (
    // Input
    .usb_dp_i                 (cio_usbdev_usb_dp_i),
    .usb_dn_i                 (cio_usbdev_usb_dn_i),
    .usb_sense_i              (cio_usbdev_sense_i),
    .usbdev_dppullup_en_i     (usbdev_dp_pullup),
    .usbdev_dnpullup_en_i     (usbdev_dn_pullup),

    // Output
    .usb_dppullup_en_o        (cio_usbdev_dp_pullup_o),
    .usb_dnpullup_en_o        (cio_usbdev_dn_pullup_o),

    // Inter-module signals
    .wake_ack_aon_i           (usbdev_aon_wake_ack),
    .suspend_req_aon_i        (usbdev_aon_suspend_req),
    .bus_not_idle_aon_o       (usbdev_aon_bus_not_idle),
    .bus_reset_aon_o          (usbdev_aon_bus_reset),
    .sense_lost_aon_o         (usbdev_aon_sense_lost),
    .wake_detect_active_aon_o (usbdev_aon_wake_detect_active),

    // Wakeup request to power management.
    .wake_req_aon_o           (usbdev_aon_wkup_req_o),

    // Clock and reset connections
    .clk_aon_i                (clk_aon_i),
    .rst_aon_ni               (rst_aon_ni)
  );

endmodule
