// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Incidental program for initial bring-up of pattgen chip-level DV.

#define CHERIOT_NO_AMBIENT_MALLOC
#define CHERIOT_NO_NEW_DELETE
#define CHERIOT_PLATFORM_CUSTOM_UART

#include <cheri.hh>
#include <stdint.h>

#include "../common/asm.hh"
#include "../common/platform-gpio.hh"
#include "../common/sunburst_pattgen.hh"
#include "../common/sunburst_plic.hh"
#include "../common/sunburst-devices.hh"
#include "../common/uart-utils.hh"

using namespace CHERI;

PLIC::SunburstPlic *plic;
PattgenPtr pattgen;

volatile uint32_t pattgen_ch_done = 0u;

/**
 * C++ entry point. This is called from assembly, with the read-write root in the first argument.
 */
extern "C" void entry_point(void *rwRoot) {
  CapRoot root{rwRoot};

  PLIC::SunburstPlic _plic(root);
  plic = &_plic;

  pattgen = pattgen_ptr(root);

  auto gpio = gpio_ptr(root);

  // TODO: Use `BACKDOOR_VAR` for pattgen parameters (and use_interrupts?)
  // once SW Symbol Backdoor mechanism has been ported/implemented.

  // Select between interrupt-based or polling-based channel-done detection
  bool use_interrupts = true;

  // Set up pattgen to emit some test patterns.
  pattgen->predividerCh0 = 2;
  pattgen->predividerCh1 = 2;
  pattgen->dataCh0_0 = 0xf0f0f0f0u;
  pattgen->dataCh0_1 = 0x11111111u;
  pattgen->dataCh1_0 = 0xf0f0f0f0u;
  pattgen->dataCh1_1 = 0x11111111u;
  // Emit each pattern four times
  pattgen->size = (0x003u << 22) | (0x3fu << 16) | (0x003u << 6) | 0x3fu;

  if (use_interrupts) {
    // Enable interrupt generation in pattgen
    pattgen->interrupt_enable(SunburstPattgen::SunburstPattgenInterrupt::InterruptDoneCh0);
    pattgen->interrupt_enable(SunburstPattgen::SunburstPattgenInterrupt::InterruptDoneCh1);

    // Enable pattgen interrupts in plic
    plic->interrupt_enable(static_cast<PLIC::Interrupts>(PLIC::Interrupts::Pattgen));
    plic->priority_set(static_cast<PLIC::Interrupts>(PLIC::Interrupts::Pattgen), 1);

    // Enable interrupts in Ibex
    ASM::Ibex::external_interrupt_set(true);
    ASM::Ibex::global_interrupt_set(true);
  }

  // Enable pattern output, and configure clock polarities and inactive levels.
  pattgen->ctrl = 0x3bu;

  // Wait for pattgen to complete
  if (use_interrupts) {
    while (pattgen_ch_done != 0x3u);
  } else {
    while (pattgen->interruptState != 0x3u);
  }

  // Signal test end to UVM testbench
  gpio->set_oe_direct(0xffffffffu);
  gpio->set_out_direct(0xDEADBEEFu);

  while (true);
}

/**
 * Override the default handler
 */
extern "C" void irq_external_handler(void) {
  if (plic == nullptr) return;
  if (auto irq = plic->interrupt_claim()) {
    if (irq == PLIC::Interrupts::Pattgen) {
      // Find out which pattgen channels are done
      auto irq_state = pattgen->interruptState;
      // Report to mainline code
      pattgen_ch_done = pattgen_ch_done | irq_state;
      // Clear interrupt
      pattgen->interruptState = irq_state;
    }
    plic->interrupt_complete(*irq);
  }
}
