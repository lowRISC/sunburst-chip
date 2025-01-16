// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// NOTE: Manually edited until there is a proper top-level hjson description.

#include "hw/top_chip/sw/autogen/top_chip.h"

/**
 * PLIC Interrupt Source to Peripheral Map
 *
 * This array is a mapping from `top_chip_plic_irq_id_t` to
 * `top_chip_plic_peripheral_t`.
 */
const top_chip_plic_peripheral_t
    top_chip_plic_interrupt_for_peripheral[32] = {
  [kTopChipPlicIrqIdNone] = kTopChipPlicPeripheralUnknown,
  [1] = kTopChipPlicPeripheralUnknown,
  [2] = kTopChipPlicPeripheralUnknown,
  [3] = kTopChipPlicPeripheralUnknown,
  [4] = kTopChipPlicPeripheralUnknown,
  [5] = kTopChipPlicPeripheralUnknown,
  [6] = kTopChipPlicPeripheralUnknown,
  [7] = kTopChipPlicPeripheralUnknown,
  [8] = kTopChipPlicPeripheralUnknown,
  [9] = kTopChipPlicPeripheralUnknown,
  [10] = kTopChipPlicPeripheralUnknown,
  [11] = kTopChipPlicPeripheralUnknown,
  [12] = kTopChipPlicPeripheralUnknown,
  [13] = kTopChipPlicPeripheralUnknown,
  [14] = kTopChipPlicPeripheralUnknown,
  [15] = kTopChipPlicPeripheralUnknown,
  [16] = kTopChipPlicPeripheralUnknown,
  [17] = kTopChipPlicPeripheralUnknown,
  [18] = kTopChipPlicPeripheralUnknown,
  [19] = kTopChipPlicPeripheralUnknown,
  [20] = kTopChipPlicPeripheralUnknown,
  [21] = kTopChipPlicPeripheralUnknown,
  [22] = kTopChipPlicPeripheralUnknown,
  [23] = kTopChipPlicPeripheralUnknown,
  [24] = kTopChipPlicPeripheralUnknown,
  [25] = kTopChipPlicPeripheralUnknown,
  [26] = kTopChipPlicPeripheralUnknown,
  [27] = kTopChipPlicPeripheralUnknown,
  [28] = kTopChipPlicPeripheralUnknown,
  [29] = kTopChipPlicPeripheralUnknown,
  [30] = kTopChipPlicPeripheralUnknown,
  [31] = kTopChipPlicPeripheralUnknown,
};

