#define CHERIOT_NO_AMBIENT_MALLOC
#define CHERIOT_NO_NEW_DELETE
#define CHERIOT_PLATFORM_CUSTOM_UART

#include "../common/defs.h"
#include <cheri.hh>
#include "../common/platform-gpio.hh"
#include "../common/platform-pattgen.hh"
#include "../common/platform-pwm.hh"
#include "../common/uart-utils.hh"
#include <stdint.h>

using namespace CHERI;

/**
 * C++ entry point. This is called from assembly, with the read-write root in the first argument.
 */
extern "C" void entry_point(void *rwRoot) {
  Capability<void> root{rwRoot};

  //// Create a bounded capability to the UART
  Capability<volatile OpenTitanUart> uart = root.cast<volatile OpenTitanUart>();
  uart.address() = UART_ADDRESS;
  uart.bounds()  = UART_BOUNDS;

  Capability<volatile OpenTitanGPIO> gpio = root.cast<volatile OpenTitanGPIO>();
  gpio.address() = GPIO_ADDRESS;
  gpio.bounds()  = GPIO_BOUNDS;

  Capability<volatile OpenTitanPattgen> pattgen = root.cast<volatile OpenTitanPattgen>();
  pattgen.address() = PATTGEN_ADDRESS;
  pattgen.bounds()  = PATTGEN_BOUNDS;

  Capability<volatile OpenTitanPwm> pwm = root.cast<volatile OpenTitanPwm>();
  pwm.address() = PWM_ADDRESS;
  pwm.bounds()  = PWM_BOUNDS;

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

  // Set up pattgen to emit a couple of distinct test patterns, with different clock polarities.
  pattgen->prediv_ch0 = 2;
  pattgen->prediv_ch1 = 3;
  pattgen->data_ch0_0 = 0xaaaaaaaau;
  pattgen->data_ch0_1 = 0xf0f0f0f0u;
  pattgen->data_ch1_0 = 0x33333333u;
  pattgen->data_ch1_1 = 0x11111111u;
  // Emit each pattern for as long as possible.
  pattgen->size = (0x3ffu << 22) | (0x3fu << 16) | (0x3ffu << 6) | 0x3fu;

  write_str(uart, "Generating pattern\r\n");
  // Enable pattern output.
  pattgen->ctrl = 0x6b;

  // Set up pwm to emit a different pattern on each of its outputs.
  pwm->cfg = 0xf0000001u;
  pwm->invert = 0x2a;
  for (unsigned ch = 0u; ch < PWM_NUM_OUTPUTS; ch++) {
    pwm->pwm_param[ch]   = ch << 12;
    pwm->duty_cycle[ch]  = (7 - ch) << 12;
    pwm->blink_param[ch] = 0u;
  }

  write_str(uart, "Enabling PWM\r\n");
  pwm->pwm_en = 0x3f;

  // Just report some register values since we cannot see the outputs of these IP blocks.
  write_str(uart, "Pattgen channel 0 : ");
  write_hex(uart, pattgen->data_ch0_1);
  write_str(uart, " : ");
  write_hex(uart, pattgen->data_ch0_0);
  write_str(uart, "\r\n");

  write_str(uart, "PWM output 0 : ");
  write_hex(uart, pwm->pwm_param[0]);
  write_str(uart, " : ");
  write_hex(uart, pwm->duty_cycle[0]);
  write_str(uart, "\r\n");

  // Wait for UART idle
  while (!(uart->status & 0x8));
  // Signal test end to UVM testbench
  gpio->set_out_direct(0xDEADBEEF);

  while (true) asm volatile("wfi");
}
