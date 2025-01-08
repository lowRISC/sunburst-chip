// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Initial UART test program. Uses external agents.
// TODO: replace with full OpenTitan test program once environment is ready.

#define CHERIOT_NO_AMBIENT_MALLOC
#define CHERIOT_NO_NEW_DELETE
#define CHERIOT_PLATFORM_CUSTOM_UART

#include <cheri.hh>
#include <stdint.h>

#include "../common/asm.hh"
#include "../common/platform-gpio.hh"
#include "../common/sunburst_plic.hh"
#include "../common/sunburst-devices.hh"

using namespace CHERI;

#define UART_DATASET_SIZE 64

static const uint8_t kUartIdx = 0u;

PLIC::SunburstPlic *plic;
UartPtr uart;

/**
 * C++ entry point. This is called from assembly, with the read-write root in the first argument.
 */
extern "C" void entry_point(void *rwRoot) {
  CapRoot root{rwRoot};

  PLIC::SunburstPlic _plic(root);
  plic = &_plic;

  uart = uart_ptr(root, kUartIdx);

  auto gpio = gpio_ptr(root);
  gpio->set_oe_direct(0xffffffffu);

  // Initialise UART and configure external agent testing at 1 Mbps
  uart->init(1'000'000);
  uart->loopback(false, false);
  uart->parity(false, false);
  uart->transmit_watermark(OpenTitanUart::TransmitWatermark::Level16);
  uart->receive_watermark(OpenTitanUart::ReceiveWatermark::Level16);
  uart->fifos_clear();

  // Send UART_DATASET_SIZE bytes
  for (int i = 0; i < UART_DATASET_SIZE; ++i) {
    uart->blocking_write(i);
  }

  // Receive UART_DATASET_SIZE bytes
  for (int i = 0; i < UART_DATASET_SIZE; ++i) {
    uint8_t receive_byte;
    receive_byte = uart->blocking_read();
    // Do not bother checking the RX data, as we have no way to signal a test failure (yet?)
  }

  // Signal test end to UVM testbench
  gpio->set_out_direct(0xDEADBEEFu);

  // Spin until DV environment finishes
  while (true) {
    ASM::Ibex::nop(); // prevent loop from being optimised away
  }
}
