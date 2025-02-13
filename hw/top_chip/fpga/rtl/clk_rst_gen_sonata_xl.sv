// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module clk_rst_gen_sonata_xl  #(
  // Frequency of the board clock fed into the FPGA.
  parameter int unsigned IOClkFreq = 25_000_000
) (
    // Board reset button
    input  rst_btn_ni,

    // Board clock signal
    input  clk_board_i,

    output clk_sys_o,
    output clk_peri_o,
    output clk_usb_o,
    output clk_aon_o,

    output rst_sys_no,
    output rst_peri_no,
    output rst_usb_no,
    output rst_aon_no

);
  logic clk_board_buf;
  logic clk_fb_buf;
  logic clk_fb_unbuf;
  logic clk_sys_buf;
  logic clk_sys_unbuf;
  logic clk_peri_buf;
  logic clk_peri_unbuf;
  logic clk_usb_buf;
  logic clk_usb_unbuf;
  logic clk_aon_buf;
  logic clk_aon_unbuf;

  // Indication that the PLL has stabilized and locked
  logic pll_locked;

  // Reset button signals
  logic rst_btn_buf_n; // buffered
  logic rst_btn_sync_n; // synchronised
  logic rst_btn; // inverted (active-high)

  // Board-clock-synchronous chip reset signal.
  // Combines POR and debounced reset button.
  logic rst_board_n;

  // Input buffers
  IBUF rst_board_ibuf(
    .I (rst_btn_ni),
    .O (rst_btn_buf_n)
  );

  IBUF clk_board_ibuf(
    .I (clk_board_i),
    .O (clk_board_buf)
  );

  // Clock synthesis
  MMCME2_BASE #(
    .BANDWIDTH            ("OPTIMIZED"),
    .STARTUP_WAIT         ("FALSE"),
    // Board clock
    .CLKIN1_PERIOD        (1_000_000_000.0 / IOClkFreq), // nanoseconds
    .DIVCLK_DIVIDE        (1),
    // Feedback clock
    .CLKFBOUT_MULT_F      (48),
    .CLKFBOUT_PHASE       (0.000),
    // clk_sys output - will differ from simulations due to FPGA limitations.
    // CLKOUT0 is unique in supporting fractional divisors at 0.125 resolution.
    .CLKOUT0_DIVIDE_F     ((48.0 * IOClkFreq) / top_chip_sonata_xl_pkg::SysClkFreq),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    // clk_peri output
    .CLKOUT1_DIVIDE       ((48 * IOClkFreq) / top_chip_system_pkg::PeriClkFreq),
    .CLKOUT1_PHASE        (0.000),
    .CLKOUT1_DUTY_CYCLE   (0.500),
    // clk_usb output
    .CLKOUT2_DIVIDE       ((48 * IOClkFreq) / top_chip_system_pkg::UsbClkFreq),
    .CLKOUT2_PHASE        (0.000),
    .CLKOUT2_DUTY_CYCLE   (0.500),
    // Cascade CLKOUT6 output to CLKOUT4 input internally for a greater
    // total divisor in order to reach AonClkFreq. See UG472 for details.
    .CLKOUT4_CASCADE      ("TRUE"),
    // AON First stage - intervening frequency
    // Choose a frequency with a period that is a multiple of the desired
    // AON clock period and that can be generated from the VCO frequency
    // using a divisor within the supported range.
    .CLKOUT6_DIVIDE       ((48 * IOClkFreq) / 20_000_000),
    .CLKOUT6_PHASE        (0.000),
    .CLKOUT6_DUTY_CYCLE   (0.500),
    // AON Second stage - final clk_aon output
    .CLKOUT4_DIVIDE       (20_000_000 / top_chip_system_pkg::AonClkFreq),
    .CLKOUT4_PHASE        (0.000),
    .CLKOUT4_DUTY_CYCLE   (0.500)
  ) pll (
    .CLKFBOUT            (clk_fb_unbuf),
    .CLKFBOUTB           (),
    .CLKOUT0             (clk_sys_unbuf),
    .CLKOUT0B            (),
    .CLKOUT1             (clk_peri_unbuf),
    .CLKOUT1B            (),
    .CLKOUT2             (clk_usb_unbuf),
    .CLKOUT2B            (),
    .CLKOUT3             (),
    .CLKOUT3B            (),
    .CLKOUT4             (clk_aon_unbuf),
    .CLKOUT5             (),
    .CLKOUT6             (/* used for clk_aon intermediate frequency */),
    // Input clock control
    .CLKFBIN             (clk_fb_buf),
    .CLKIN1              (clk_board_buf),
    // Control and status signals
    .LOCKED              (pll_locked),
    .PWRDWN              (1'b0),
    // Do not reset PLL on external reset, otherwise ILA disconnects at a reset
    .RST                 (1'b0)
  );

  // Output buffering
  BUFG clk_fb_bufg (
    .I (clk_fb_unbuf),
    .O (clk_fb_buf)
  );

  BUFG clk_sys_bufg (
    .I (clk_sys_unbuf),
    .O (clk_sys_buf)
  );

  BUFG clk_peri_bufg (
    .I (clk_peri_unbuf),
    .O (clk_peri_buf)
  );

  BUFG clk_usb_bufg (
    .I (clk_usb_unbuf),
    .O (clk_usb_buf)
  );

  BUFG clk_aon_bufg (
    .I (clk_aon_unbuf),
    .O (clk_aon_buf)
  );

  // Clock outputs
  assign clk_sys_o    = clk_sys_buf;
  assign clk_peri_o   = clk_peri_buf;
  assign clk_usb_o    = clk_usb_buf;
  assign clk_aon_o    = clk_aon_buf;

  // Reset button synchronisation and inversion
  prim_flop_2sync #(
    .Width(1)
  ) u_rst_btn_sync (
    .clk_i(clk_board_buf),
    .rst_ni(1'b1),
    .d_i(rst_btn_buf_n),
    .q_o(rst_btn_sync_n)
  );
  assign rst_btn = ~rst_btn_sync_n;

  // Reset generation from power-on and on-board reset button
  rst_ctrl u_rst_ctrl (
    .clk_i       (clk_board_buf),
    .pll_locked_i(pll_locked),
    .rst_btn_i   (rst_btn),
    .rst_no      (rst_board_n)
  );

  // De-assert synchronised resets (asynchronous assertion)
  //
  // clk_sys
  prim_flop_2sync #(
    .Width(1),
    .ResetValue('0)
  ) u_rst_sys_sync (
    .clk_i(clk_sys_buf),
    .rst_ni(rst_board_n),
    .d_i(1'b1),
    .q_o(rst_sys_no)
  );
  // clk_peri
  prim_flop_2sync #(
    .Width(1),
    .ResetValue('0)
  ) u_rst_peri_sync (
    .clk_i(clk_peri_buf),
    .rst_ni(rst_board_n),
    .d_i(1'b1),
    .q_o(rst_peri_no)
  );
  // clk_usb
  prim_flop_2sync #(
    .Width(1),
    .ResetValue('0)
  ) u_rst_usb_sync (
    .clk_i(clk_usb_buf),
    .rst_ni(rst_board_n),
    .d_i(1'b1),
    .q_o(rst_usb_no)
  );
  // clk_aon
  prim_flop_2sync #(
    .Width(1),
    .ResetValue('0)
  ) u_rst_aon_sync (
    .clk_i(clk_aon_buf),
    .rst_ni(rst_board_n),
    .d_i(1'b1),
    .q_o(rst_aon_no)
  );

endmodule
