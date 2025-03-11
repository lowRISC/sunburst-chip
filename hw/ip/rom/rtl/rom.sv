// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module rom #(
  // (Byte-addressable) address width of the SRAM.
  parameter int unsigned AddrWidth  = 17,
  parameter              InitFile   = ""
) (
  input  logic clk_i,
  input  logic rst_ni,

  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o,

  input prim_rom_pkg::rom_cfg_t rom_cfg_i
);
  localparam int unsigned DataWidth = top_pkg::TL_DW;
  // Bit offset of word address.
  localparam int unsigned AOff = $clog2(DataWidth / 8);
  // Number of address bits to select a word from the SRAM.
  localparam int unsigned RomAw = AddrWidth - AOff;

  logic                 rom_req;
  logic                 rom_we;
  logic [RomAw-1:0]     rom_addr;  // in bus words.
  logic                 rom_rvalid;
  logic [DataWidth-1:0] rom_rdata;

  tlul_adapter_sram #(
    .SramAw          (RomAw),
    .Outstanding     (2),
    .ByteAccess      (0),
    .ErrOnWrite      (1),
    .EnableRspIntgGen(1)
  ) rom_adapter (
    .clk_i,
    .rst_ni,

    // TL-UL interface.
    .tl_i(tl_i),
    .tl_o(tl_o),

    // Control interface.
    .en_ifetch_i(prim_mubi_pkg::MuBi4True),

    // SRAM interface.
    .req_o       (rom_req),
    .req_type_o  (),
    .gnt_i       (rom_req),
    .we_o        (rom_we),
    .addr_o      (rom_addr),
    .wdata_o     (),
    .wdata_cap_o (),
    .wmask_o     (),
    .intg_error_o(),
    .rdata_i     (rom_rdata),
    .rdata_cap_i (1'b0),
    .rvalid_i    (rom_rvalid),
    .rerror_i    (2'b00),

    .compound_txn_in_progress_o(),
    .readback_en_i             (prim_mubi_pkg::MuBi4False),
    .readback_error_o          (),
    .wr_collision_i            (1'b0),
    .write_pending_i           (1'b0)
  );

  localparam int unsigned RomDepth = 2 ** RomAw;

  prim_rom #(
    .Width      (DataWidth),
    .Depth      (RomDepth),
    .MemInitFile(InitFile)
  ) u_rom (
    .clk_i(clk_i),

    .req_i  (rom_req),
    .addr_i (rom_addr),
    .rdata_o(rom_rdata),

    .cfg_i(rom_cfg_i)
  );

  // Single-cycle read response.
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rom_rvalid <= '0;
    end else begin
      rom_rvalid <= rom_req & ~rom_we;
    end
  end
endmodule
