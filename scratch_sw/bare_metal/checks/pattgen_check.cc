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
#include "../common/backdoor.hh"
#include "../common/sunburst_pattgen.hh"
#include "../common/sunburst_plic.hh"
#include "../common/sunburst-devices.hh"
#include "../common/uart-utils.hh"

using namespace CHERI;

// Following volatile const will be overwritten by
// SV testbench with random values.
// 1: channel 0, 2: channel 1, 3: Both channels
DEFINE_BACKDOOR_VAR(uint8_t, kChannelEnable, 3)

DEFINE_BACKDOOR_VAR(uint8_t, kPattPol0, 0)
DEFINE_BACKDOOR_VAR(uint8_t, kPattInactiveLevelPda0, 1)
DEFINE_BACKDOOR_VAR(uint8_t, kPattInactiveLevelPcl0, 1)
DEFINE_BACKDOOR_VAR(uint32_t, kPattDiv0, 2)
DEFINE_BACKDOOR_VAR(uint32_t, kPattLower0, 0xF0F0F0F0u)
DEFINE_BACKDOOR_VAR(uint32_t, kPattUpper0, 0x11111111u)
DEFINE_BACKDOOR_VAR(uint8_t, kPattLen0, 0x40u)
DEFINE_BACKDOOR_VAR(uint16_t, kPattRep0, 0x004u)

DEFINE_BACKDOOR_VAR(uint8_t, kPattPol1, 1)
DEFINE_BACKDOOR_VAR(uint8_t, kPattInactiveLevelPda1, 0)
DEFINE_BACKDOOR_VAR(uint8_t, kPattInactiveLevelPcl1, 0)
DEFINE_BACKDOOR_VAR(uint32_t, kPattDiv1, 2)
DEFINE_BACKDOOR_VAR(uint32_t, kPattLower1, 0xF0F0F0F0u)
DEFINE_BACKDOOR_VAR(uint32_t, kPattUpper1, 0x11111111u)
DEFINE_BACKDOOR_VAR(uint8_t, kPattLen1, 0x40u)
DEFINE_BACKDOOR_VAR(uint16_t, kPattRep1, 0x004u)

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

  CHERI::Capability<volatile uint32_t> status = root.cast<volatile uint32_t>();
  status.address() = 0x811F0080;
  status.bounds() = 4;

  // TODO: Randomise use_interrupts somehow.
  // Select between interrupt-based or polling-based channel-done detection
  bool use_interrupts = true;

  // Set up pattgen to emit some test patterns.
  pattgen->predividerCh0 = BACKDOOR_VAR(kPattDiv0);
  pattgen->predividerCh1 = BACKDOOR_VAR(kPattDiv1);
  pattgen->dataCh0_0 = BACKDOOR_VAR(kPattLower0);
  pattgen->dataCh0_1 = BACKDOOR_VAR(kPattUpper0);
  pattgen->dataCh1_0 = BACKDOOR_VAR(kPattLower1);
  pattgen->dataCh1_1 = BACKDOOR_VAR(kPattUpper1);
  // Emit each pattern four times
  pattgen->size = (
    ((BACKDOOR_VAR(kPattRep1) - 1u) << 22) |
    ((BACKDOOR_VAR(kPattLen1) - 1u) << 16) |
    ((BACKDOOR_VAR(kPattRep0) - 1u) <<  6) |
     (BACKDOOR_VAR(kPattLen0) - 1u)
  );

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

  // Configure clock polarities and inactive levels.
  pattgen->ctrl = (
    (BACKDOOR_VAR(kPattInactiveLevelPda1) << 7) |
    (BACKDOOR_VAR(kPattInactiveLevelPcl1) << 6) |
    (BACKDOOR_VAR(kPattInactiveLevelPda0) << 5) |
    (BACKDOOR_VAR(kPattInactiveLevelPcl0) << 4) |
    (BACKDOOR_VAR(kPattPol1) << 3) |
    (BACKDOOR_VAR(kPattPol0) << 2)
  );

  // Signal start of test
  *status = 0x4354u; // 'test'

  // Enable pattern output.
  // NOTE: other fields are ignored when setting the enable bit.
  pattgen->ctrl = BACKDOOR_VAR(kChannelEnable);

  // Wait for pattgen to complete
  if (use_interrupts) {
    while (pattgen_ch_done != BACKDOOR_VAR(kChannelEnable));
  } else {
    while (pattgen->interruptState != BACKDOOR_VAR(kChannelEnable));
  }

  // Signal test end to UVM testbench
  *status = 0x900d; // 'good'

  while (true) asm volatile("wfi");
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
