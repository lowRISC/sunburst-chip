#define CHERIOT_NO_AMBIENT_MALLOC
#define CHERIOT_NO_NEW_DELETE
#define CHERIOT_PLATFORM_CUSTOM_UART

#include "../common/defs.h"
#include <cheri.hh>
#include "../common/platform-gpio.hh"
#include "../common/uart-utils.hh"
#include <stdint.h>

using namespace CHERI;

/**
 * C++ entry point for the loader.  This is called from assembly, with the
 * read-write root in the first argument.
 */
[[noreturn]]
extern "C" void rom_loader_entry(void *rwRoot)
{
  Capability<void> root{rwRoot};

  //// Create a bounded capability to the UART
  Capability<volatile OpenTitanUart> uart = root.cast<volatile OpenTitanUart>();
  uart.address() = UART0_ADDRESS;
  uart.bounds()  = UART_BOUNDS;

  Capability<volatile OpenTitanGPIO> gpio = root.cast<volatile OpenTitanGPIO>();
  gpio.address() = GPIO_ADDRESS;
  gpio.bounds()  = GPIO_BOUNDS;

  uart->init(BAUD_RATE);

  uint32_t next_out = 0xAAAAAAAA;

  gpio->set_oe_direct(0xffffffff);

  for (int i = 0; i < 10; ++i) {
    gpio->set_out_direct(next_out);
    next_out = ~next_out;
    write_str(uart, "Hello from Sonata Chip! ");
    write_hex8b(uart, i);
    write_str(uart, "\r\n");
  }

  // Wait for UART idle
  while (!(uart->status & 0x8));
  // Signal test end to UVM testbench
  gpio->set_out_direct(0xDEADBEEF);

  while (true);
}
