// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module intr_ctrl (
  input clk_i,
  input rst_ni,

  output  logic        ibex_irq_software_o,
  output  logic        ibex_irq_timer_o,
  output  logic        ibex_irq_external_o,
  output  logic [14:0] ibex_irq_fast_o,
  output  logic        ibex_irq_nm_o,

  input [31:0] gpio_intr_i,

  input top_chip_system_pkg::aon_timer_intr_t aon_timer_intr_i,
  input logic                                 aon_timer_nmi_wdog_timer_bark_i,

  input logic rv_timer_intr_i,

  input top_chip_system_pkg::i2c_intr_t i2c0_intr_i,
  input top_chip_system_pkg::i2c_intr_t i2c1_intr_i,

  input top_chip_system_pkg::spi_host_intr_t spi_host0_intr_i,
  input top_chip_system_pkg::spi_host_intr_t spi_host1_intr_i,

  input top_chip_system_pkg::uart_intr_t uart0_intr_i,
  input top_chip_system_pkg::uart_intr_t uart1_intr_i
);
  // Basic registered pass-through interrupt 'controller'. Acts as a stand-in
  // for a real interrupt controller in advance of one being created.

  logic        ibex_irq_software_unsync;
  logic        ibex_irq_timer_unsync;
  logic        ibex_irq_external_unsync;
  logic [14:0] ibex_irq_fast_unsync;
  logic        ibex_irq_nm_unsync;

  assign ibex_irq_software_unsync = 1'b0;
  assign ibex_irq_timer_unsync    = rv_timer_intr_i;
  assign ibex_irq_external_unsync = 1'b0;

  assign ibex_irq_fast_unsync = {
    7'b0,
    |gpio_intr_i,
    |aon_timer_intr_i,
    |i2c0_intr_i,
    |i2c1_intr_i,
    |spi_host0_intr_i,
    |spi_host1_intr_i,
    |uart0_intr_i,
    |uart1_intr_i
  };

  assign ibex_irq_nm_unsync = aon_timer_nmi_wdog_timer_bark_i;

  prim_flop_2sync #(
    .Width(1)
  ) u_ibex_irq_software_sync (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    .d_i(ibex_irq_software_unsync),
    .q_o(ibex_irq_software_o)
  );

  prim_flop_2sync #(
    .Width(1)
  ) u_ibex_irq_timer_sync (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    .d_i(ibex_irq_timer_unsync),
    .q_o(ibex_irq_timer_o)
  );

  prim_flop_2sync #(
    .Width(1)
  ) u_ibex_irq_external_sync (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    .d_i(ibex_irq_external_unsync),
    .q_o(ibex_irq_external_o)
  );

  prim_flop_2sync #(
    .Width(15)
  ) u_ibex_irq_fast_sync (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    .d_i(ibex_irq_fast_unsync),
    .q_o(ibex_irq_fast_o)
  );

  prim_flop_2sync #(
    .Width(1)
  ) u_ibex_irq_nm_sync (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    .d_i(ibex_irq_nm_unsync),
    .q_o(ibex_irq_nm_o)
  );
endmodule
