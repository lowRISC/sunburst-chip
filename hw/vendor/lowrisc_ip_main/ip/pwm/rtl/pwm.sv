// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`include "prim_assert.sv"

module pwm
  import pwm_reg_pkg::*;
#(
  parameter int                             PhaseCntDw                = 16,
  parameter int                             BeatCntDw                 = 27
) (
  input                       clk_i,
  input                       rst_ni,

  input                       clk_core_i,
  input                       rst_core_ni,

  input                       tlul_pkg::tl_h2d_t tl_i,
  output                      tlul_pkg::tl_d2h_t tl_o,

  output logic [NOutputs-1:0] cio_pwm_o,
  output logic [NOutputs-1:0] cio_pwm_en_o
);

  pwm_reg_pkg::pwm_reg2hw_t reg2hw;

  pwm_reg_top u_reg (
    .clk_i,
    .rst_ni,
    .clk_core_i,
    .rst_core_ni,
    .tl_i             (tl_i),
    .tl_o             (tl_o),
    .reg2hw           (reg2hw)
  );

  assign cio_pwm_en_o = {NOutputs{1'b1}};

  pwm_core #(
    .NOutputs(NOutputs),
    .PhaseCntDw(PhaseCntDw),
    .BeatCntDw(BeatCntDw)
  ) u_pwm_core (
    .clk_core_i,
    .rst_core_ni,
    .reg2hw,
    .pwm_o       (cio_pwm_o)
  );

  `ASSERT_KNOWN(TlDValidKnownO_A, tl_o.d_valid)
  `ASSERT_KNOWN(TlAReadyKnownO_A, tl_o.a_ready)

  `ASSERT_KNOWN(CioPWMKnownO_A, cio_pwm_o)
  `ASSERT(CioPWMEnIsOneO_A, (&cio_pwm_en_o) === 1'b1)
endmodule : pwm
