#!/bin/bash
# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
set -e

TOP_CHIP_DIR=hw/top_chip
XBAR_DATA_DIR=$TOP_CHIP_DIR/data
XBAR_MAIN_DIR=$TOP_CHIP_DIR/ip/xbar_main
XBAR_PERI_DIR=$TOP_CHIP_DIR/ip/xbar_peri
echo "Generating main crossbar"
hw/vendor/lowrisc_ip/util/tlgen.py -t "$XBAR_DATA_DIR"/xbar_main.hjson -o "$XBAR_MAIN_DIR"
echo "Generating peripheral crossbar"
hw/vendor/lowrisc_ip/util/tlgen.py -t $XBAR_DATA_DIR/xbar_peri.hjson -o "$XBAR_PERI_DIR"
