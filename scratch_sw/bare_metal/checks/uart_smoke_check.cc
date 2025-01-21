// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Initial UART test program. Uses internal loopback

#define CHERIOT_NO_AMBIENT_MALLOC
#define CHERIOT_NO_NEW_DELETE
#define CHERIOT_PLATFORM_CUSTOM_UART

#include <cheri.hh>
#include <stdint.h>

#include "../common/sunburst_plic.hh"
#include "../common/sunburst-devices.hh"

using namespace CHERI;

typedef struct log_fields_dv {
  /**
   * Indicates the severity of the LOG.
   */
  uint32_t severity;
  /**
   * ADDRESS (as plain integer) of the `const char` string containing...
   * Name of the file at which a LOG line occurs, e.g. `__FILE__`. There
   * are no requirements for this string, other than that it be some kind of
   * UNIX-like pathname.
   */
  uint32_t file_name;
  /**
   * Indicates the line number at which the LOG line occurs, e.g., `__LINE__`.
   */
  uint32_t line;
  /**
   * Indicates the number of arguments passed to the format string.
   *
   * This value used only in DV mode, and is ignored by non-DV logging.
   */
  uint32_t nargs;
  /**
   * ADDRESS (as plain integer) of the `const char` string containing...
   * The actual format string.
   */
  uint32_t format;
} log_fields_dv_t;

extern uint32_t _dv_log_offset;

static const uint8_t kSendData[] = "Smoke test!";
static const uint8_t kUartIdx = 0u;

PLIC::SunburstPlic *plic;
UartPtr uart;

/**
 * C++ entry point. This is called from assembly, with the read-write root in the first argument.
 */
extern "C" void entry_point(void *rwRoot) {
  CapRoot root{rwRoot};

  CHERI::Capability<volatile uint32_t> status = root.cast<volatile uint32_t>();
  status.address() = 0x00100000;
  status.bounds() = 4;

  CHERI::Capability<volatile uint32_t> logger = root.cast<volatile uint32_t>();
  logger.address() = 0x00100004;
  logger.bounds() = 4;

  PLIC::SunburstPlic _plic(root);
  plic = &_plic;

  uart = uart_ptr(root, kUartIdx);

  // TODO: Use `BACKDOOR_VAR` for uart parameters
  // once SW Symbol Backdoor mechanism has been ported/implemented.

  // Initialise UART and configure for system/internal loopback testing with no parity
  uart->init(BAUD_RATE);
  uart->loopback(true, false);
  uart->parity(false, false);
  uart->fifos_clear();

  // Signal start of test
  *status = 0x4354u; // 'test'

  // Output a log message using the DV fast logging interface (as a hard-coded example)
  __attribute__((section(".logs.fields"))) \
  static const log_fields_dv_t kLogFields = { \
    .severity = 0, \
    .file_name = (uint32_t)"" __FILE__ "", \
    .line = __LINE__, \
    .nargs = 2, \
    .format = (uint32_t)"Hi, I'm a log message! Here's a number: %u, and a string: %s", \
  };
  // TODO: remove the HARDCODED line below when we have figured out
  //       how to get the IDEAL line working.
  *logger = (uint32_t)&kLogFields + (uint32_t)&_dv_log_offset; // <-- IDEAL but gives unexpected value at runtime
  *logger = 0x10004u;                                          // <-- HARDCODED address matching what the DV expects
  *logger = 123u;
  *logger = (uint32_t)"PAVLOVA";

  // Send all bytes in `kSendData`, and check that they are received via
  // the loopback mechanism.
  for (int i = 0; i < sizeof(kSendData); ++i) {
    uart->blocking_write(kSendData[i]);

    uint8_t receive_byte;
    receive_byte = uart->blocking_read();
    if (receive_byte != kSendData[i]) {
      *status = 0xbaad; // 'baad'
    }
  }

  // Signal test end to UVM testbench
  *status = 0x900d; // 'good'

  while (true) asm volatile("wfi");
}
