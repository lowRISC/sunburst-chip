/**
 * Copyright lowRISC contributors.
 * Licensed under the Apache License, Version 2.0, see LICENSE for details.
 * SPDX-License-Identifier: Apache-2.0
 */

#pragma once
// clang-format off
#include "defs.h"
#include "sunburst_plic.hh"
// clang-format on

#include <assert.h>

#include <cheri.hh>
// #include <platform-gpio.hh>
#include "platform-gpio.hh"
#include <platform-uart.hh>
#include <platform-i2c.hh>
#include <platform-rgbctrl.hh>
#include "sunburst_pattgen.hh"
// #include <platform-spi.hh>
#include "sunburst_spi.hh"
// #include <platform-usbdev.hh>
#include "platform-usbdev.hh"

typedef CHERI::Capability<void> CapRoot;
typedef volatile OpenTitanGPIO *GpioPtr;
typedef volatile OpenTitanUart *UartPtr;
typedef volatile OpenTitanUsbdev *UsbdevPtr;
typedef volatile OpenTitanI2c *I2cPtr;
typedef volatile SunburstPattgen *PattgenPtr;
typedef volatile SunburstSpi *SpiPtr;
typedef volatile OpenTitanUsbdev *UsbdevPtr;
typedef PLIC::SunburstPlic *PlicPtr;

[[maybe_unused]] static GpioPtr gpio_ptr(CapRoot root) {
  CHERI::Capability<volatile OpenTitanGPIO> gpio = root.cast<volatile OpenTitanGPIO>();
  gpio.address()                                   = GPIO_ADDRESS;
  gpio.bounds()                                    = GPIO_BOUNDS;
  return gpio;
}

[[maybe_unused]] static UartPtr uart_ptr(CapRoot root, uint32_t idx = 0) {
  CHERI::Capability<volatile OpenTitanUart> uart = root.cast<volatile OpenTitanUart>();
  assert(idx < UART_NUM);
  uart.address() = UART_ADDRESS + (idx * UART_RANGE);
  uart.bounds()  = UART_BOUNDS;
  return uart;
}

[[maybe_unused]] static I2cPtr i2c_ptr(CapRoot root, uint32_t idx = 0) {
  CHERI::Capability<volatile OpenTitanI2c> i2c = root.cast<volatile OpenTitanI2c>();
  assert(idx < I2C_NUM);
  i2c.address() = I2C_ADDRESS + (idx * I2C_RANGE);
  i2c.bounds()  = I2C_BOUNDS;
  return i2c;
}

[[maybe_unused]] static PattgenPtr pattgen_ptr(CapRoot root) {
  CHERI::Capability<volatile SunburstPattgen> pattgen = root.cast<volatile SunburstPattgen>();
  pattgen.address()                                   = PATTGEN_ADDRESS;
  pattgen.bounds()                                    = PATTGEN_BOUNDS;
  return pattgen;
}

[[maybe_unused]] static SpiPtr spi_ptr(CapRoot root, uint32_t idx = 0) {
  CHERI::Capability<volatile SunburstSpi> spi = root.cast<volatile SunburstSpi>();
  assert(idx < SPI_NUM);
  spi.address() = SPI_ADDRESS + (idx * SPI_RANGE);
  spi.bounds()  = SPI_BOUNDS;
  return spi;
}

[[maybe_unused]] static UsbdevPtr usbdev_ptr(CapRoot root) {
  CHERI::Capability<volatile OpenTitanUsbdev> usbdev = root.cast<volatile OpenTitanUsbdev>();
  usbdev.address()                                   = USBDEV_ADDRESS;
  usbdev.bounds()                                    = USBDEV_BOUNDS;
  return usbdev;
}
