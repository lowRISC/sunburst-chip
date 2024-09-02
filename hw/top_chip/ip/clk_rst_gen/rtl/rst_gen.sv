// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module rst_gen #(
  parameter int unsigned StartWaitNs = 100,
  parameter int unsigned ResetLengthNs = 30,
  parameter bit ActiveLow = 1'b1
) (
  output rst_o
);
  timeunit  1ns / 1ps;

  logic rst;

  initial begin
    rst = ActiveLow;
    #StartWaitNs;
    rst = ~rst;
    #ResetLengthNs;
    rst = ~rst;
  end

  assign rst_o = rst;
endmodule
