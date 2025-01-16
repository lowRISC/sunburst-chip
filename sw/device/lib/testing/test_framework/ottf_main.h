// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef OPENTITAN_SW_DEVICE_LIB_TESTING_TEST_FRAMEWORK_OTTF_MAIN_H_
#define OPENTITAN_SW_DEVICE_LIB_TESTING_TEST_FRAMEWORK_OTTF_MAIN_H_

#include <stdbool.h>

#include "sw/device/lib/base/status.h"
#include "sw/device/lib/dif/dif_uart.h"
#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_test_config.h"

/**
 * @file
 * @brief Entrypoint definitions for on-device tests
 */

/**
 * Entry point for a SW on-device (or chip-level) test.
 *
 * This function should be defined externally in a standalone SW test, linked
 * together with this library. This library provides a `main()` function that
 * does test harness setup, initializes FreeRTOS, and starts a FreeRTOS task
 * that executes `test_main()`.
 *
 * @return success or failure of the test as boolean.
 */
extern bool test_main(void);

/**
 * TODO: add description
 */
extern bool manufacturer_pre_test_hook(void);

/**
 * TODO: add description
 */
extern bool manufacturer_post_test_hook(void);

/**
 * Execute a test function, profile the execution and log the test result.
 * Update the result value if there is a failure code.
 */
#define EXECUTE_TEST(result_, test_function_, ...)                       \
  do {                                                                   \
    LOG_INFO("Starting test " #test_function_ "...");                    \
    uint64_t t_start_ = ibex_mcycle_read();                              \
    status_t local_status = INTO_STATUS(test_function_(__VA_ARGS__));    \
    uint64_t cycles_ = ibex_mcycle_read() - t_start_;                    \
    CHECK(kClockFreqCpuHz <= UINT32_MAX, "");                            \
    uint32_t clock_mhz = (uint32_t)kClockFreqCpuHz / 1000000;            \
    if (status_ok(local_status)) {                                       \
      if (cycles_ <= UINT32_MAX) {                                       \
        uint32_t micros = (uint32_t)cycles_ / clock_mhz;                 \
        LOG_INFO("Successfully finished test " #test_function_           \
                 " in %u cycles or %u us @ %u MHz.",                     \
                 (uint32_t)cycles_, micros, clock_mhz);                  \
      } else {                                                           \
        uint32_t cycles_lower_ = (uint32_t)(cycles_ & UINT32_MAX);       \
        uint32_t cycles_upper_ = (uint32_t)(cycles_ >> 32);              \
        LOG_INFO("Successfully finished test " #test_function_           \
                 " in 0x%08x%08x cycles.",                               \
                 cycles_upper_, cycles_lower_);                          \
      }                                                                  \
    } else {                                                             \
      result_ = local_status;                                            \
      LOG_ERROR("Finished test " #test_function_ ": %r.", local_status); \
    }                                                                    \
  } while (0)

/**
 * Override the default status report list size. This list is used to store
 * error statuses in case of failed TRY() and are reported when the test
 * fails. This must be used at the global scope.
 */
#define OTTF_OVERRIDE_STATUS_REPORT_LIST(list_size) \
  const size_t kStatusReportListSize = list_size;   \
  status_t status_report_list[list_size];

#endif  // OPENTITAN_SW_DEVICE_LIB_TESTING_TEST_FRAMEWORK_OTTF_MAIN_H_
