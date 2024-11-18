// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// xbar_main module generated by `tlgen.py` tool
// all reset signals should be generated from one reset signal to not make any deadlock
//
// Interconnect
// rv_core_ibex.corei
//   -> s1n_7
//     -> sm1_8
//       -> sram
//     -> sm1_9
//       -> rom
// rv_core_ibex.cored
//   -> s1n_10
//     -> sm1_8
//       -> sram
//     -> sm1_9
//       -> rom
//     -> revocation_ram
//     -> rv_plic
//     -> asf_11
//       -> peri

module xbar_main (
  input clk_sys_i,
  input clk_peri_i,
  input rst_sys_ni,
  input rst_peri_ni,

  // Host interfaces
  input  tlul_pkg::tl_h2d_t tl_rv_core_ibex__corei_i,
  output tlul_pkg::tl_d2h_t tl_rv_core_ibex__corei_o,
  input  tlul_pkg::tl_h2d_t tl_rv_core_ibex__cored_i,
  output tlul_pkg::tl_d2h_t tl_rv_core_ibex__cored_o,

  // Device interfaces
  output tlul_pkg::tl_h2d_t tl_rom_o,
  input  tlul_pkg::tl_d2h_t tl_rom_i,
  output tlul_pkg::tl_h2d_t tl_sram_o,
  input  tlul_pkg::tl_d2h_t tl_sram_i,
  output tlul_pkg::tl_h2d_t tl_revocation_ram_o,
  input  tlul_pkg::tl_d2h_t tl_revocation_ram_i,
  output tlul_pkg::tl_h2d_t tl_rv_plic_o,
  input  tlul_pkg::tl_d2h_t tl_rv_plic_i,
  output tlul_pkg::tl_h2d_t tl_peri_o,
  input  tlul_pkg::tl_d2h_t tl_peri_i,

  input prim_mubi_pkg::mubi4_t scanmode_i
);

  import tlul_pkg::*;
  import tl_main_pkg::*;

  // scanmode_i is currently not used, but provisioned for future use
  // this assignment prevents lint warnings
  logic unused_scanmode;
  assign unused_scanmode = ^scanmode_i;

  tl_h2d_t tl_s1n_7_us_h2d ;
  tl_d2h_t tl_s1n_7_us_d2h ;


  tl_h2d_t tl_s1n_7_ds_h2d [2];
  tl_d2h_t tl_s1n_7_ds_d2h [2];

  // Create steering signal
  logic [1:0] dev_sel_s1n_7;


  tl_h2d_t tl_sm1_8_us_h2d [2];
  tl_d2h_t tl_sm1_8_us_d2h [2];

  tl_h2d_t tl_sm1_8_ds_h2d ;
  tl_d2h_t tl_sm1_8_ds_d2h ;


  tl_h2d_t tl_sm1_9_us_h2d [2];
  tl_d2h_t tl_sm1_9_us_d2h [2];

  tl_h2d_t tl_sm1_9_ds_h2d ;
  tl_d2h_t tl_sm1_9_ds_d2h ;

  tl_h2d_t tl_s1n_10_us_h2d ;
  tl_d2h_t tl_s1n_10_us_d2h ;


  tl_h2d_t tl_s1n_10_ds_h2d [5];
  tl_d2h_t tl_s1n_10_ds_d2h [5];

  // Create steering signal
  logic [2:0] dev_sel_s1n_10;

  tl_h2d_t tl_asf_11_us_h2d ;
  tl_d2h_t tl_asf_11_us_d2h ;
  tl_h2d_t tl_asf_11_ds_h2d ;
  tl_d2h_t tl_asf_11_ds_d2h ;



  assign tl_sm1_8_us_h2d[0] = tl_s1n_7_ds_h2d[0];
  assign tl_s1n_7_ds_d2h[0] = tl_sm1_8_us_d2h[0];

  assign tl_sm1_9_us_h2d[0] = tl_s1n_7_ds_h2d[1];
  assign tl_s1n_7_ds_d2h[1] = tl_sm1_9_us_d2h[0];

  assign tl_sm1_8_us_h2d[1] = tl_s1n_10_ds_h2d[0];
  assign tl_s1n_10_ds_d2h[0] = tl_sm1_8_us_d2h[1];

  assign tl_sm1_9_us_h2d[1] = tl_s1n_10_ds_h2d[1];
  assign tl_s1n_10_ds_d2h[1] = tl_sm1_9_us_d2h[1];

  assign tl_revocation_ram_o = tl_s1n_10_ds_h2d[2];
  assign tl_s1n_10_ds_d2h[2] = tl_revocation_ram_i;

  assign tl_rv_plic_o = tl_s1n_10_ds_h2d[3];
  assign tl_s1n_10_ds_d2h[3] = tl_rv_plic_i;

  assign tl_asf_11_us_h2d = tl_s1n_10_ds_h2d[4];
  assign tl_s1n_10_ds_d2h[4] = tl_asf_11_us_d2h;

  assign tl_s1n_7_us_h2d = tl_rv_core_ibex__corei_i;
  assign tl_rv_core_ibex__corei_o = tl_s1n_7_us_d2h;

  assign tl_sram_o = tl_sm1_8_ds_h2d;
  assign tl_sm1_8_ds_d2h = tl_sram_i;

  assign tl_rom_o = tl_sm1_9_ds_h2d;
  assign tl_sm1_9_ds_d2h = tl_rom_i;

  assign tl_s1n_10_us_h2d = tl_rv_core_ibex__cored_i;
  assign tl_rv_core_ibex__cored_o = tl_s1n_10_us_d2h;

  assign tl_peri_o = tl_asf_11_ds_h2d;
  assign tl_asf_11_ds_d2h = tl_peri_i;

  always_comb begin
    // default steering to generate error response if address is not within the range
    dev_sel_s1n_7 = 2'd2;
    if ((tl_s1n_7_us_h2d.a_address &
         ~(ADDR_MASK_SRAM)) == ADDR_SPACE_SRAM) begin
      dev_sel_s1n_7 = 2'd0;

    end else if ((tl_s1n_7_us_h2d.a_address &
                  ~(ADDR_MASK_ROM)) == ADDR_SPACE_ROM) begin
      dev_sel_s1n_7 = 2'd1;
