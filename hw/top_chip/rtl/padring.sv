// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module padring
  import prim_pad_wrapper_pkg::*;
#(
  parameter int NPads = 64
) (
  input                           clk_scan_i,
  prim_mubi_pkg::mubi4_t          scanmode_i,

  inout  wire  [NPads-1:0] pad_io,

  input  logic [NPads-1:0] pad_out_i,
  input  logic [NPads-1:0] pad_oe_i,
  output logic [NPads-1:0] pad_in_o,
  input  pad_attr_t        pad_attr_i [NPads]
);

  for(genvar i_pad = 0; i_pad < NPads; i_pad++) begin : g_pads
    prim_generic_pad_wrapper #(
      .PadType(BidirStd)
    ) u_pad_wrapper (
      .clk_scan_i,
      .scanmode_i(1'b0),

      .pok_i   ('1),
      .inout_io(pad_io[i_pad]),
      .in_o    (pad_in_o[i_pad]),
      .in_raw_o(),
      .ie_i    (1'b1),
      .out_i   (pad_out_i[i_pad]),
      .oe_i    (pad_oe_i[i_pad]),
      .attr_i  (pad_attr_i[i_pad])
    );
  end
endmodule
