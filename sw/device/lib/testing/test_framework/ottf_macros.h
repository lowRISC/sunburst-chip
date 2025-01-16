// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef OPENTITAN_SW_DEVICE_LIB_TESTING_TEST_FRAMEWORK_OTTF_MACROS_H_
#define OPENTITAN_SW_DEVICE_LIB_TESTING_TEST_FRAMEWORK_OTTF_MACROS_H_

#ifndef OTTF_CHERIOT
#define OTTF_CHERIOT 1
#endif

// Size of CHERI capability in bytes
#define OTTF_CAP_SIZE  8
#define OTTF_WORD_SIZE 4
#define OTTF_NV_SCRATCH _non_volatile_scratch_start
#define OTTF_HALF_WORD_SIZE (OTTF_WORD_SIZE / 2)
#if OTTF_CHERIOT
#define OTTF_CONTEXT_SIZE (OTTF_CAP_SIZE * 15)
#else
#define OTTF_CONTEXT_SIZE (OTTF_CAP_SIZE * 30)
#endif
#define OTTF_TASK_DELETE_SELF_OR_DIE \
  ottf_task_delete_self();           \
  abort();

#endif  // OPENTITAN_SW_DEVICE_LIB_TESTING_TEST_FRAMEWORK_OTTF_MACROS_H_
