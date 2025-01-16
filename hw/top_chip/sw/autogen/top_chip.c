// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// NOTE: Manually edited until there is a proper top-level hjson description.

#include "hw/top_chip/sw/autogen/top_chip.h"

/**
 * PLIC Interrupt Source to Peripheral Map
 *
 * This array is a mapping from `top_earlgrey_plic_irq_id_t` to
 * `top_earlgrey_plic_peripheral_t`.
 */
const top_earlgrey_plic_peripheral_t
    top_earlgrey_plic_interrupt_for_peripheral[32] = {
  [kTopEarlgreyPlicIrqIdNone] = kTopEarlgreyPlicPeripheralUnknown,
  [1] = kTopEarlgreyPlicPeripheralUnknown,
  [2] = kTopEarlgreyPlicPeripheralUnknown,
  [3] = kTopEarlgreyPlicPeripheralUnknown,
  [4] = kTopEarlgreyPlicPeripheralUnknown,
  [5] = kTopEarlgreyPlicPeripheralUnknown,
  [6] = kTopEarlgreyPlicPeripheralUnknown,
  [7] = kTopEarlgreyPlicPeripheralUnknown,
  [8] = kTopEarlgreyPlicPeripheralUnknown,
  [9] = kTopEarlgreyPlicPeripheralUnknown,
  [10] = kTopEarlgreyPlicPeripheralUnknown,
  [11] = kTopEarlgreyPlicPeripheralUnknown,
  [12] = kTopEarlgreyPlicPeripheralUnknown,
  [13] = kTopEarlgreyPlicPeripheralUnknown,
  [14] = kTopEarlgreyPlicPeripheralUnknown,
  [15] = kTopEarlgreyPlicPeripheralUnknown,
  [16] = kTopEarlgreyPlicPeripheralUnknown,
  [17] = kTopEarlgreyPlicPeripheralUnknown,
  [18] = kTopEarlgreyPlicPeripheralUnknown,
  [19] = kTopEarlgreyPlicPeripheralUnknown,
  [20] = kTopEarlgreyPlicPeripheralUnknown,
  [21] = kTopEarlgreyPlicPeripheralUnknown,
  [22] = kTopEarlgreyPlicPeripheralUnknown,
  [23] = kTopEarlgreyPlicPeripheralUnknown,
  [24] = kTopEarlgreyPlicPeripheralUnknown,
  [25] = kTopEarlgreyPlicPeripheralUnknown,
  [26] = kTopEarlgreyPlicPeripheralUnknown,
  [27] = kTopEarlgreyPlicPeripheralUnknown,
  [28] = kTopEarlgreyPlicPeripheralUnknown,
  [29] = kTopEarlgreyPlicPeripheralUnknown,
  [30] = kTopEarlgreyPlicPeripheralUnknown,
  [31] = kTopEarlgreyPlicPeripheralUnknown,
};