end
  end

  always_comb begin
    // default steering to generate error response if address is not within the range
    dev_sel_s1n_10 = 3'd5;
    if ((tl_s1n_10_us_h2d.a_address &
         ~(ADDR_MASK_SRAM)) == ADDR_SPACE_SRAM) begin
      dev_sel_s1n_10 = 3'd0;

    end else if ((tl_s1n_10_us_h2d.a_address &
                  ~(ADDR_MASK_ROM)) == ADDR_SPACE_ROM) begin
      dev_sel_s1n_10 = 3'd1;

    end else if ((tl_s1n_10_us_h2d.a_address &
                  ~(ADDR_MASK_REVOCATION_RAM)) == ADDR_SPACE_REVOCATION_RAM) begin
      dev_sel_s1n_10 = 3'd2;

    end else if ((tl_s1n_10_us_h2d.a_address &
                  ~(ADDR_MASK_RV_PLIC)) == ADDR_SPACE_RV_PLIC) begin
      dev_sel_s1n_10 = 3'd3;

    end else if ((tl_s1n_10_us_h2d.a_address &
                  ~(ADDR_MASK_PERI)) == ADDR_SPACE_PERI) begin
      dev_sel_s1n_10 = 3'd4;
end
  end


  // Instantiation phase
  tlul_socket_1n #(
    .HReqDepth (4'h0),
    .HRspDepth (4'h0),
    .DReqDepth (8'h0),
    .DRspDepth (8'h0),
    .N         (2)
  ) u_s1n_7 (
    .clk_i        (clk_sys_i),
    .rst_ni       (rst_sys_ni),
    .tl_h_i       (tl_s1n_7_us_h2d),
    .tl_h_o       (tl_s1n_7_us_d2h),
    .tl_d_o       (tl_s1n_7_ds_h2d),
    .tl_d_i       (tl_s1n_7_ds_d2h),
    .dev_select_i (dev_sel_s1n_7)
  );
  tlul_socket_m1 #(
    .HReqDepth (8'h0),
    .HRspDepth (8'h0),
    .DReqDepth (4'h0),
    .DRspDepth (4'h0),
    .M         (2)
  ) u_sm1_8 (
    .clk_i        (clk_sys_i),
    .rst_ni       (rst_sys_ni),
    .tl_h_i       (tl_sm1_8_us_h2d),
    .tl_h_o       (tl_sm1_8_us_d2h),
    .tl_d_o       (tl_sm1_8_ds_h2d),
    .tl_d_i       (tl_sm1_8_ds_d2h)
  );
  tlul_socket_m1 #(
    .HReqDepth (8'h0),
    .HRspDepth (8'h0),
    .DReqDepth (4'h0),
    .DRspDepth (4'h0),
    .M         (2)
  ) u_sm1_9 (
    .clk_i        (clk_sys_i),
    .rst_ni       (rst_sys_ni),
    .tl_h_i       (tl_sm1_9_us_h2d),
    .tl_h_o       (tl_sm1_9_us_d2h),
    .tl_d_o       (tl_sm1_9_ds_h2d),
    .tl_d_i       (tl_sm1_9_ds_d2h)
  );
  tlul_socket_1n #(
    .HReqDepth (4'h0),
    .HRspDepth (4'h0),
    .DReqDepth (20'h0),
    .DRspDepth (20'h0),
    .N         (5)
  ) u_s1n_10 (
    .clk_i        (clk_sys_i),
    .rst_ni       (rst_sys_ni),
    .tl_h_i       (tl_s1n_10_us_h2d),
    .tl_h_o       (tl_s1n_10_us_d2h),
    .tl_d_o       (tl_s1n_10_ds_h2d),
    .tl_d_i       (tl_s1n_10_ds_d2h),
    .dev_select_i (dev_sel_s1n_10)
  );
  tlul_fifo_async #(
    .ReqDepth        (1),
    .RspDepth        (1)
  ) u_asf_11 (
    .clk_h_i      (clk_sys_i),
    .rst_h_ni     (rst_sys_ni),
    .clk_d_i      (clk_peri_i),
    .rst_d_ni     (rst_peri_ni),
    .tl_h_i       (tl_asf_11_us_h2d),
    .tl_h_o       (tl_asf_11_us_d2h),
    .tl_d_o       (tl_asf_11_ds_h2d),
    .tl_d_i       (tl_asf_11_ds_d2h)
  );

endmodule
