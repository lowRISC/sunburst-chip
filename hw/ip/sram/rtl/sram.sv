// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module sram #(
  // Employ a single tag bit per 64-bit capability?
  parameter int unsigned SingleTagPerCap = 1,
  // (Byte-addressable) address width of the SRAM.
  parameter int unsigned AddrWidth = 17,
  parameter              InitFile  = ""
) (
  input  logic clk_i,
  input  logic rst_ni,

  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o,

  input prim_ram_1p_pkg::ram_1p_cfg_t ram_1p_cfg_i
);
  localparam int unsigned DataWidth = top_pkg::TL_DW;
  // 1 mask bit per byte always for tile-link accessible SRAM
  localparam int unsigned DataBitsPerMask = 8;
  // Bit offset of word address.
  localparam int unsigned AOff = $clog2(DataWidth / 8);
  // Number of address bits to select a word from the SRAM.
  localparam int unsigned SramAw = AddrWidth - AOff;

  // There may be a single capability tag bit for every 64 bits of data;
  // bus words may be at most 64 bits wide and the tag bit associated with
  // the group of 64 bits is updated on every write to any of those 64 bits.
  //
  // When storing a capability (CSC instruction) the tag bit will be written
  // as 1 for each (partial) write of the capability.
  //
  // For all non-capability stores the tag bit will be cleared, marking those
  // 64 bits as not containing a valid capability.
  localparam int unsigned TOff = (SingleTagPerCap == 1) ? (3 - AOff) : 0;

  logic                 mem_req;
  logic                 mem_we;
  logic [SramAw-1:0]    mem_addr;  // in bus words.
  logic [DataWidth-1:0] mem_wmask;
  logic [DataWidth-1:0] mem_wdata;
  logic                 mem_wcap;
  logic                 mem_rvalid;
  logic [DataWidth-1:0] mem_rdata;
  logic                 mem_rcap;

  // TL-UL device adapters
  tlul_adapter_sram #(
    .SramAw          (SramAw),
    .EnableRspIntgGen(1     )
  ) sram_adapter (
    .clk_i,
    .rst_ni,

    // TL-UL interface.
    .tl_i(tl_i),
    .tl_o(tl_o),

    // Control interface.
    .en_ifetch_i(prim_mubi_pkg::MuBi4True),

    // SRAM interface.
    .req_o       (mem_req),
    .req_type_o  (),
    .gnt_i       (mem_req),
    .we_o        (mem_we),
    .addr_o      (mem_addr),
    .wdata_o     (mem_wdata),
    .wdata_cap_o (mem_wcap),
    .wmask_o     (mem_wmask),
    .intg_error_o(),
    .rdata_i     (mem_rdata),
    .rdata_cap_i (mem_rcap),
    .rvalid_i    (mem_rvalid),
    .rerror_i    (2'b00),

    .compound_txn_in_progress_o(),
    .readback_en_i             (prim_mubi_pkg::MuBi4False),
    .readback_error_o          (),
    .wr_collision_i            (1'b0),
    .write_pending_i           (1'b0)
  );

  // Instantiate RAM blocks

  // Number of words in data memory.
  localparam int unsigned DataRamDepth = 2 ** SramAw;
  localparam int unsigned TagRamDepth  = DataRamDepth >> TOff;

  // Data memory
  prim_ram_1p #(
    .Width          (DataWidth),
    .DataBitsPerMask(DataBitsPerMask),
    .Depth          (DataRamDepth),
    .MemInitFile    (InitFile)
  ) u_ram (
    .clk_i(clk_i),

    .req_i  (mem_req),
    .write_i(mem_we),
    .addr_i (mem_addr),
    .wdata_i(mem_wdata),
    .wmask_i(mem_wmask),
    .rdata_o(mem_rdata),

    .cfg_i(ram_1p_cfg_i)
  );

  // Tag memory
  prim_ram_1p #(
    .Width (1),
    .Depth(TagRamDepth)
  ) u_cap_ram (
    .clk_i(clk_i),

    .req_i  (mem_req),
    .write_i(mem_we),
    .addr_i (mem_addr[SramAw-1:TOff]),
    .wdata_i(mem_wcap),
    .wmask_i(mem_we),
    .rdata_o(mem_rcap),

    .cfg_i(ram_1p_cfg_i)
  );

  // Single-cycle read response.
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      mem_rvalid <= '0;
    end else begin
      mem_rvalid <= mem_req & ~mem_we;
    end
  end
endmodule
