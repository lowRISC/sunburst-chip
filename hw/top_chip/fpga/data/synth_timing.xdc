## Copyright lowRISC contributors (Sunburst project).
## Licensed under the Apache License, Version 2.0, see LICENSE for details.
## SPDX-License-Identifier: Apache-2.0

# This file is for timing constraints to be applied *before* synthesis.
# i.e. timing constraints on top-level ports.
#
# See UG949 and UG903 for information on setting various timing constraints.

#### Recommended timing constraints sequence from UG949 ####
## Timing Assertions Section
# Primary clocks
# Virtual clocks
# Generated clocks
# Delay for external MMCM/PLL feedback loop
# Clock Uncertainty and Jitter
# Input and output delay constraints
# Clock Groups and Clock False Paths
## Timing Exceptions Section
# False Paths
# Max Delay / Min Delay
# Multicycle Paths
# Case Analysis
# Disable Timing


#### Timing Assertions Section ####

### Primary clocks ###
create_clock -name mainClk -period 40.0   [get_ports mainClk] ;# 40 ns = 25 MHz
# create_clock -name tck     -period 66.666 [get_ports tck_i]   ;# 66 ns = 15 MHz

### Virtual clocks ###
create_clock -name vclk_extusb -period 83.333 ;# 83 ns = 12 MHz (full-speed USB)

### Generated clocks ###
# PLL clocks - name only; period will be derived from RTL parameters.
# All are generated from mainClk.
set clk_sys_source_pin    [get_pins [all_fanin -flat [get_nets clk_sys]] \
                           -filter {name =~ u_clk_rst_gen/pll/CLKOUT*}]
set clk_peri_source_pin   [get_pins [all_fanin -flat [get_nets clk_peri]] \
                           -filter {name =~ u_clk_rst_gen/pll/CLKOUT*}]
set clk_usb_source_pin    [get_pins [all_fanin -flat [get_nets clk_usb]] \
                           -filter {name =~ u_clk_rst_gen/pll/CLKOUT*}]
set clk_aon_source_pin    [get_pins [all_fanin -flat [get_nets clk_aon]] \
                           -filter {name =~ u_clk_rst_gen/pll/CLKOUT*}]
create_generated_clock -name clk_sys   $clk_sys_source_pin
create_generated_clock -name clk_peri  $clk_peri_source_pin
create_generated_clock -name clk_usb   $clk_usb_source_pin
create_generated_clock -name clk_aon   $clk_aon_source_pin
# mainClk and internal clocks generated from it (and thus synchronous with it)
set mainClk_and_generated {mainClk clk_sys clk_peri clk_usb clk_aon}
# I/O clocks
# TODO...

## Virtual clocks based on generated clocks.
# Defined here (after generated clocks) to avoid code constant duplication
create_clock -name vclk_peri -period [get_property period [get_clocks clk_peri]]

### Clock Uncertainty and Jitter ###
# Primary clock comes from ASE-25.000MHZ-L-C-T crystal oscillator.
# Reference Peak to Peak Jitter is 28 ps (with a note to contact ABRACOM)
# and maximum RMS Jitter is 5 ps.
# Use the worst value for now.
set_input_jitter mainClk 0.028

### Input and output delay constraints prep ###
#
## Make handy clock period variables for use in I/O delay constraints
set mainClk_ns [get_property period [get_clocks mainClk]]
# set tck_ns     [get_property period [get_clocks tck]]
# SPI hosts can run as fast as half the rate of clk_sys
set sclk_ns [expr {2 * [get_property period [get_clocks clk_peri]]}]

### Input and output delay constraints proper ###

#
# TODO...
#

### Clock Groups and Clock False Paths ###
# JTAG tck is completely asynchronous to FPGA mainClk and derivatives
# set_clock_groups -asynchronous -group tck -group $mainClk_and_generated

#### Timing Exceptions Section ####

### False Paths ###

## prim_flop_2sync
# Set false_path timing exceptions on 2-stage synchroniser inputs.
# Target the inputs because the flops inside are clocked by the destination.
#
# Reliant on the hierarchical pin names of the synchronisers remaining
# unchanged during synthesis due to use of DONT_TOUCH or KEEP_HIERARCHY.
set sync_cells [get_cells -hier -filter {ORIG_REF_NAME == prim_flop_2sync}]
set sync_pins [get_pins -filter {REF_PIN_NAME =~ d_i*} -of $sync_cells]
# Filter out any that do not have a real timing path (fail to find leaf cell).
set sync_endpoints [filter [all_fanout -endpoints_only -flat $sync_pins] IS_LEAF]
set_false_path -to $sync_endpoints

## prim_fifo_async and prim_fifo_async_simple
# Set false_path timing exceptions on asynchronous fifo outputs.
# Target the outputs because the storage elements are clocked by the source
# clock domain (but made safe to read from the destination clock domain
# thanks to the gray-coded read/write pointers and surrounding logic).
#
# Reliant on the hierarchical pin names used here remaining unchanged during
# synthesis by setting DONT_TOUCH or KEEP_HIERARCHY earlier in the flow.
set async_fifo_cells [get_cells -hier -regexp -filter {ORIG_REF_NAME =~ {prim_fifo_async(_simple)?}}]
set async_fifo_pins [get_pins -filter {REF_PIN_NAME =~ rdata_o*} -of $async_fifo_cells]
set async_fifo_startpoints [all_fanin -startpoints_only -flat $async_fifo_pins]
# Specify `-through` as well as `-from` to avoid including non-rdata_o paths,
# such as paths from the read pointers that stay internal or exit via rvalid_o.
set_false_path -from $async_fifo_startpoints -through $async_fifo_pins

### Max Delay / Min Delay ###

## Reset async-assert sync-deassert CDC - async path to synchroniser reset pins
# Use max_delay rather than false_path to avoid big skew between clock domains.
#
# Reliant on the hierarchical pin names used here remaining unchanged during
# synthesis by setting DONT_TOUCH or KEEP_HIERARCHY earlier in the flow.
set rst_sync_cells [get_cells u_clk_rst_gen/* -filter {ORIG_REF_NAME == prim_flop_2sync}]
set rst_sync_pins [get_pins -filter {REF_PIN_NAME =~ rst_ni} -of $rst_sync_cells]
# Filter out any that do not have a real timing path (fail to find leaf cell).
set rst_sync_endpoints [filter [all_fanout -endpoints_only -flat $rst_sync_pins] IS_LEAF]
set_max_delay 20 -to $rst_sync_endpoints  ;# keep path reasonably short

### Multicycle Paths ###

### Case Analysis ###

### Disable Timing ###
