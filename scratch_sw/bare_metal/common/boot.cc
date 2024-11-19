/**
 * Copyright lowRISC contributors.
 * Licensed under the Apache License, Version 2.0, see LICENSE for details.
 * SPDX-License-Identifier: Apache-2.0
 */
#define CHERIOT_NO_AMBIENT_MALLOC
#define CHERIOT_NO_NEW_DELETE
#define CHERIOT_PLATFORM_CUSTOM_UART

#include <cheri.hh>
#include "../common/defs.h"
#include <platform-uart.hh>
#include "../common/asm.hh"
#include "../common/uart-utils.hh"

typedef CHERI::Capability<volatile OpenTitanUart> &UartRef;

const char prefix[] = "\x1b[35sunburst-chip\033[0m: ";

static void write_hex_with_prefix(UartRef uart, const char *msg, uint32_t value) {
  write_str(uart, prefix);
  write_str(uart, msg);
  write_hex(uart, value);
  write_str(uart, "\r\n");
}

extern "C" void exception_handler(void *rwRoot) {
  CHERI::Capability<void> root{rwRoot};

  // Create a bounded capability to the UART
  CHERI::Capability<volatile OpenTitanUart> uart = root.cast<volatile OpenTitanUart>();
  uart.address()                                 = UART_ADDRESS;
  uart.bounds()                                  = UART_BOUNDS;

  write_str(uart, prefix);
  write_str(uart, "Exception happened during loading.\r\n");

  write_hex_with_prefix(uart, "mepc  : ", READ_CSR("mepc"));
  write_hex_with_prefix(uart, "mcause: ", READ_CSR("mcause"));
  write_hex_with_prefix(uart, "mtval : ", READ_CSR("mtval"));
}

