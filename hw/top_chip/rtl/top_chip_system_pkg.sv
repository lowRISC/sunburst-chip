// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

package top_chip_system_pkg;

typedef struct packed {
  logic wkup_timer_expired;
  logic wdog_timer_bark;
} aon_timer_intr_t;

typedef struct packed {
  logic fmt_threshold;
  logic rx_threshold;
  logic acq_threshold;
  logic rx_overflow;
  logic controller_halt;
  logic scl_interference;
  logic sda_interference;
  logic stretch_timeout;
  logic sda_unstable;
  logic cmd_complete;
  logic tx_stretch;
  logic tx_threshold;
  logic acq_stretch;
  logic unexp_stop;
  logic host_timeout;
} i2c_intr_t;

typedef struct packed {
  logic error;
  logic spi_event;
} spi_host_intr_t;

typedef struct packed {
  logic tx_watermark;
  logic rx_watermark;
  logic tx_done;
  logic rx_overflow;
  logic rx_frame_err;
  logic rx_break_err;
  logic rx_timeout;
  logic rx_parity_err;
  logic tx_empty;
} uart_intr_t;

// 512k SRAM must be kept in sync with address space size in crossbar
parameter int unsigned SRAMAddrWidth = 19;
// 4k ROM must be kept in sync with address space size in crossbar
parameter int unsigned ROMAddrWidth = 12;

// 250 MHz System clock
parameter int unsigned SysClkFreq = 250_000_000;
// 50 MHz Peripheral clock
parameter int unsigned PeriClkFreq = 50_000_000;
// 400 kHz always-on clock
parameter int unsigned AonClkFreq = 400_000;

endpackage
