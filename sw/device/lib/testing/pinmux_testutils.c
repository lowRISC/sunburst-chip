// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/testing/pinmux_testutils.h"

#include "sw/device/lib/arch/device.h"
#include "sw/device/lib/base/macros.h"
#include "sw/device/lib/base/status.h"
#include "sw/device/lib/dif/dif_base.h"
#include "sw/device/lib/dif/dif_gpio.h"
#include "sw/device/lib/dif/dif_pinmux.h"
#include "sw/device/lib/runtime/hart.h"
#include "sw/device/lib/testing/test_framework/check.h"

#include "hw/top_chip/sw/autogen/top_chip.h"

void pinmux_testutils_init(dif_pinmux_t *pinmux) {
  // Set up SW straps on IOC0-IOC2, for GPIOs 22-24
  CHECK_DIF_OK(dif_pinmux_input_select(pinmux,
                                       kTopChipPinmuxPeripheralInGpioGpio22,
                                       kTopChipPinmuxInselIoc0));
  CHECK_DIF_OK(dif_pinmux_input_select(pinmux,
                                       kTopChipPinmuxPeripheralInGpioGpio23,
                                       kTopChipPinmuxInselIoc1));
  CHECK_DIF_OK(dif_pinmux_input_select(pinmux,
                                       kTopChipPinmuxPeripheralInGpioGpio24,
                                       kTopChipPinmuxInselIoc2));

  // Configure UART0 RX input to connect to MIO pad IOC3
  CHECK_DIF_OK(dif_pinmux_input_select(pinmux,
                                       kTopChipPinmuxPeripheralInUart0Rx,
                                       kTopChipPinmuxInselIoc3));
  CHECK_DIF_OK(dif_pinmux_output_select(pinmux, kTopChipPinmuxMioOutIoc3,
                                        kTopChipPinmuxOutselConstantHighZ));
  // Configure UART0 TX output to connect to MIO pad IOC4
  CHECK_DIF_OK(dif_pinmux_output_select(pinmux, kTopChipPinmuxMioOutIoc4,
                                        kTopChipPinmuxOutselUart0Tx));

#if !OT_IS_ENGLISH_BREAKFAST
  // Enable pull-ups on UART0 RX
  // Pull-ups are available only on certain platforms.
  if (kDeviceType == kDeviceSimDV) {
    dif_pinmux_pad_attr_t out_attr;
    dif_pinmux_pad_attr_t in_attr = {
        .slew_rate = 0,
        .drive_strength = 0,
        .flags = kDifPinmuxPadAttrPullResistorEnable |
                 kDifPinmuxPadAttrPullResistorUp};

    CHECK_DIF_OK(dif_pinmux_pad_write_attrs(pinmux, kTopChipMuxedPadsIoc3,
                                            kDifPinmuxPadKindMio, in_attr,
                                            &out_attr));
  };

  // Configure UART1 RX input to connect to MIO pad IOB4
  CHECK_DIF_OK(dif_pinmux_input_select(pinmux,
                                       kTopChipPinmuxPeripheralInUart1Rx,
                                       kTopChipPinmuxInselIob4));
  CHECK_DIF_OK(dif_pinmux_output_select(pinmux, kTopChipPinmuxMioOutIob4,
                                        kTopChipPinmuxOutselConstantHighZ));
  // Configure UART1 TX output to connect to MIO pad IOB5
  CHECK_DIF_OK(dif_pinmux_output_select(pinmux, kTopChipPinmuxMioOutIob5,
                                        kTopChipPinmuxOutselUart1Tx));

  // Configure a higher drive strength for the USB_P and USB_N pads because we
  // must the pad drivers must be capable of overpowering the 'pull' signal
  // strength of the internal pull ups in the differential receiver.
  //
  // 'pull' strength is required because at the host end of the USB, there
  // are 'weak' pull downs, allowing it to detect device presence when it
  // applies its pull up.
  //    strong PAD driver > internal pull up > weak pull down at host
  //
  // Normally the pull up on USB_P will be asserted, but we may be employing
  // 'pin flipping' and instead choose to apply the _N pull up.
  if (kDeviceType == kDeviceSimDV) {
    dif_pinmux_pad_attr_t out_attr;
    dif_pinmux_pad_attr_t in_attr = {
        .slew_rate = 0, .drive_strength = 1, .flags = 0};

    CHECK_DIF_OK(
        dif_pinmux_pad_write_attrs(pinmux, kTopChipDirectPadsUsbdevUsbDp,
                                   kDifPinmuxPadKindDio, in_attr, &out_attr));
    CHECK_DIF_OK(
        dif_pinmux_pad_write_attrs(pinmux, kTopChipDirectPadsUsbdevUsbDn,
                                   kDifPinmuxPadKindDio, in_attr, &out_attr));
  }
#endif

  // Configure USBDEV SENSE outputs to be high-Z (IOC7)
  CHECK_DIF_OK(dif_pinmux_output_select(pinmux, kTopChipPinmuxMioOutIoc7,
                                        kTopChipPinmuxOutselConstantHighZ));
}

