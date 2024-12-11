// Copyright lowRISC Contributors.
// SPDX-License-Identifier: Apache-2.0

#define CHERIOT_NO_AMBIENT_MALLOC
#define CHERIOT_NO_NEW_DELETE
#define CHERIOT_PLATFORM_CUSTOM_UART

#include "test_runner.hh"

// clang-format off
#include "../common/defs.h"
#include "../common/console.hh"
#include "uart_tests.hh"
#include "plic_tests.hh"
#include "../common/uart-utils.hh"
#include "../common/sunburst-devices.hh"
#include "../common/platform-gpio.hh"
#include <cheri.hh>
// clang-format on
#include <platform-uart.hh>

extern "C" void entry_point(void *rwRoot) {
  CapRoot root{rwRoot};

  auto uart0 = uart_ptr(root);
  uart0->init(BAUD_RATE);
  WriteUart uart{uart0};
  Log log(uart);

  log.println("Starting test_runner");
  plic_tests(root, log);
  log.println("All tests finished");

  // Wait for UART idle
  while (!(uart0->status & 0x8));

  CHERI::Capability<volatile OpenTitanGPIO> gpio = root.cast<volatile OpenTitanGPIO>();
  gpio.address() = GPIO_ADDRESS;
  gpio.bounds()  = GPIO_BOUNDS;

  // Signal test end to UVM testbench
  gpio->set_oe_direct(0xffffffff);
  gpio->set_out_direct(0xDEADBEEF);
}
