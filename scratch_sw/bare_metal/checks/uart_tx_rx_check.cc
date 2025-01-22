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
#include "../common/backdoor.hh"
#include "../common/sunburst_plic.hh"
#include "../common/sunburst-devices.hh"

using namespace CHERI;

#define UART_DATASET_SIZE 64

DEFINE_BACKDOOR_VAR(uint8_t, kUartIdx, 0)

static volatile const uint8_t kUartTxData[UART_DATASET_SIZE] = {
    0xff, 0x50, 0xc6, 0xb4, 0xbe, 0x16, 0xed, 0x55, 0x16, 0x1d, 0xe6,
    0x1c, 0xde, 0x9f, 0xfd, 0x24, 0x89, 0x81, 0x4d, 0x0d, 0x1a, 0x12,
    0x4f, 0x57, 0xea, 0xd6, 0x6f, 0xc0, 0x7d, 0x46, 0xe7, 0x37, 0x81,
    0xd3, 0x8e, 0x16, 0xad, 0x7b, 0xd0, 0xe2, 0x4f, 0xff, 0x39, 0xe6,
    0x71, 0x3c, 0x82, 0x04, 0xec, 0x3a, 0x27, 0xcc, 0x3d, 0x58, 0x0e,
    0x56, 0xd2, 0xd2, 0xb9, 0xa3, 0xb5, 0x3d, 0xc0, 0x40,
};

static volatile const uint8_t kExpUartRxData[UART_DATASET_SIZE] = {
    0x1b, 0x95, 0xc5, 0xb5, 0x8a, 0xa4, 0xa8, 0x9f, 0x6a, 0x7d, 0x6b,
    0x0c, 0xcd, 0xd5, 0xa6, 0x8f, 0x07, 0x3a, 0x9e, 0x82, 0xe6, 0xa2,
    0x2b, 0xe0, 0x0c, 0x30, 0xe8, 0x5a, 0x05, 0x14, 0x79, 0x8a, 0xFf,
    0x88, 0x29, 0xda, 0xc8, 0xdd, 0x82, 0xd5, 0x68, 0xa5, 0x9d, 0x5a,
    0x48, 0x02, 0x7f, 0x24, 0x32, 0xaf, 0x9d, 0xca, 0xa7, 0x06, 0x0c,
    0x96, 0x65, 0x18, 0xe4, 0x7f, 0x26, 0x44, 0xf3, 0x14,
};

PLIC::SunburstPlic *plic;
UartPtr uart;

/**
 * C++ entry point. This is called from assembly, with the read-write root in the first argument.
 */
extern "C" void entry_point(void *rwRoot) {
  CapRoot root{rwRoot};

  PLIC::SunburstPlic _plic(root);
  plic = &_plic;

  uart = uart_ptr(root, BACKDOOR_VAR(kUartIdx));

  CHERI::Capability<volatile uint32_t> status = root.cast<volatile uint32_t>();
  status.address() = 0x00100000;
  status.bounds() = 4;

  // Initialise UART and configure external agent testing at 1 Mbps
  uart->init(1'000'000);
  uart->loopback(false, false);
  uart->parity(false, false);
  uart->transmit_watermark(OpenTitanUart::TransmitWatermark::Level16);
  uart->receive_watermark(OpenTitanUart::ReceiveWatermark::Level16);
  uart->fifos_clear();

  // Signal start of test
  *status = 0x4354u; // 'test'

  // Send UART_DATASET_SIZE bytes
  for (int i = 0; i < UART_DATASET_SIZE; ++i) {
    uart->blocking_write(kUartTxData[i]);
  }

  // Receive UART_DATASET_SIZE bytes
  for (int i = 0; i < UART_DATASET_SIZE; ++i) {
    uint8_t receive_byte;
    receive_byte = uart->blocking_read();
    if (receive_byte != kExpUartRxData[i]) {
      *status = 0xbaad; // 'baad'
    }
  }

  // Signal test end to UVM testbench
  *status = 0x900d; // 'good'

  while (true) asm volatile("wfi");
}
