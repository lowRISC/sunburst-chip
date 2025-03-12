// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef OPENTITAN_SW_DEVICE_LIB_RUNTIME_IRQ_H_
#define OPENTITAN_SW_DEVICE_LIB_RUNTIME_IRQ_H_

#include <stdbool.h>
#include <stdint.h>

#include "sw/device/lib/base/csr.h"

/**
 * Update to the location of vectors as specificed in the linker file
 *
 * The address must be 256-byte aligned.
 */
void irq_set_vector_offset(uintptr_t address);

/**
 * Enable / disable ibex global interrupts
 *
 * Sunburst - Converted func to macro to avoid interrupt-clearing side effects
 *            of function returns as compiled by the CHERIoT toolchain.
 *            For more info on the mechanics of interrupt-clearing backward
 *            sentries, see "Sealed capabilities" in the CHERIoT ISA.
 *
 * Equivalent to: `void irq_global_ctrl(bool en)`
 *
 */
#define irq_global_ctrl(en)                \
  if (en) {                                \
    CSR_SET_BITS(CSR_REG_MSTATUS, 0x8);    \
  } else {                                 \
    CSR_CLEAR_BITS(CSR_REG_MSTATUS, 0x8);  \
  }                                        \

/**
 * Enable / disable ibex external interrupts
 */
void irq_external_ctrl(bool en);

/**
 * Enable / disable ibex timer interrupts
 */
void irq_timer_ctrl(bool en);

/**
 * Enable / disable ibex software interrupts
 */
void irq_software_ctrl(bool en);

#endif  // OPENTITAN_SW_DEVICE_LIB_RUNTIME_IRQ_H_
