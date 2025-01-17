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
