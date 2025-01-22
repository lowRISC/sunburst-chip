// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class top_chip_dv_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(top_chip_dv_virtual_sequencer)
  `uvm_component_new

  top_chip_dv_env_cfg   cfg;
  top_chip_dv_if_bundle ifs;

  mem_bkdr_util mem_bkdr_util_h[chip_mem_e];

  // Handles to specific interface agent sequencers. Used by some virtual
  // sequences to drive RX (to-chip) items.
  uart_sequencer       uart_sequencer_hs[NUarts];

  // FIFOs for monitor output. Used by some virtual sequences to check
  // TX (from-chip) items.
  uvm_tlm_analysis_fifo #(pattgen_item) pattgen_rx_fifo[NUM_PATTGEN_CHANNELS];
  uvm_tlm_analysis_fifo #(uart_item)    uart_tx_fifos[NUarts];

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    foreach (pattgen_rx_fifo[i]) pattgen_rx_fifo[i] = new($sformatf("pattgen_rx_fifo%0d", i), this);
    foreach (uart_tx_fifos[i]) uart_tx_fifos[i] = new($sformatf("uart_tx_fifo%0d", i), this);
  endfunction
endclass
