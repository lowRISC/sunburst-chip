// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module clk_osc #(
  parameter int unsigned ClkFreq = 100_000_000,
  parameter int unsigned StartDelayNs = 110
) (
  input clk_en,
  output clk_o
);
  timeunit  1ns / 1ps;

  parameter real ClkPeriod = 1_000_000_000.0 / ClkFreq;

  logic clk;

  initial begin
    clk = 1'b0;
    #StartDelayNs;

    forever begin
      #(ClkPeriod/2);
      if (clk_en) begin
        clk = ~clk;
      end else begin
        clk = 1'b0;
      end
    end
  end

  assign clk_o = clk;
endmodule
