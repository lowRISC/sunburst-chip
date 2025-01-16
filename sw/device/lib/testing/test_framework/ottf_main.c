// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/testing/test_framework/ottf_main.h"

#include <assert.h>
#include <stddef.h>

#include "sw/device/lib/arch/device.h"
#include "sw/device/lib/base/macros.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/dif/dif_base.h"
#include "sw/device/lib/dif/dif_rv_core_ibex.h"
#include "sw/device/lib/dif/dif_uart.h"
#include "sw/device/lib/runtime/hart.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/rand_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/coverage.h"
#include "sw/device/lib/testing/test_framework/ottf_console.h"
#include "sw/device/lib/testing/test_framework/ottf_test_config.h"
#include "sw/device/lib/testing/test_framework/status.h"
//#include "sw/device/silicon_creator/lib/manifest_def.h"
#define manufacturer_pre_test_hook() true
#define manufacturer_post_test_hook() true

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

#define MODULE_ID MAKE_MODULE_ID('o', 't', 'm')

// Check layout of test configuration struct since OTTF ISR asm code requires a
// specific layout.
OT_ASSERT_MEMBER_OFFSET(ottf_test_config_t, enable_concurrency, 0);
OT_ASSERT_MEMBER_SIZE(ottf_test_config_t, enable_concurrency, 1);

// A global random number generator testutil handle.
rand_testutils_rng_t rand_testutils_rng_ctx;

/* Array holding the report statuses.
 *
 * This is a weak symbol which means that the test can override it to change its
 * size. For this reason, it is important to NOT use its size anywhere. To avoid
 * any errors, we define it at the bottom of the file so the rest the code uses
 * this declaration that has no size.
 */
extern const size_t kStatusReportListSize;
extern status_t status_report_list[];
// This is the count for the number of statuses that have been reported so far.
// Warning: this may be greater than kStatusReportListSize! When that happens,
// we simply overwrite previous values (modulo kStatusReportListSize).
static size_t status_report_list_cnt = 0;

// Override the status report function to store it in the array above.
void status_report(status_t status) {
  // In case of overflow, we overwrite previous values.
  status_report_list[status_report_list_cnt % kStatusReportListSize] = status;
  status_report_list_cnt++;
}

static void report_test_status(bool result) {
  // Reinitialize UART before print any debug output if the test clobbered it.
  if (kDeviceType != kDeviceSimDV) {
    if (kOttfTestConfig.console.test_may_clobber) {
      ottf_console_init();
    }
    if (!kOttfTestConfig.silence_console_prints) {
      LOG_INFO("Finished %s", kOttfTestConfig.file);
    }
  }
  // Print the reported status in case of error. Beware that
  // status_report_list_cnt might be greater than kStatusReportListSize which
  // means we had to overwrite values.
  if (!result) {
    LOG_INFO("Status reported by the test:");
    // Handle overflow.
    size_t print_cnt = status_report_list_cnt;
    if (status_report_list_cnt > kStatusReportListSize) {
      print_cnt = kStatusReportListSize;
    }
    // We print the list backwards like a stack (last report event first).
    for (size_t i = 1; i <= print_cnt; i++) {
      size_t idx = (status_report_list_cnt - i) % kStatusReportListSize;
      LOG_INFO("- %r", status_report_list[idx]);
    }
    // Warn about overflow.
    if (status_report_list_cnt > kStatusReportListSize) {
      LOG_INFO(
          "Some statuses have been lost due to the limited size of the list.");
    }
  }

  coverage_send_buffer();
  test_status_set(result ? kTestStatusPassed : kTestStatusFailed);
}

// A wrapper function is required to enable `test_main()` and test teardown
// logic to be invoked as a FreeRTOS task. This wrapper can be used by tests
// that are run on bare-metal.
static void test_wrapper(void *task_parameters) {
  // Invoke test hooks that can be overridden by closed-source code.
  bool result = manufacturer_pre_test_hook();
  result = result && test_main();
  result = result && manufacturer_post_test_hook();
  report_test_status(result);
}

void _ottf_main(void) {
  test_status_set(kTestStatusInTest);

  // Initialize the console to enable logging for non-DV simulation platforms.
  if (kDeviceType != kDeviceSimDV) {
    ottf_console_init();
    if (!kOttfTestConfig.silence_console_prints) {
      LOG_INFO("Running %s", kOttfTestConfig.file);
    }
  }

  // Initialize a global random number generator testutil context to provide
  // tests with a source of entropy for randomizing test behaviors.
  dif_rv_core_ibex_t rv_core_ibex;
  CHECK_DIF_OK(dif_rv_core_ibex_init(
      mmio_region_from_addr(TOP_EARLGREY_RV_CORE_IBEX_CFG_BASE_ADDR),
      &rv_core_ibex));
  rand_testutils_rng_ctx = rand_testutils_init(&rv_core_ibex);

  // Run the test.
  CHECK(!kOttfTestConfig.enable_concurrency);
  // Launch `test_main()` on bare-metal.
  test_wrapper(NULL);

  // Unreachable.
  CHECK(false);
}

/* Actual declaration of the weak report list. See comment above for context. */
#define OTTF_STATUS_REPORT_DEFAULT_LIST_SIZE 10
OT_WEAK const size_t kStatusReportListSize =
    OTTF_STATUS_REPORT_DEFAULT_LIST_SIZE;
OT_WEAK status_t status_report_list[OTTF_STATUS_REPORT_DEFAULT_LIST_SIZE];