// Mapping of Chip IOs to the GPIO peripheral.
//
// Depending on the simulation platform, there may be a limitation to how chip
// IOs are allocated to the GPIO peripheral, even for testing. The DV testbench
// does not have this limitation, and is able to allocate as many chip IOs as
// the number of GPIOs supported by the peripheral. At this time, these pin
// assignments matches DV (see `hw/top_chip/dv/env/chip_if.sv`).
//
// The pinout spreadsheet allocates fewer pins to GPIOs than what the GPIO IP
// supports. This oversubscription is intentional to maximize testing.
const dif_pinmux_index_t kPinmuxTestutilsGpioInselPins[kDifGpioNumPins] = {
    kTopChipPinmuxInselIoa0,  kTopChipPinmuxInselIoa1,
    kTopChipPinmuxInselIoa2,  kTopChipPinmuxInselIoa3,
    kTopChipPinmuxInselIoa4,  kTopChipPinmuxInselIoa5,
    kTopChipPinmuxInselIoa6,  kTopChipPinmuxInselIoa7,
    kTopChipPinmuxInselIoa8,  kTopChipPinmuxInselIob6,
    kTopChipPinmuxInselIob7,  kTopChipPinmuxInselIob8,
    kTopChipPinmuxInselIob9,  kTopChipPinmuxInselIob10,
    kTopChipPinmuxInselIob11, kTopChipPinmuxInselIob12,
    kTopChipPinmuxInselIoc9,  kTopChipPinmuxInselIoc10,
    kTopChipPinmuxInselIoc11, kTopChipPinmuxInselIoc12,
    kTopChipPinmuxInselIor0,  kTopChipPinmuxInselIor1,
    kTopChipPinmuxInselIor2,  kTopChipPinmuxInselIor3,
    kTopChipPinmuxInselIor4,  kTopChipPinmuxInselIor5,
    kTopChipPinmuxInselIor6,  kTopChipPinmuxInselIor7,
    kTopChipPinmuxInselIor10, kTopChipPinmuxInselIor11,
    kTopChipPinmuxInselIor12, kTopChipPinmuxInselIor13};

const dif_pinmux_index_t kPinmuxTestutilsGpioMioOutPins[kDifGpioNumPins] = {
    kTopChipPinmuxMioOutIoa0,  kTopChipPinmuxMioOutIoa1,
    kTopChipPinmuxMioOutIoa2,  kTopChipPinmuxMioOutIoa3,
    kTopChipPinmuxMioOutIoa4,  kTopChipPinmuxMioOutIoa5,
    kTopChipPinmuxMioOutIoa6,  kTopChipPinmuxMioOutIoa7,
    kTopChipPinmuxMioOutIoa8,  kTopChipPinmuxMioOutIob6,
    kTopChipPinmuxMioOutIob7,  kTopChipPinmuxMioOutIob8,
    kTopChipPinmuxMioOutIob9,  kTopChipPinmuxMioOutIob10,
    kTopChipPinmuxMioOutIob11, kTopChipPinmuxMioOutIob12,
    kTopChipPinmuxMioOutIoc9,  kTopChipPinmuxMioOutIoc10,
    kTopChipPinmuxMioOutIoc11, kTopChipPinmuxMioOutIoc12,
    kTopChipPinmuxMioOutIor0,  kTopChipPinmuxMioOutIor1,
    kTopChipPinmuxMioOutIor2,  kTopChipPinmuxMioOutIor3,
    kTopChipPinmuxMioOutIor4,  kTopChipPinmuxMioOutIor5,
    kTopChipPinmuxMioOutIor6,  kTopChipPinmuxMioOutIor7,
    kTopChipPinmuxMioOutIor10, kTopChipPinmuxMioOutIor11,
    kTopChipPinmuxMioOutIor12, kTopChipPinmuxMioOutIor13};

