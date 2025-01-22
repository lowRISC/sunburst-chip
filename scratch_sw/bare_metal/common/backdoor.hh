// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Handy macros for defining and using variables to be overridden by
// backdoor access from the DV or other testing environment.

/* Macro to define and use variable that need to be stored in .rodata
 * for DV tests and .data for real tests, to enable backdoor access. */
#define DEFINE_BACKDOOR_VAR(type, name, default_val)                       \
  /* DV variable in .rodata. */                                              \
  __attribute__((section(".rodata"))) static volatile const type name##DV = default_val; \
  /* non-DV variable in .data. */                                            \
  __attribute__((section(".data"))) type name##Real = default_val;

// TODO: Restore non-DV option in BACKDOOR_VAR when kDeviceType exists.
// #define BACKDOOR_VAR(name) (kDeviceType == kDeviceSimDV ? name##DV : name##Real)
#define BACKDOOR_VAR(name) (name##DV)
