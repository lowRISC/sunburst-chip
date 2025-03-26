#define CHERIOT_NO_AMBIENT_MALLOC
#define CHERIOT_NO_NEW_DELETE
#define CHERIOT_PLATFORM_CUSTOM_UART

#include "../common/defs.h"
#include <cheri.hh>
#include "../common/platform-pwm.hh"
#include "../common/uart-utils.hh"
#include <stdint.h>

using namespace CHERI;

/**
 * C++ entry point. This is called from assembly, with the read-write root in the first argument.
 */
extern "C" void entry_point(void *rwRoot) {
  Capability<void> root{rwRoot};

  // Create a bounded capability to the UART
  Capability<volatile OpenTitanUart> uart = root.cast<volatile OpenTitanUart>();
  uart.address() = UART_ADDRESS;
  uart.bounds()  = UART_BOUNDS;

  Capability<volatile OpenTitanPwm> pwm = root.cast<volatile OpenTitanPwm>();
  pwm.address() = PWM_ADDRESS;
  pwm.bounds()  = PWM_BOUNDS;

  uart->init(BAUD_RATE);

  // Set up PWM
  // Target 40 kHz (40 MHz / 1000) PWM frequency
  pwm->cfg = 0x800003e7u;
  // Blink on/off every second
  pwm->duty_cycle[0]  = 0xffff0000; // Set full-on/full-off duty cycle values
  pwm->pwm_param[0] = 0x00000000u; // Clear BLINK_EN and HTBT_EN
  pwm->blink_param[0] = 0x4e1f4e1f; // Set on/off periods for 1s each
  pwm->pwm_param[0] = 0x80000000u; // Assert BLINK_EN
  // Enable output
  pwm->pwm_en = 0x01u;

  while (true) asm volatile("wfi");
}
