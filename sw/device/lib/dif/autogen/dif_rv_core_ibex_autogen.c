// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// TODO: This file has been manually edited pending a decision on which parts
// of the rv_core_ibex functionality are required in the Sunburst chip project.

#include "sw/device/lib/dif/autogen/dif_rv_core_ibex_autogen.h"

#include <stdint.h>

#include "sw/device/lib/dif/dif_base.h"

#include "rv_core_ibex_regs.h"  // Generated.

OT_WARN_UNUSED_RESULT
dif_result_t dif_rv_core_ibex_init(mmio_region_t base_addr,
                                   dif_rv_core_ibex_t *rv_core_ibex) {
  if (rv_core_ibex == NULL) {
    return kDifBadArg;
  }

  rv_core_ibex->base_addr = base_addr;

  return kDifOk;
}
