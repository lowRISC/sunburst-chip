// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef OPENTITAN_SW_DEVICE_LIB_TESTING_JSON_PINMUX_H_
#define OPENTITAN_SW_DEVICE_LIB_TESTING_JSON_PINMUX_H_
#include "sw/device/lib/ujson/ujson_derive.h"
#ifdef __cplusplus
extern "C" {
#endif

// Note: these definitions rely on constants from top_chip.h
// and therefore this library cannot be used with the `ujson_rust`
// bazel rule.  Instead, these constants are imported into rust
// by way of a bindgen rule and recreated as Rust datatypes with
// appropriate aliases to be used by other `ujson` libraries.
#ifndef RUST_PREPROCESSOR_EMIT
#include "hw/top_chip/sw/autogen/top_chip.h"
#endif
// clang-format off

#define TOP_CHIP_PINMUX_PERIPHERAL_IN(_, value) \
    value(_, GpioGpio0, kTopChipPinmuxPeripheralInGpioGpio0) \
    value(_, GpioGpio1, kTopChipPinmuxPeripheralInGpioGpio1) \
    value(_, GpioGpio2, kTopChipPinmuxPeripheralInGpioGpio2) \
    value(_, GpioGpio3, kTopChipPinmuxPeripheralInGpioGpio3) \
    value(_, GpioGpio4, kTopChipPinmuxPeripheralInGpioGpio4) \
    value(_, GpioGpio5, kTopChipPinmuxPeripheralInGpioGpio5) \
    value(_, GpioGpio6, kTopChipPinmuxPeripheralInGpioGpio6) \
    value(_, GpioGpio7, kTopChipPinmuxPeripheralInGpioGpio7) \
    value(_, GpioGpio8, kTopChipPinmuxPeripheralInGpioGpio8) \
    value(_, GpioGpio9, kTopChipPinmuxPeripheralInGpioGpio9) \
    value(_, GpioGpio10, kTopChipPinmuxPeripheralInGpioGpio10) \
    value(_, GpioGpio11, kTopChipPinmuxPeripheralInGpioGpio11) \
    value(_, GpioGpio12, kTopChipPinmuxPeripheralInGpioGpio12) \
    value(_, GpioGpio13, kTopChipPinmuxPeripheralInGpioGpio13) \
    value(_, GpioGpio14, kTopChipPinmuxPeripheralInGpioGpio14) \
    value(_, GpioGpio15, kTopChipPinmuxPeripheralInGpioGpio15) \
    value(_, GpioGpio16, kTopChipPinmuxPeripheralInGpioGpio16) \
    value(_, GpioGpio17, kTopChipPinmuxPeripheralInGpioGpio17) \
    value(_, GpioGpio18, kTopChipPinmuxPeripheralInGpioGpio18) \
    value(_, GpioGpio19, kTopChipPinmuxPeripheralInGpioGpio19) \
    value(_, GpioGpio20, kTopChipPinmuxPeripheralInGpioGpio20) \
    value(_, GpioGpio21, kTopChipPinmuxPeripheralInGpioGpio21) \
    value(_, GpioGpio22, kTopChipPinmuxPeripheralInGpioGpio22) \
    value(_, GpioGpio23, kTopChipPinmuxPeripheralInGpioGpio23) \
    value(_, GpioGpio24, kTopChipPinmuxPeripheralInGpioGpio24) \
    value(_, GpioGpio25, kTopChipPinmuxPeripheralInGpioGpio25) \
    value(_, GpioGpio26, kTopChipPinmuxPeripheralInGpioGpio26) \
    value(_, GpioGpio27, kTopChipPinmuxPeripheralInGpioGpio27) \
    value(_, GpioGpio28, kTopChipPinmuxPeripheralInGpioGpio28) \
    value(_, GpioGpio29, kTopChipPinmuxPeripheralInGpioGpio29) \
    value(_, GpioGpio30, kTopChipPinmuxPeripheralInGpioGpio30) \
    value(_, GpioGpio31, kTopChipPinmuxPeripheralInGpioGpio31) \
    value(_, I2c0Sda, kTopChipPinmuxPeripheralInI2c0Sda) \
    value(_, I2c0Scl, kTopChipPinmuxPeripheralInI2c0Scl) \
    value(_, I2c1Sda, kTopChipPinmuxPeripheralInI2c1Sda) \
    value(_, I2c1Scl, kTopChipPinmuxPeripheralInI2c1Scl) \
    value(_, I2c2Sda, kTopChipPinmuxPeripheralInI2c2Sda) \
    value(_, I2c2Scl, kTopChipPinmuxPeripheralInI2c2Scl) \
    value(_, SpiHost1Sd0, kTopChipPinmuxPeripheralInSpiHost1Sd0) \
    value(_, SpiHost1Sd1, kTopChipPinmuxPeripheralInSpiHost1Sd1) \
    value(_, SpiHost1Sd2, kTopChipPinmuxPeripheralInSpiHost1Sd2) \
    value(_, SpiHost1Sd3, kTopChipPinmuxPeripheralInSpiHost1Sd3) \
    value(_, Uart0Rx, kTopChipPinmuxPeripheralInUart0Rx) \
    value(_, Uart1Rx, kTopChipPinmuxPeripheralInUart1Rx) \
    value(_, Uart2Rx, kTopChipPinmuxPeripheralInUart2Rx) \
    value(_, Uart3Rx, kTopChipPinmuxPeripheralInUart3Rx) \
    value(_, SpiDeviceTpmCsb, kTopChipPinmuxPeripheralInSpiDeviceTpmCsb) \
    value(_, FlashCtrlTck, kTopChipPinmuxPeripheralInFlashCtrlTck) \
    value(_, FlashCtrlTms, kTopChipPinmuxPeripheralInFlashCtrlTms) \
    value(_, FlashCtrlTdi, kTopChipPinmuxPeripheralInFlashCtrlTdi) \
    value(_, SysrstCtrlAonAcPresent, kTopChipPinmuxPeripheralInSysrstCtrlAonAcPresent) \
    value(_, SysrstCtrlAonKey0In, kTopChipPinmuxPeripheralInSysrstCtrlAonKey0In) \
    value(_, SysrstCtrlAonKey1In, kTopChipPinmuxPeripheralInSysrstCtrlAonKey1In) \
    value(_, SysrstCtrlAonKey2In, kTopChipPinmuxPeripheralInSysrstCtrlAonKey2In) \
    value(_, SysrstCtrlAonPwrbIn, kTopChipPinmuxPeripheralInSysrstCtrlAonPwrbIn) \
    value(_, SysrstCtrlAonLidOpen, kTopChipPinmuxPeripheralInSysrstCtrlAonLidOpen) \
    value(_, UsbdevSense, kTopChipPinmuxPeripheralInUsbdevSense) \
    value(_, End, kTopChipPinmuxPeripheralInLast + 1)
C_ONLY(UJSON_SERDE_ENUM(PinmuxPeripheralIn, pinmux_peripheral_in_t, TOP_CHIP_PINMUX_PERIPHERAL_IN, WITH_UNKNOWN));

#define TOP_CHIP_PINMUX_INSEL(_, value) \
    value(_, ConstantZero, kTopChipPinmuxInselConstantZero) \
    value(_, ConstantOne, kTopChipPinmuxInselConstantOne) \
    value(_, Ioa0, kTopChipPinmuxInselIoa0) \
    value(_, Ioa1, kTopChipPinmuxInselIoa1) \
    value(_, Ioa2, kTopChipPinmuxInselIoa2) \
    value(_, Ioa3, kTopChipPinmuxInselIoa3) \
    value(_, Ioa4, kTopChipPinmuxInselIoa4) \
    value(_, Ioa5, kTopChipPinmuxInselIoa5) \
    value(_, Ioa6, kTopChipPinmuxInselIoa6) \
    value(_, Ioa7, kTopChipPinmuxInselIoa7) \
    value(_, Ioa8, kTopChipPinmuxInselIoa8) \
    value(_, Iob0, kTopChipPinmuxInselIob0) \
    value(_, Iob1, kTopChipPinmuxInselIob1) \
    value(_, Iob2, kTopChipPinmuxInselIob2) \
    value(_, Iob3, kTopChipPinmuxInselIob3) \
    value(_, Iob4, kTopChipPinmuxInselIob4) \
    value(_, Iob5, kTopChipPinmuxInselIob5) \
    value(_, Iob6, kTopChipPinmuxInselIob6) \
    value(_, Iob7, kTopChipPinmuxInselIob7) \
    value(_, Iob8, kTopChipPinmuxInselIob8) \
    value(_, Iob9, kTopChipPinmuxInselIob9) \
    value(_, Iob10, kTopChipPinmuxInselIob10) \
    value(_, Iob11, kTopChipPinmuxInselIob11) \
    value(_, Iob12, kTopChipPinmuxInselIob12) \
    value(_, Ioc0, kTopChipPinmuxInselIoc0) \
    value(_, Ioc1, kTopChipPinmuxInselIoc1) \
    value(_, Ioc2, kTopChipPinmuxInselIoc2) \
    value(_, Ioc3, kTopChipPinmuxInselIoc3) \
    value(_, Ioc4, kTopChipPinmuxInselIoc4) \
    value(_, Ioc5, kTopChipPinmuxInselIoc5) \
    value(_, Ioc6, kTopChipPinmuxInselIoc6) \
    value(_, Ioc7, kTopChipPinmuxInselIoc7) \
    value(_, Ioc8, kTopChipPinmuxInselIoc8) \
    value(_, Ioc9, kTopChipPinmuxInselIoc9) \
    value(_, Ioc10, kTopChipPinmuxInselIoc10) \
    value(_, Ioc11, kTopChipPinmuxInselIoc11) \
    value(_, Ioc12, kTopChipPinmuxInselIoc12) \
    value(_, Ior0, kTopChipPinmuxInselIor0) \
    value(_, Ior1, kTopChipPinmuxInselIor1) \
    value(_, Ior2, kTopChipPinmuxInselIor2) \
    value(_, Ior3, kTopChipPinmuxInselIor3) \
    value(_, Ior4, kTopChipPinmuxInselIor4) \
    value(_, Ior5, kTopChipPinmuxInselIor5) \
    value(_, Ior6, kTopChipPinmuxInselIor6) \
    value(_, Ior7, kTopChipPinmuxInselIor7) \
    value(_, Ior10, kTopChipPinmuxInselIor10) \
    value(_, Ior11, kTopChipPinmuxInselIor11) \
    value(_, Ior12, kTopChipPinmuxInselIor12) \
    value(_, Ior13, kTopChipPinmuxInselIor13) \
    value(_, End, kTopChipPinmuxInselLast + 1)
C_ONLY(UJSON_SERDE_ENUM(PinmuxInsel, pinmux_insel_t, TOP_CHIP_PINMUX_INSEL, WITH_UNKNOWN));

#define TOP_CHIP_PINMUX_MIO_OUT(_, value) \
    value(_, Ioa0, kTopChipPinmuxMioOutIoa0) \
    value(_, Ioa1, kTopChipPinmuxMioOutIoa1) \
    value(_, Ioa2, kTopChipPinmuxMioOutIoa2) \
    value(_, Ioa3, kTopChipPinmuxMioOutIoa3) \
    value(_, Ioa4, kTopChipPinmuxMioOutIoa4) \
    value(_, Ioa5, kTopChipPinmuxMioOutIoa5) \
    value(_, Ioa6, kTopChipPinmuxMioOutIoa6) \
    value(_, Ioa7, kTopChipPinmuxMioOutIoa7) \
    value(_, Ioa8, kTopChipPinmuxMioOutIoa8) \
    value(_, Iob0, kTopChipPinmuxMioOutIob0) \
    value(_, Iob1, kTopChipPinmuxMioOutIob1) \
    value(_, Iob2, kTopChipPinmuxMioOutIob2) \
    value(_, Iob3, kTopChipPinmuxMioOutIob3) \
    value(_, Iob4, kTopChipPinmuxMioOutIob4) \
    value(_, Iob5, kTopChipPinmuxMioOutIob5) \
    value(_, Iob6, kTopChipPinmuxMioOutIob6) \
    value(_, Iob7, kTopChipPinmuxMioOutIob7) \
    value(_, Iob8, kTopChipPinmuxMioOutIob8) \
    value(_, Iob9, kTopChipPinmuxMioOutIob9) \
    value(_, Iob10, kTopChipPinmuxMioOutIob10) \
    value(_, Iob11, kTopChipPinmuxMioOutIob11) \
    value(_, Iob12, kTopChipPinmuxMioOutIob12) \
    value(_, Ioc0, kTopChipPinmuxMioOutIoc0) \
    value(_, Ioc1, kTopChipPinmuxMioOutIoc1) \
    value(_, Ioc2, kTopChipPinmuxMioOutIoc2) \
    value(_, Ioc3, kTopChipPinmuxMioOutIoc3) \
    value(_, Ioc4, kTopChipPinmuxMioOutIoc4) \
    value(_, Ioc5, kTopChipPinmuxMioOutIoc5) \
    value(_, Ioc6, kTopChipPinmuxMioOutIoc6) \
    value(_, Ioc7, kTopChipPinmuxMioOutIoc7) \
    value(_, Ioc8, kTopChipPinmuxMioOutIoc8) \
    value(_, Ioc9, kTopChipPinmuxMioOutIoc9) \
    value(_, Ioc10, kTopChipPinmuxMioOutIoc10) \
    value(_, Ioc11, kTopChipPinmuxMioOutIoc11) \
    value(_, Ioc12, kTopChipPinmuxMioOutIoc12) \
    value(_, Ior0, kTopChipPinmuxMioOutIor0) \
    value(_, Ior1, kTopChipPinmuxMioOutIor1) \
    value(_, Ior2, kTopChipPinmuxMioOutIor2) \
    value(_, Ior3, kTopChipPinmuxMioOutIor3) \
    value(_, Ior4, kTopChipPinmuxMioOutIor4) \
    value(_, Ior5, kTopChipPinmuxMioOutIor5) \
    value(_, Ior6, kTopChipPinmuxMioOutIor6) \
    value(_, Ior7, kTopChipPinmuxMioOutIor7) \
    value(_, Ior10, kTopChipPinmuxMioOutIor10) \
    value(_, Ior11, kTopChipPinmuxMioOutIor11) \
    value(_, Ior12, kTopChipPinmuxMioOutIor12) \
    value(_, Ior13, kTopChipPinmuxMioOutIor13) \
    value(_, End, kTopChipPinmuxMioOutLast + 1)
C_ONLY(UJSON_SERDE_ENUM(PinmuxMioOut, pinmux_mio_out_t, TOP_CHIP_PINMUX_MIO_OUT, WITH_UNKNOWN));

#define TOP_CHIP_PINMUX_OUTSEL(_, value) \
    value(_, ConstantZero, kTopChipPinmuxOutselConstantZero) \
    value(_, ConstantOne, kTopChipPinmuxOutselConstantOne) \
    value(_, ConstantHighZ, kTopChipPinmuxOutselConstantHighZ) \
    value(_, GpioGpio0, kTopChipPinmuxOutselGpioGpio0) \
    value(_, GpioGpio1, kTopChipPinmuxOutselGpioGpio1) \
    value(_, GpioGpio2, kTopChipPinmuxOutselGpioGpio2) \
    value(_, GpioGpio3, kTopChipPinmuxOutselGpioGpio3) \
    value(_, GpioGpio4, kTopChipPinmuxOutselGpioGpio4) \
    value(_, GpioGpio5, kTopChipPinmuxOutselGpioGpio5) \
    value(_, GpioGpio6, kTopChipPinmuxOutselGpioGpio6) \
    value(_, GpioGpio7, kTopChipPinmuxOutselGpioGpio7) \
    value(_, GpioGpio8, kTopChipPinmuxOutselGpioGpio8) \
    value(_, GpioGpio9, kTopChipPinmuxOutselGpioGpio9) \
    value(_, GpioGpio10, kTopChipPinmuxOutselGpioGpio10) \
    value(_, GpioGpio11, kTopChipPinmuxOutselGpioGpio11) \
    value(_, GpioGpio12, kTopChipPinmuxOutselGpioGpio12) \
    value(_, GpioGpio13, kTopChipPinmuxOutselGpioGpio13) \
    value(_, GpioGpio14, kTopChipPinmuxOutselGpioGpio14) \
    value(_, GpioGpio15, kTopChipPinmuxOutselGpioGpio15) \
    value(_, GpioGpio16, kTopChipPinmuxOutselGpioGpio16) \
    value(_, GpioGpio17, kTopChipPinmuxOutselGpioGpio17) \
    value(_, GpioGpio18, kTopChipPinmuxOutselGpioGpio18) \
    value(_, GpioGpio19, kTopChipPinmuxOutselGpioGpio19) \
    value(_, GpioGpio20, kTopChipPinmuxOutselGpioGpio20) \
    value(_, GpioGpio21, kTopChipPinmuxOutselGpioGpio21) \
    value(_, GpioGpio22, kTopChipPinmuxOutselGpioGpio22) \
    value(_, GpioGpio23, kTopChipPinmuxOutselGpioGpio23) \
    value(_, GpioGpio24, kTopChipPinmuxOutselGpioGpio24) \
    value(_, GpioGpio25, kTopChipPinmuxOutselGpioGpio25) \
    value(_, GpioGpio26, kTopChipPinmuxOutselGpioGpio26) \
    value(_, GpioGpio27, kTopChipPinmuxOutselGpioGpio27) \
    value(_, GpioGpio28, kTopChipPinmuxOutselGpioGpio28) \
    value(_, GpioGpio29, kTopChipPinmuxOutselGpioGpio29) \
    value(_, GpioGpio30, kTopChipPinmuxOutselGpioGpio30) \
    value(_, GpioGpio31, kTopChipPinmuxOutselGpioGpio31) \
    value(_, I2c0Sda, kTopChipPinmuxOutselI2c0Sda) \
    value(_, I2c0Scl, kTopChipPinmuxOutselI2c0Scl) \
    value(_, I2c1Sda, kTopChipPinmuxOutselI2c1Sda) \
    value(_, I2c1Scl, kTopChipPinmuxOutselI2c1Scl) \
    value(_, I2c2Sda, kTopChipPinmuxOutselI2c2Sda) \
    value(_, I2c2Scl, kTopChipPinmuxOutselI2c2Scl) \
    value(_, SpiHost1Sd0, kTopChipPinmuxOutselSpiHost1Sd0) \
    value(_, SpiHost1Sd1, kTopChipPinmuxOutselSpiHost1Sd1) \
    value(_, SpiHost1Sd2, kTopChipPinmuxOutselSpiHost1Sd2) \
    value(_, SpiHost1Sd3, kTopChipPinmuxOutselSpiHost1Sd3) \
    value(_, Uart0Tx, kTopChipPinmuxOutselUart0Tx) \
    value(_, Uart1Tx, kTopChipPinmuxOutselUart1Tx) \
    value(_, Uart2Tx, kTopChipPinmuxOutselUart2Tx) \
    value(_, Uart3Tx, kTopChipPinmuxOutselUart3Tx) \
    value(_, PattgenPda0Tx, kTopChipPinmuxOutselPattgenPda0Tx) \
    value(_, PattgenPcl0Tx, kTopChipPinmuxOutselPattgenPcl0Tx) \
    value(_, PattgenPda1Tx, kTopChipPinmuxOutselPattgenPda1Tx) \
    value(_, PattgenPcl1Tx, kTopChipPinmuxOutselPattgenPcl1Tx) \
    value(_, SpiHost1Sck, kTopChipPinmuxOutselSpiHost1Sck) \
    value(_, SpiHost1Csb, kTopChipPinmuxOutselSpiHost1Csb) \
    value(_, FlashCtrlTdo, kTopChipPinmuxOutselFlashCtrlTdo) \
    value(_, SensorCtrlAstDebugOut0, kTopChipPinmuxOutselSensorCtrlAonAstDebugOut0) \
    value(_, SensorCtrlAstDebugOut1, kTopChipPinmuxOutselSensorCtrlAonAstDebugOut1) \
    value(_, SensorCtrlAstDebugOut2, kTopChipPinmuxOutselSensorCtrlAonAstDebugOut2) \
    value(_, SensorCtrlAstDebugOut3, kTopChipPinmuxOutselSensorCtrlAonAstDebugOut3) \
    value(_, SensorCtrlAstDebugOut4, kTopChipPinmuxOutselSensorCtrlAonAstDebugOut4) \
    value(_, SensorCtrlAstDebugOut5, kTopChipPinmuxOutselSensorCtrlAonAstDebugOut5) \
    value(_, SensorCtrlAstDebugOut6, kTopChipPinmuxOutselSensorCtrlAonAstDebugOut6) \
    value(_, SensorCtrlAstDebugOut7, kTopChipPinmuxOutselSensorCtrlAonAstDebugOut7) \
    value(_, SensorCtrlAstDebugOut8, kTopChipPinmuxOutselSensorCtrlAonAstDebugOut8) \
    value(_, PwmAonPwm0, kTopChipPinmuxOutselPwmAonPwm0) \
    value(_, PwmAonPwm1, kTopChipPinmuxOutselPwmAonPwm1) \
    value(_, PwmAonPwm2, kTopChipPinmuxOutselPwmAonPwm2) \
    value(_, PwmAonPwm3, kTopChipPinmuxOutselPwmAonPwm3) \
    value(_, PwmAonPwm4, kTopChipPinmuxOutselPwmAonPwm4) \
    value(_, PwmAonPwm5, kTopChipPinmuxOutselPwmAonPwm5) \
    value(_, OtpCtrlTest0, kTopChipPinmuxOutselOtpCtrlTest0) \
    value(_, SysrstCtrlAonBatDisable, kTopChipPinmuxOutselSysrstCtrlAonBatDisable) \
    value(_, SysrstCtrlAonKey0Out, kTopChipPinmuxOutselSysrstCtrlAonKey0Out) \
    value(_, SysrstCtrlAonKey1Out, kTopChipPinmuxOutselSysrstCtrlAonKey1Out) \
    value(_, SysrstCtrlAonKey2Out, kTopChipPinmuxOutselSysrstCtrlAonKey2Out) \
    value(_, SysrstCtrlAonPwrbOut, kTopChipPinmuxOutselSysrstCtrlAonPwrbOut) \
    value(_, SysrstCtrlAonZ3Wakeup, kTopChipPinmuxOutselSysrstCtrlAonZ3Wakeup) \
    value(_, End, kTopChipPinmuxOutselLast + 1)
C_ONLY(UJSON_SERDE_ENUM(PinmuxOutsel, pinmux_outsel_t, TOP_CHIP_PINMUX_OUTSEL, WITH_UNKNOWN));

#define TOP_CHIP_DIRECT_PADS(_, value) \
    value(_, UsbdevUsbDp, kTopChipDirectPadsUsbdevUsbDp) \
    value(_, UsbdevUsbDn, kTopChipDirectPadsUsbdevUsbDn) \
    value(_, SpiHost0Sd0, kTopChipDirectPadsSpiHost0Sd0) \
    value(_, SpiHost0Sd1, kTopChipDirectPadsSpiHost0Sd1) \
    value(_, SpiHost0Sd2, kTopChipDirectPadsSpiHost0Sd2) \
    value(_, SpiHost0Sd3, kTopChipDirectPadsSpiHost0Sd3) \
    value(_, SpiDeviceSd0, kTopChipDirectPadsSpiDeviceSd0) \
    value(_, SpiDeviceSd1, kTopChipDirectPadsSpiDeviceSd1) \
    value(_, SpiDeviceSd2, kTopChipDirectPadsSpiDeviceSd2) \
    value(_, SpiDeviceSd3, kTopChipDirectPadsSpiDeviceSd3) \
    value(_, SysrstCtrlAonEcRstL, kTopChipDirectPadsSysrstCtrlAonEcRstL) \
    value(_, SysrstCtrlAonFlashWpL, kTopChipDirectPadsSysrstCtrlAonFlashWpL) \
    value(_, SpiDeviceSck, kTopChipDirectPadsSpiDeviceSck) \
    value(_, SpiDeviceCsb, kTopChipDirectPadsSpiDeviceCsb) \
    value(_, SpiHost0Sck, kTopChipDirectPadsSpiHost0Sck) \
    value(_, SpiHost0Csb, kTopChipDirectPadsSpiHost0Csb) \
    value(_, End, kTopChipDirectPadsLast + 1)
C_ONLY(UJSON_SERDE_ENUM(DirectPads, direct_pads_t, TOP_CHIP_DIRECT_PADS, WITH_UNKNOWN));

#define TOP_CHIP_MUXED_PADS(_, value) \
    value(_, Ioa0, kTopChipMuxedPadsIoa0) \
    value(_, Ioa1, kTopChipMuxedPadsIoa1) \
    value(_, Ioa2, kTopChipMuxedPadsIoa2) \
    value(_, Ioa3, kTopChipMuxedPadsIoa3) \
    value(_, Ioa4, kTopChipMuxedPadsIoa4) \
    value(_, Ioa5, kTopChipMuxedPadsIoa5) \
    value(_, Ioa6, kTopChipMuxedPadsIoa6) \
    value(_, Ioa7, kTopChipMuxedPadsIoa7) \
    value(_, Ioa8, kTopChipMuxedPadsIoa8) \
    value(_, Iob0, kTopChipMuxedPadsIob0) \
    value(_, Iob1, kTopChipMuxedPadsIob1) \
    value(_, Iob2, kTopChipMuxedPadsIob2) \
    value(_, Iob3, kTopChipMuxedPadsIob3) \
    value(_, Iob4, kTopChipMuxedPadsIob4) \
    value(_, Iob5, kTopChipMuxedPadsIob5) \
    value(_, Iob6, kTopChipMuxedPadsIob6) \
    value(_, Iob7, kTopChipMuxedPadsIob7) \
    value(_, Iob8, kTopChipMuxedPadsIob8) \
    value(_, Iob9, kTopChipMuxedPadsIob9) \
    value(_, Iob10, kTopChipMuxedPadsIob10) \
    value(_, Iob11, kTopChipMuxedPadsIob11) \
    value(_, Iob12, kTopChipMuxedPadsIob12) \
    value(_, Ioc0, kTopChipMuxedPadsIoc0) \
    value(_, Ioc1, kTopChipMuxedPadsIoc1) \
    value(_, Ioc2, kTopChipMuxedPadsIoc2) \
    value(_, Ioc3, kTopChipMuxedPadsIoc3) \
    value(_, Ioc4, kTopChipMuxedPadsIoc4) \
    value(_, Ioc5, kTopChipMuxedPadsIoc5) \
    value(_, Ioc6, kTopChipMuxedPadsIoc6) \
    value(_, Ioc7, kTopChipMuxedPadsIoc7) \
    value(_, Ioc8, kTopChipMuxedPadsIoc8) \
    value(_, Ioc9, kTopChipMuxedPadsIoc9) \
    value(_, Ioc10, kTopChipMuxedPadsIoc10) \
    value(_, Ioc11, kTopChipMuxedPadsIoc11) \
    value(_, Ioc12, kTopChipMuxedPadsIoc12) \
    value(_, Ior0, kTopChipMuxedPadsIor0) \
    value(_, Ior1, kTopChipMuxedPadsIor1) \
    value(_, Ior2, kTopChipMuxedPadsIor2) \
    value(_, Ior3, kTopChipMuxedPadsIor3) \
    value(_, Ior4, kTopChipMuxedPadsIor4) \
    value(_, Ior5, kTopChipMuxedPadsIor5) \
    value(_, Ior6, kTopChipMuxedPadsIor6) \
    value(_, Ior7, kTopChipMuxedPadsIor7) \
    value(_, Ior10, kTopChipMuxedPadsIor10) \
    value(_, Ior11, kTopChipMuxedPadsIor11) \
    value(_, Ior12, kTopChipMuxedPadsIor12) \
    value(_, Ior13, kTopChipMuxedPadsIor13) \
    value(_, End, kTopChipMuxedPadsLast + 1)
C_ONLY(UJSON_SERDE_ENUM(MuxedPads, muxed_pads_t, TOP_CHIP_MUXED_PADS, WITH_UNKNOWN));

// clang-format on
#ifdef __cplusplus
}
#endif
#endif  // OPENTITAN_SW_DEVICE_LIB_TESTING_JSON_PINMUX_H_
