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
  wire IO57;
  wire IO58;
  wire IO59;
  wire IO60;
  wire IO61;
  wire IO62;
  wire IO63;

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
    .IO57,
    .IO58,
    .IO59,
    .IO60,
    .IO61,
    .IO62,
    .IO63,

    .USB_P,
    .USB_N
  );

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

  if (`PRIM_DEFAULT_IMPL == prim_pkg::ImplGeneric) begin : gen_generic
    initial begin
      chip_mem_e    mem;
      mem_bkdr_util m_mem_bkdr_util[chip_mem_e];

      m_mem_bkdr_util[ChipMemSRAM] = new(
        .name ("mem_bkdr_util[ChipMemSRAM]"),
        .path (`DV_STRINGIFY(`SRAM_MEM_HIER)),
        .depth ($size(`SRAM_MEM_HIER)),
        .n_bits($bits(`SRAM_MEM_HIER)),
        .err_detection_scheme(mem_bkdr_util_pkg::ErrDetectionNone),
        .system_base_addr    (tl_main_pkg::ADDR_SPACE_SRAM));
      `MEM_BKDR_UTIL_FILE_OP(m_mem_bkdr_util[ChipMemSRAM], `SRAM_MEM_HIER)

      m_mem_bkdr_util[ChipMemROM] = new(
        .name ("mem_bkdr_util[ChipMemROM]"),
        .path (`DV_STRINGIFY(`ROM_MEM_HIER)),
        .depth ($size(`ROM_MEM_HIER)),
        .n_bits($bits(`ROM_MEM_HIER)),
        .err_detection_scheme(mem_bkdr_util_pkg::ErrDetectionNone),
        .system_base_addr    (tl_main_pkg::ADDR_SPACE_ROM));
      `MEM_BKDR_UTIL_FILE_OP(m_mem_bkdr_util[ChipMemROM], `ROM_MEM_HIER)

      mem = mem.first();
      do begin
        uvm_config_db#(mem_bkdr_util)::set(
            null, "*.env", m_mem_bkdr_util[mem].get_name(), m_mem_bkdr_util[mem]);
        mem = mem.next();
      end while (mem != mem.first());
    end
  end : gen_generic

  initial begin
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

    uvm_config_db#(virtual pins_if#(NGpioPins))::set(null, "*", "gpio_pins_vif", gpio_pins_if);

    run_test();
  end

  uartdpi #(
    .BAUD(UartDpiBaud),
    .FREQ(top_chip_system_pkg::PeriClkFreq)
  ) u_uartdpi0 (
    .clk_i(u_dut.clk_peri),
    .rst_ni(u_dut.rst_peri_n),
    .active(1'b1),
    .tx_o(IO59),
    .rx_i(IO60)
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

    .usb_vbus         (IO63),
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
