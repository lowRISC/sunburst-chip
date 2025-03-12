// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/runtime/irq.h"

#include "sw/device/lib/base/csr.h"

static const uint32_t IRQ_EXT_ENABLE_OFFSET = 11;
static const uint32_t IRQ_TIMER_ENABLE_OFFSET = 7;
static const uint32_t IRQ_SW_ENABLE_OFFSET = 3;

void irq_set_vector_offset(uintptr_t address) {
  CSR_WRITE(CSR_REG_MTVEC, (uint32_t)address);
}

// Global interrupt enable function has been converted to a macro.
// See irq.h for explanation and macro definition equivalent to:
// void irq_global_ctrl(bool en);

void irq_external_ctrl(bool en) {
  const uint32_t mask = 1 << IRQ_EXT_ENABLE_OFFSET;
  if (en) {
    CSR_SET_BITS(CSR_REG_MIE, mask);
  } else {
    CSR_CLEAR_BITS(CSR_REG_MIE, mask);
  }
}

void irq_timer_ctrl(bool en) {
  const uint32_t mask = 1 << IRQ_TIMER_ENABLE_OFFSET;
  if (en) {
    CSR_SET_BITS(CSR_REG_MIE, mask);
  } else {
    CSR_CLEAR_BITS(CSR_REG_MIE, mask);
  }
}

void irq_software_ctrl(bool en) {
  const uint32_t mask = 1 << IRQ_SW_ENABLE_OFFSET;
  if (en) {
    CSR_SET_BITS(CSR_REG_MIE, mask);
  } else {
    CSR_CLEAR_BITS(CSR_REG_MIE, mask);
  }
}
