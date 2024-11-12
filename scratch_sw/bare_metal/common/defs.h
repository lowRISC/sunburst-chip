#pragma once

// CPU clock is 250 Mhz but Uart uses CPU_TIMER_HZ to set timing parameters
// based upon BAUD_RATE and the Uart runs at the 50 MHz peripheral clock
// frequency
#define CPU_TIMER_HZ ( 50'000'000)
#define BAUD_RATE    (    921'600)

#define SRAM_ADDRESS (0x0020'0000)
#define SRAM_BOUNDS  (0x0004'0000)

#define UART_BOUNDS   (0x0000'0034)
#define UART0_ADDRESS (0x4030'0000)
#define UART1_ADDRESS (0x4030'1000)

#define USBDEV_BOUNDS  (0x0000'1000)
#define USBDEV_ADDRESS (0x4040'0000)

#define GPIO_ADDRESS (0x4000'2000)
#define GPIO_BOUNDS  (0x0000'0040)

