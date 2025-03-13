// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//

module tb;
  // dep packages
  import uvm_pkg::*;
  import dv_utils_pkg::*;
  import spi_host_env_pkg::*;
  import spi_host_test_pkg::*;
  import spi_host_reg_pkg::*;
  import lc_ctrl_pkg::*;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  wire clk, rst_n;
  wire [NUM_MAX_INTERRUPTS-1:0] interrupts;
  wire [3:0]                    si_pulldown;
  wire [3:0]                    so_pulldown;
  wire [3:0]                    sio;

  lc_tx_t                       scanmode_i;
  logic                         cio_sck_o;
  logic                         cio_sck_en_o;
  logic [SPI_HOST_NUM_CS-1:0]   cio_csb_o;
  logic [SPI_HOST_NUM_CS-1:0]   cio_csb_en_o;
  logic [3:0]                   cio_sd_o;
  logic [3:0]                   cio_sd_en_o;
  logic [3:0]                   cio_sd_i;
  logic                         intr_error;
  logic                         intr_event;

  // interfaces
  clk_rst_if   clk_rst_if(.clk(clk), .rst_n(rst_n));
  pins_if #(NUM_MAX_INTERRUPTS) intr_if(.pins(interrupts));
  tl_if        tl_if(.clk(clk), .rst_n(rst_n));
  spi_if       spi_if(.rst_n(rst_n), .sio(sio));

  `DV_ALERT_IF_CONNECT()

  // dut
  spi_host # (
    .NumCS(SPI_HOST_NUM_CS)
  ) dut (
    .clk_i                (clk),
    .rst_ni               (rst_n),

    // tl i/f
    .tl_i                 (tl_if.h2d),
    .tl_o                 (tl_if.d2h),
    // spi i/o
    .cio_sck_o            (cio_sck_o),
    .cio_sck_en_o         (cio_sck_en_o),
    .cio_csb_o            (cio_csb_o),
    .cio_csb_en_o         (cio_csb_en_o),
    .cio_sd_o             (cio_sd_o),
    .cio_sd_en_o          (cio_sd_en_o),
    .cio_sd_i             (cio_sd_i),
    // intr i/f
    .intr_error_o         (intr_error),
    .intr_spi_event_o     (intr_event)
  );

  assign cio_sd_i = si_pulldown;

  // configure spi_if i/o
  assign spi_if.sck = (cio_sck_en_o) ? cio_sck_o : 1'bz;
  for (genvar i = 0; i < 4; i++) begin : gen_tri_state
    pullup (weak1) pd_in_i (si_pulldown[i]);
    pullup (weak1) pd_out_i (so_pulldown[i]);
    assign sio[i]  = (cio_sd_en_o[i]) ? cio_sd_o[i] : 'z;
    assign (highz0, pull1) sio[i] = !cio_sd_en_o[i];
    assign si_pulldown[i] = sio[i];

    if (i < SPI_HOST_NUM_CS) begin : gen_drive_csb
      assign spi_if.csb[i] = cio_csb_en_o[i] ? cio_csb_o[i] : 1'b1;
    end
  end

  assign interrupts[SpiHostError] = intr_error;
  assign interrupts[SpiHostEvent] = intr_event;

  initial begin
    // drive clk and rst_n from clk_if
    clk_rst_if.set_active();
    uvm_config_db#(virtual clk_rst_if)::set(null, "*.env", "clk_rst_vif", clk_rst_if);
    uvm_config_db#(intr_vif)::set(null, "*.env", "intr_vif", intr_if);
    uvm_config_db#(virtual tl_if)::set(null, "*.env.m_tl_agent*", "vif", tl_if);
    uvm_config_db#(virtual spi_if)::set(null, "*.env.m_spi_agent*", "vif", spi_if);
    $timeformat(-12, 0, " ps", 12);
    run_test();
  end

endmodule
