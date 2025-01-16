// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stdint.h>

// TODO: Problem with CLLC; the cincaddrimm appears to add the wrong offset, not compensating
// properly for the fact that auipcc has a smaller offset shift.
#include "cheri_init_globals.h"

#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/base/memory.h"

void boot_init_globals(void *__capability gdc, uint32_t start_addr, uint32_t stop_addr) {
  const void *__capability code_cap = __builtin_cheri_program_counter_get();
  const void *__capability rodata_cap = gdc;
  void *__capability data_cap = gdc;

  const struct capreloc *start_relocs = __builtin_cheri_address_set(gdc, start_addr);
  const struct capreloc *stop_relocs  = __builtin_cheri_address_set(gdc, stop_addr);

  // This code is derived from that in cheri_init_globals.h but it retains full permissions
  // without trying to lock down the protection model.
  for (const struct capreloc *reloc = start_relocs; reloc < stop_relocs;
       reloc++) {
    const void *__capability *__capability dest =
        (const void *__capability *__capability)cheri_address_or_offset_set(
            data_cap, reloc->capability_location);
    if (reloc->object == 0) {
      /* XXXAR: clang fills uninitialized capabilities with 0xcacaca..., so we
       * we need to explicitly write NULL here */
      *dest = (void *__capability)0;
      continue;
    }
    const void *__capability base_cap;
    if ((reloc->permissions & function_reloc_flag) == function_reloc_flag) {
      base_cap = code_cap; /* code pointer */
    } else if ((reloc->permissions & constant_reloc_flag) ==
               constant_reloc_flag) {
      base_cap = rodata_cap; /* read-only data pointer */
    } else {
      base_cap = data_cap; /* read-write data */
    }
    const void *__capability src = cheri_address_or_offset_set(base_cap, reloc->object);
    *dest = __builtin_cheri_offset_increment(src, reloc->offset);
  }

  // Supply a valid read/write capability for access to all MMIO regions.
  mmio_set_capability(gdc);
}
