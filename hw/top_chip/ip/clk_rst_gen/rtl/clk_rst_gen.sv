// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Generates clocks and resets for the sunburst chip. Simulation only mock-up
// for now.
module clk_rst_gen (
  output clk_sys_o,
  output clk_peri_o,
  output clk_aon_o,

  output rst_sys_n,
  output rst_peri_n,
  output rst_aon_n
);
  clk_osc #(.ClkFreq(top_chip_system_pkg::SysClkFreq)) u_sys_clk_osc (
    .clk_en(1'b1),
    .clk_o(clk_sys_o)
  );

  clk_osc #(.ClkFreq(top_chip_system_pkg::PeriClkFreq)) u_peri_clk_osc (
    .clk_en(1'b1),
    .clk_o(clk_peri_o)
  );

  clk_osc #(.ClkFreq(top_chip_system_pkg::AonClkFreq)) u_aon_clk_osc (
    .clk_en(1'b1),
    .clk_o(clk_aon_o)
  );

  rst_gen u_sys_rst_gen (
    .rst_o(rst_sys_n)
  );

  rst_gen u_peri_rst_gen (
    .rst_o(rst_peri_n)
  );

  rst_gen u_aon_rst_gen (
    .rst_o(rst_aon_n)
  );
endmodule
