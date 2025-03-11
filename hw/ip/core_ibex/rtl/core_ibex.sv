module core_ibex #(
  parameter int unsigned      DmHaltAddr      = 32'hDEADBEEF,
  parameter int unsigned      DmExceptionAddr = 32'hDEADBEEF,
  parameter bit               DbgTriggerEn    = 1'b1,
  parameter int unsigned      DbgHwBreakNum   = 2,
  parameter int unsigned      MHPMCounterNum  = 0,
  parameter ibex_pkg::rv32b_e RV32B           = ibex_pkg::RV32BOTEarlGrey
) (
  input clk_i,
  input rst_ni,

  output tlul_pkg::tl_h2d_t tl_corei_h2d_o,
  input  tlul_pkg::tl_d2h_t tl_corei_d2h_i,
  output tlul_pkg::tl_h2d_t tl_cored_h2d_o,
  input  tlul_pkg::tl_d2h_t tl_cored_d2h_i,

  input  tlul_pkg::tl_h2d_t tl_revocation_ram_h2d_i,
  output tlul_pkg::tl_d2h_t tl_revocation_ram_d2h_o,

  input  logic [127:0] hardware_revoker_control_reg_rdata,
  output logic [63:0] hardware_revoker_control_reg_wdata,

  input  logic [31:0] boot_addr_i,

  input  logic        irq_software_i,
  input  logic        irq_timer_i,
  input  logic        irq_external_i,
  input  logic [14:0] irq_fast_i,
  input  logic        irq_nm_i,

  // peripheral interface access
  input  tlul_pkg::tl_h2d_t cfg_tl_d_i,
  output tlul_pkg::tl_d2h_t cfg_tl_d_o,

  input prim_ram_2p_pkg::ram_2p_cfg_t ram_2p_cfg_i
);
  localparam int unsigned RevTagDepth =
    1 << (top_chip_system_pkg::SRAMAddrWidth - 3 - $clog2(top_pkg::TL_DW));

  localparam int unsigned RevTagAddrWidth = $clog2(RevTagDepth);

  logic                      core_instr_req;
  logic                      core_instr_gnt;
  logic                      core_instr_rvalid;
  logic [top_pkg::TL_AW-1:0] core_instr_addr;
  logic [top_pkg::TL_DW-1:0] core_instr_rdata;
  logic                      core_instr_err;

  logic                      core_data_req;
  logic                      core_data_we;
  logic                      core_data_gnt;
  logic                      core_data_rvalid;
  logic [top_pkg::TL_AW-1:0] core_data_addr;
  logic [top_pkg::TL_DW:0]   core_data_rdata;
  logic [top_pkg::TL_DW:0]   core_data_wdata;
  logic [3:0]                core_data_be;
  logic                      core_data_err;

  logic                      tsmap_cs;
  logic [15:0]               tsmap_addr;
  logic [top_pkg::TL_DW-1:0] tsmap_rdata;

  ibexc_top_tracing #(
    .DmHaltAddr     (DmHaltAddr),
    .DmExceptionAddr(DmExceptionAddr),
    .DbgTriggerEn   (DbgTriggerEn),
    .DbgHwBreakNum  (DbgHwBreakNum),
    .MHPMCounterNum (MHPMCounterNum),
    .HeapBase       (tl_main_pkg::ADDR_SPACE_SRAM),
    .TSMapBase      (tl_main_pkg::ADDR_SPACE_REVOCATION_RAM),
    .TSMapSize      (RevTagDepth),
    .RV32B          (RV32B)
  ) u_ibex_top_tracing (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    .test_en_i  (1'b0),
    .scan_rst_ni(1'b1),
    // RAM config unused, required for ICache RAMs that aren't present in sunburst chip
    .ram_cfg_i  ('0),

    .cheri_pmode_i   (1'b1),
    .cheri_tsafe_en_i(1'b1),
    .cheri_err_o     (),

    .hart_id_i  (32'b0),
    // First instruction executed is at 0x0010_0000 + 0x80.
    .boot_addr_i(boot_addr_i),

    .instr_req_o       (core_instr_req),
    .instr_gnt_i       (core_instr_gnt),
    .instr_rvalid_i    (core_instr_rvalid),
    .instr_addr_o      (core_instr_addr),
    .instr_rdata_i     (core_instr_rdata),
    .instr_rdata_intg_i('0),
    .instr_err_i       (core_instr_err),

    .data_req_o       (core_data_req),
    .data_is_cap_o    (),
    .data_gnt_i       (core_data_gnt),
    .data_rvalid_i    (core_data_rvalid),
    .data_we_o        (core_data_we),
    .data_be_o        (core_data_be),
    .data_addr_o      (core_data_addr),
    .data_wdata_o     (core_data_wdata),
    .data_wdata_intg_o(),
    .data_rdata_i     (core_data_rdata),
    .data_rdata_intg_i('0),
    .data_err_i       (core_data_err),

    .tsmap_cs_o   (tsmap_cs),
    .tsmap_addr_o (tsmap_addr),
    .tsmap_rdata_i(tsmap_rdata),

    .mmreg_corein_i   (hardware_revoker_control_reg_rdata),
    .mmreg_coreout_o  (hardware_revoker_control_reg_wdata),
    .cheri_fatal_err_o(),

    .irq_software_i(irq_software_i),
    .irq_timer_i   (irq_timer_i),
    .irq_external_i(irq_external_i),
    .irq_fast_i    (irq_fast_i),
    .irq_nm_i      (irq_nm_i),

    .scramble_key_valid_i('0),
    .scramble_key_i      ('0),
    .scramble_nonce_i    ('0),
    .scramble_req_o      (),

    .debug_req_i        (1'b0),
    .crash_dump_o       (),
    .double_fault_seen_o(),

    .fetch_enable_i        ('1),
    .alert_minor_o         (),
    .alert_major_internal_o(),
    .alert_major_bus_o     (),
    .core_sleep_o          ()
  );

  tlul_adapter_host ibex_instr_host_adapter (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    .req_i       (core_instr_req),
    .gnt_o       (core_instr_gnt),
    .addr_i      (core_instr_addr),
    .we_i        ('0),
    .wdata_i     ('0),
    .wdata_cap_i ('0),
    .wdata_intg_i('0),
    .be_i        ('0),
    .instr_type_i(prim_mubi_pkg::MuBi4True),

    .valid_o     (core_instr_rvalid),
    .rdata_o     (core_instr_rdata),
    .rdata_cap_o (),
    .rdata_intg_o(),
    .err_o       (core_instr_err),
    .intg_err_o  (),

    .tl_o(tl_corei_h2d_o),
    .tl_i(tl_corei_d2h_i)
  );

  tlul_adapter_host ibex_data_host_adapter (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    .req_i       (core_data_req),
    .gnt_o       (core_data_gnt),
    .addr_i      (core_data_addr),
    .we_i        (core_data_we),
    .wdata_i     (core_data_wdata[top_pkg::TL_DW-1:0]),
    .wdata_cap_i (core_data_wdata[top_pkg::TL_DW]),
    .wdata_intg_i('0),
    .be_i        (core_data_be),
    .instr_type_i(prim_mubi_pkg::MuBi4False),

    .valid_o     (core_data_rvalid),
    .rdata_o     (core_data_rdata[top_pkg::TL_DW-1:0]),
    .rdata_cap_o (core_data_rdata[top_pkg::TL_DW]),
    .rdata_intg_o(),
    .err_o       (core_data_err),
    .intg_err_o  (),

    .tl_o(tl_cored_h2d_o),
    .tl_i(tl_cored_d2h_i)
  );

  /////////////////////////////////////
  // The carved out space is for DV emulation purposes only
  /////////////////////////////////////

  import tlul_pkg::tl_h2d_t;
  import tlul_pkg::tl_d2h_t;
  localparam int TlH2DWidth = $bits(tl_h2d_t);
  localparam int TlD2HWidth = $bits(tl_d2h_t);

  logic [TlH2DWidth-1:0] tl_win_h2d_int;
  logic [TlD2HWidth-1:0] tl_win_d2h_int;
  tl_d2h_t tl_win_d2h_err_rsp;

  prim_buf #(
    .Width(TlH2DWidth)
  ) u_tlul_req_buf (
    .in_i(cfg_tl_d_i),
    .out_o(tl_win_h2d_int)
  );

  prim_buf #(
    .Width(TlD2HWidth)
  ) u_tlul_rsp_buf (
    .in_i(tl_win_d2h_err_rsp),
    .out_o(tl_win_d2h_int)
  );

  // Interception point for connecting simulation SRAM by disconnecting the tl_d output. The
  // disconnection is done only if `SYNTHESIS is NOT defined AND `RV_CORE_IBEX_SIM_SRAM is
  // defined.
  // This define is used only for verilator as verilator does not support forces.
`ifdef RV_CORE_IBEX_SIM_SRAM
`ifdef SYNTHESIS
  // Induce a compilation error by instantiating a non-existent module.
  illegal_preprocessor_branch_taken u_illegal_preprocessor_branch_taken();
`endif
`else
  assign cfg_tl_d_o = tl_d2h_t'(tl_win_d2h_int);
`endif

  tlul_err_resp u_sim_win_rsp (
    .clk_i,
    .rst_ni,
    .tl_h_i(tl_h2d_t'(tl_win_h2d_int)),
    .tl_h_o(tl_win_d2h_err_rsp)
  );

  logic                       revocation_ram_req;
  logic                       revocation_ram_we;
  logic                       revocation_ram_rvalid;
  logic [RevTagAddrWidth-1:0] revocation_ram_addr;
  logic [top_pkg::TL_DW-1:0]  revocation_ram_wdata;
  logic [top_pkg::TL_DW-1:0]  revocation_ram_wmask;
  logic [top_pkg::TL_DW-1:0]  revocation_ram_rdata;

  tlul_adapter_sram #(
    .SramAw          (RevTagAddrWidth),
    .EnableRspIntgGen(1)
  ) revocation_sram_adapter (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    // TL-UL interface.
    .tl_i(tl_revocation_ram_h2d_i),
    .tl_o(tl_revocation_ram_d2h_o),

    // Control interface.
    .en_ifetch_i(prim_mubi_pkg::MuBi4False),

    // SRAM interface.
    .req_o       (revocation_ram_req),
    .req_type_o  (),
    .gnt_i       (revocation_ram_req),
    .we_o        (revocation_ram_we),
    .addr_o      (revocation_ram_addr),
    .wdata_o     (revocation_ram_wdata),
    .wdata_cap_o (),
    .wmask_o     (revocation_ram_wmask),
    .intg_error_o(),
    .rdata_i     (revocation_ram_rdata),
    .rdata_cap_i (1'b0),
    .rvalid_i    (revocation_ram_rvalid),
    .rerror_i    (2'b00),

    .compound_txn_in_progress_o(),
    .readback_en_i             (prim_mubi_pkg::MuBi4False),
    .readback_error_o          (),
    .wr_collision_i            (1'b0),
    .write_pending_i           (1'b0)
  );

  prim_ram_2p #(
    .Depth          (RevTagDepth),
    .Width          (top_pkg::TL_DW),
    .DataBitsPerMask(8)
  ) u_revocation_ram (
    .clk_a_i(clk_i),
    .clk_b_i(clk_i),

    .a_req_i  (revocation_ram_req),
    .a_write_i(revocation_ram_we),
    .a_addr_i (revocation_ram_addr),
    .a_wdata_i(revocation_ram_wdata),
    .a_wmask_i(revocation_ram_wmask),
    .a_rdata_o(revocation_ram_rdata),

    .b_req_i  (tsmap_cs),
    .b_write_i(1'b0),
    .b_wmask_i('0),
    .b_addr_i (tsmap_addr[RevTagAddrWidth-1:0]),
    .b_wdata_i('0),
    .b_rdata_o(tsmap_rdata),

    .cfg_i(ram_2p_cfg_i)
  );

  logic unused_tsmap_addr;

  assign unused_tsmap_addr = ^tsmap_addr[15:RevTagAddrWidth];

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      revocation_ram_rvalid <= 1'b0;
    end else begin
      revocation_ram_rvalid <= revocation_ram_req & ~revocation_ram_we;
    end
  end
endmodule
