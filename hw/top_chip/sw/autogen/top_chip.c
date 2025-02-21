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
  [kTopChipPlicIrqHwRevoker] = kTopChipPlicPeripheralUnknown,
  [2] = kTopChipPlicPeripheralUnknown,
  [kTopChipPlicIrqIdUsbdev] = kTopChipPlicPeripheralUsbdev,
  [4] = kTopChipPlicPeripheralUnknown,
  [5] = kTopChipPlicPeripheralUnknown,
  [kTopChipPlicIrqIdPattgen] = kTopChipPlicPeripheralPattgen,
  [kTopChipPlicIrqIdAonTimer] = kTopChipPlicPeripheralAonTimerAon,
  [kTopChipPlicIrqIdUart0] = kTopChipPlicPeripheralUart0,
  [kTopChipPlicIrqIdUart1] = kTopChipPlicPeripheralUart1,
  [10] = kTopChipPlicPeripheralUnknown,
  [11] = kTopChipPlicPeripheralUnknown,
  [12] = kTopChipPlicPeripheralUnknown,
  [13] = kTopChipPlicPeripheralUnknown,
  [14] = kTopChipPlicPeripheralUnknown,
  [15] = kTopChipPlicPeripheralUnknown,
  [kTopChipPlicIrqIdI2c0] = kTopChipPlicPeripheralI2c0,
  [kTopChipPlicIrqIdI2c1] = kTopChipPlicPeripheralI2c1,
  [18] = kTopChipPlicPeripheralUnknown,
  [19] = kTopChipPlicPeripheralUnknown,
  [20] = kTopChipPlicPeripheralUnknown,
  [21] = kTopChipPlicPeripheralUnknown,
  [22] = kTopChipPlicPeripheralUnknown,
  [23] = kTopChipPlicPeripheralUnknown,
  [kTopChipPlicIrqIdSpiHost0] = kTopChipPlicPeripheralSpiHost0,
  [kTopChipPlicIrqIdSpiHost1] = kTopChipPlicPeripheralSpiHost1,
  [26] = kTopChipPlicPeripheralUnknown,
  [27] = kTopChipPlicPeripheralUnknown,
  [kTopChipPlicIrqIdGpio] = kTopChipPlicPeripheralGpio,
  [29] = kTopChipPlicPeripheralUnknown,
  [30] = kTopChipPlicPeripheralUnknown,
  [31] = kTopChipPlicPeripheralUnknown,
};

