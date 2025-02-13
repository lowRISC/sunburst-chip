// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Sonata XL package

package top_chip_sonata_xl_pkg;

// System clock frequency for Sonata XL.
// Set to the fastest we can reliably synthesise on the A200T FPGA.
parameter int unsigned SysClkFreq = 40_000_000;

// Number of Instances
localparam int unsigned GPIO_NUM = 1;
localparam int unsigned PWM_NUM = 1;
localparam int unsigned UART_NUM = 2;
localparam int unsigned I2C_NUM = 2;
localparam int unsigned SPI_NUM = 2;

// Width of block IO arrays
localparam int unsigned GPIO_IOS_WIDTH = 32;
localparam int unsigned PWM_OUT_WIDTH = 1;
localparam int unsigned SPI_CS_WIDTH = 1;

// inout pins
localparam int unsigned INOUT_PIN_SCL0        = 0;
localparam int unsigned INOUT_PIN_SDA0        = 1;
localparam int unsigned INOUT_PIN_SCL1        = 2;
localparam int unsigned INOUT_PIN_SDA1        = 3;
localparam int unsigned INOUT_PIN_GPIO_START  = 4;
localparam int unsigned INOUT_PIN_GPIO_END    = 4 + (GPIO_IOS_WIDTH - 1);
localparam int unsigned INOUT_PIN_NUM         = INOUT_PIN_GPIO_END + 1; // number of inout pins

typedef logic [INOUT_PIN_NUM-1:0] sonata_xl_inout_pins_t;

endpackage : top_chip_sonata_xl_pkg