uint32_t pinmux_testutils_get_testable_gpios_mask(void) {
  switch (kDeviceType) {
    case kDeviceSimDV:
    case kDeviceSimVerilator:
      // All GPIOs are testable in DV.
      return 0xffffffff;
    case kDeviceFpgaCw310:
      // Only IOR6, IOR7, and IOR10 to IOR13 are available for use as GPIOs.
      return 0xfc000000;
    case kDeviceSilicon:
      // IOA3/6, IOB6, IOC9-12, IOR5-7 and IOR10-13.
      return 0xfe0f0248;
    default:
      CHECK(false);
      return 0;
  }
}

uint32_t pinmux_testutils_read_strap_pin(dif_pinmux_t *pinmux, dif_gpio_t *gpio,
                                         dif_gpio_pin_t io,
                                         top_chip_muxed_pads_t pad) {
  // Turn off the pull enable on the pad and read the IO.
  dif_pinmux_pad_attr_t attr = {.flags = 0};
  dif_pinmux_pad_attr_t attr_out;
  CHECK_DIF_OK(dif_pinmux_pad_write_attrs(pinmux, pad, kDifPinmuxPadKindMio,
                                          attr, &attr_out));
  // Let the change propagate.
  busy_spin_micros(100);
  bool state;
  // The value read is unmodified by the internal pull resistors and represents
  // the upper bit of the 4 possible states [Strong0, Weak0, Weak1,
  // Strong1].
  CHECK_DIF_OK(dif_gpio_read(gpio, io, &state));
  uint32_t result = state ? 2 : 0;

  // Based on the previous read, enable the opposite pull resistor.  If the
  // external signal is weak, the internal pull resistor will win; if the
  // external signal is strong, the external value will win.
  attr.flags = kDifPinmuxPadAttrPullResistorEnable |
               (state ? 0 : kDifPinmuxPadAttrPullResistorUp);
  CHECK_DIF_OK(dif_pinmux_pad_write_attrs(pinmux, pad, kDifPinmuxPadKindMio,
                                          attr, &attr_out));
  // Let the change propagate.
  busy_spin_micros(100);
  // Combine the result of the contest between the external signal in internal
  // pull resistors.  This represents the lower bit of the 4 possible states.
  CHECK_DIF_OK(dif_gpio_read(gpio, io, &state));
  result += state ? 1 : 0;
  return result;
}

uint32_t pinmux_testutils_read_straps(dif_pinmux_t *pinmux, dif_gpio_t *gpio) {
  uint32_t strap = 0;
  strap |= pinmux_testutils_read_strap_pin(pinmux, gpio, 22,
                                           kTopChipMuxedPadsIoc0);
  strap |= pinmux_testutils_read_strap_pin(pinmux, gpio, 23,
                                           kTopChipMuxedPadsIoc1)
           << 2;
  strap |= pinmux_testutils_read_strap_pin(pinmux, gpio, 24,
                                           kTopChipMuxedPadsIoc2)
           << 4;
  return strap;
}

void pinmux_testutils_configure_pads(const dif_pinmux_t *pinmux,
                                     const pinmux_pad_attributes_t *attrs,
                                     size_t num_attrs) {
  for (size_t i = 0; i < num_attrs; ++i) {
    dif_pinmux_pad_attr_t desired_attr, actual_attr;
    CHECK_DIF_OK(dif_pinmux_pad_get_attrs(pinmux, attrs[i].pad, attrs[i].kind,
                                          &desired_attr));
    desired_attr.flags = attrs[i].flags;
    CHECK_DIF_OK(dif_pinmux_pad_write_attrs(pinmux, attrs[i].pad, attrs[i].kind,
                                            desired_attr, &actual_attr));
  }
}
