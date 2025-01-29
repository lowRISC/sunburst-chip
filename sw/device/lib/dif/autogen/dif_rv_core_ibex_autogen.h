// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef OPENTITAN_SW_DEVICE_LIB_DIF_AUTOGEN_DIF_RV_CORE_IBEX_AUTOGEN_H_
#define OPENTITAN_SW_DEVICE_LIB_DIF_AUTOGEN_DIF_RV_CORE_IBEX_AUTOGEN_H_

// TODO: This file has been manually edited pending a decision on which parts of the
// rv_core_ibex functionality are required in the Sunburst chip project.

/**
 * @file
 * @brief <a href="/book/hw/ip/rv_core_ibex/">RV_CORE_IBEX</a> Device Interface
 * Functions
 */

#include <stdbool.h>
#include <stdint.h>

#include "sw/device/lib/base/macros.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/dif/dif_base.h"

#ifdef __cplusplus
extern "C" {
#endif  // __cplusplus

/**
 * A handle to rv_core_ibex.
 *
 * This type should be treated as opaque by users.
 */
typedef struct dif_rv_core_ibex {
  /**
   * The base address for the rv_core_ibex hardware registers.
   */
  mmio_region_t base_addr;
} dif_rv_core_ibex_t;

/**
 * Creates a new handle for a(n) rv_core_ibex peripheral.
 *
 * This function does not actuate the hardware.
 *
 * @param base_addr The MMIO base address of the rv_core_ibex peripheral.
 * @param[out] rv_core_ibex Out param for the initialized handle.
 * @return The result of the operation.
 */
OT_WARN_UNUSED_RESULT
dif_result_t dif_rv_core_ibex_init(mmio_region_t base_addr,
                                   dif_rv_core_ibex_t *rv_core_ibex);

#ifdef __cplusplus
}  // extern "C"
#endif  // __cplusplus

#endif  // OPENTITAN_SW_DEVICE_LIB_DIF_AUTOGEN_DIF_RV_CORE_IBEX_AUTOGEN_H_
