// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef OPENTITAN_SW_DEVICE_LIB_TESTING_AUTOGEN_ISR_TESTUTILS_H_
#define OPENTITAN_SW_DEVICE_LIB_TESTING_AUTOGEN_ISR_TESTUTILS_H_

// TODO: Edited manually until there is a top-level hjson file.
//
// THIS FILE HAS BEEN GENERATED, DO NOT EDIT MANUALLY. COMMAND:
// util/autogen_testutils.py

/**
 * @file
 * @brief Default ISRs for each IP
 */

#include "sw/device/lib/dif/dif_aon_timer.h"
#include "sw/device/lib/dif/dif_gpio.h"
#include "sw/device/lib/dif/dif_i2c.h"
#include "sw/device/lib/dif/dif_pattgen.h"
#include "sw/device/lib/dif/dif_rv_plic.h"
#include "sw/device/lib/dif/dif_rv_timer.h"
#include "sw/device/lib/dif/dif_spi_host.h"
#include "sw/device/lib/dif/dif_uart.h"
#include "sw/device/lib/dif/dif_usbdev.h"

#include "hw/top_chip/sw/autogen/top_chip.h"  // Generated.

/**
 * A handle to a PLIC ISR context struct.
 */
typedef struct plic_isr_ctx {
  /**
   * A handle to a rv_plic.
   */
  dif_rv_plic_t *rv_plic;
  /**
   * The HART ID associated with the PLIC (correspond to a PLIC "target").
   */
  uint32_t hart_id;
} plic_isr_ctx_t;

/**
 * A handle to a aon_timer ISR context struct.
 */
typedef struct aon_timer_isr_ctx {
  /**
   * A handle to a aon_timer.
   */
  dif_aon_timer_t *aon_timer;
  /**
   * The PLIC IRQ ID where this aon_timer instance's IRQs start.
   */
  dif_rv_plic_irq_id_t plic_aon_timer_start_irq_id;
  /**
   * The aon_timer IRQ that is expected to be encountered in the ISR.
   */
  dif_aon_timer_irq_t expected_irq;
  /**
   * Whether or not a single IRQ is expected to be encountered in the ISR.
   */
  bool is_only_irq;
} aon_timer_isr_ctx_t;

/**
 * A handle to a gpio ISR context struct.
 */
typedef struct gpio_isr_ctx {
  /**
   * A handle to a gpio.
   */
  dif_gpio_t *gpio;
  /**
   * The PLIC IRQ ID where this gpio instance's IRQs start.
   */
  dif_rv_plic_irq_id_t plic_gpio_start_irq_id;
  /**
   * The gpio IRQ that is expected to be encountered in the ISR.
   */
  dif_gpio_irq_t expected_irq;
  /**
   * Whether or not a single IRQ is expected to be encountered in the ISR.
   */
  bool is_only_irq;
} gpio_isr_ctx_t;

/**
 * A handle to a i2c ISR context struct.
 */
typedef struct i2c_isr_ctx {
  /**
   * A handle to a i2c.
   */
  dif_i2c_t *i2c;
  /**
   * The PLIC IRQ ID where this i2c instance's IRQs start.
   */
  dif_rv_plic_irq_id_t plic_i2c_start_irq_id;
  /**
   * The i2c IRQ that is expected to be encountered in the ISR.
   */
  dif_i2c_irq_t expected_irq;
  /**
   * Whether or not a single IRQ is expected to be encountered in the ISR.
   */
  bool is_only_irq;
} i2c_isr_ctx_t;

/**
 * A handle to a pattgen ISR context struct.
 */
typedef struct pattgen_isr_ctx {
  /**
   * A handle to a pattgen.
   */
  dif_pattgen_t *pattgen;
  /**
   * The PLIC IRQ ID where this pattgen instance's IRQs start.
   */
  dif_rv_plic_irq_id_t plic_pattgen_start_irq_id;
  /**
   * The pattgen IRQ that is expected to be encountered in the ISR.
   */
  dif_pattgen_irq_t expected_irq;
  /**
   * Whether or not a single IRQ is expected to be encountered in the ISR.
   */
  bool is_only_irq;
} pattgen_isr_ctx_t;

/**
 * A handle to a rv_timer ISR context struct.
 */
typedef struct rv_timer_isr_ctx {
  /**
   * A handle to a rv_timer.
   */
  dif_rv_timer_t *rv_timer;
  /**
   * The PLIC IRQ ID where this rv_timer instance's IRQs start.
   */
  dif_rv_plic_irq_id_t plic_rv_timer_start_irq_id;
  /**
   * The rv_timer IRQ that is expected to be encountered in the ISR.
   */
  dif_rv_timer_irq_t expected_irq;
  /**
   * Whether or not a single IRQ is expected to be encountered in the ISR.
   */
  bool is_only_irq;
} rv_timer_isr_ctx_t;

/**
 * A handle to a spi_host ISR context struct.
 */
typedef struct spi_host_isr_ctx {
  /**
   * A handle to a spi_host.
   */
  dif_spi_host_t *spi_host;
  /**
   * The PLIC IRQ ID where this spi_host instance's IRQs start.
   */
  dif_rv_plic_irq_id_t plic_spi_host_start_irq_id;
  /**
   * The spi_host IRQ that is expected to be encountered in the ISR.
   */
  dif_spi_host_irq_t expected_irq;
  /**
   * Whether or not a single IRQ is expected to be encountered in the ISR.
   */
  bool is_only_irq;
} spi_host_isr_ctx_t;

/**
 * A handle to a uart ISR context struct.
 */
typedef struct uart_isr_ctx {
  /**
   * A handle to a uart.
   */
  dif_uart_t *uart;
  /**
   * The PLIC IRQ ID where this uart instance's IRQs start.
   */
  dif_rv_plic_irq_id_t plic_uart_start_irq_id;
  /**
   * The uart IRQ that is expected to be encountered in the ISR.
   */
  dif_uart_irq_t expected_irq;
  /**
   * Whether or not a single IRQ is expected to be encountered in the ISR.
   */
  bool is_only_irq;
} uart_isr_ctx_t;

/**
 * A handle to a usbdev ISR context struct.
 */
typedef struct usbdev_isr_ctx {
  /**
   * A handle to a usbdev.
   */
  dif_usbdev_t *usbdev;
  /**
   * The PLIC IRQ ID where this usbdev instance's IRQs start.
   */
  dif_rv_plic_irq_id_t plic_usbdev_start_irq_id;
  /**
   * The usbdev IRQ that is expected to be encountered in the ISR.
   */
  dif_usbdev_irq_t expected_irq;
  /**
   * Whether or not a single IRQ is expected to be encountered in the ISR.
   */
  bool is_only_irq;
} usbdev_isr_ctx_t;

/**
 * Services an aon_timer IRQ.
 *
 * @param plic_ctx A PLIC ISR context handle.
 * @param aon_timer_ctx A(n) aon_timer ISR context handle.
 * @param[out] peripheral_serviced Out param for the peripheral that was
 * serviced.
 * @param[out] irq_serviced Out param for the IRQ that was serviced.
 */
void isr_testutils_aon_timer_isr(
    plic_isr_ctx_t plic_ctx, aon_timer_isr_ctx_t aon_timer_ctx,
    top_chip_plic_peripheral_t *peripheral_serviced,
    dif_aon_timer_irq_t *irq_serviced);

/**
 * Services an gpio IRQ.
 *
 * @param plic_ctx A PLIC ISR context handle.
 * @param gpio_ctx A(n) gpio ISR context handle.
 * @param[out] peripheral_serviced Out param for the peripheral that was
 * serviced.
 * @param[out] irq_serviced Out param for the IRQ that was serviced.
 */
void isr_testutils_gpio_isr(plic_isr_ctx_t plic_ctx, gpio_isr_ctx_t gpio_ctx,
                            top_chip_plic_peripheral_t *peripheral_serviced,
                            dif_gpio_irq_t *irq_serviced);

/**
 * Services an i2c IRQ.
 *
 * @param plic_ctx A PLIC ISR context handle.
 * @param i2c_ctx A(n) i2c ISR context handle.
 * @param mute_status_irq set to true to disable the serviced status type IRQ.
 * @param[out] peripheral_serviced Out param for the peripheral that was
 * serviced.
 * @param[out] irq_serviced Out param for the IRQ that was serviced.
 */
void isr_testutils_i2c_isr(plic_isr_ctx_t plic_ctx, i2c_isr_ctx_t i2c_ctx,
                           bool mute_status_irq,
                           top_chip_plic_peripheral_t *peripheral_serviced,
                           dif_i2c_irq_t *irq_serviced);

/**
 * Services an pattgen IRQ.
 *
 * @param plic_ctx A PLIC ISR context handle.
 * @param pattgen_ctx A(n) pattgen ISR context handle.
 * @param[out] peripheral_serviced Out param for the peripheral that was
 * serviced.
 * @param[out] irq_serviced Out param for the IRQ that was serviced.
 */
void isr_testutils_pattgen_isr(
    plic_isr_ctx_t plic_ctx, pattgen_isr_ctx_t pattgen_ctx,
    top_chip_plic_peripheral_t *peripheral_serviced,
    dif_pattgen_irq_t *irq_serviced);

/**
 * Services an rv_timer IRQ.
 *
 * @param plic_ctx A PLIC ISR context handle.
 * @param rv_timer_ctx A(n) rv_timer ISR context handle.
 * @param[out] peripheral_serviced Out param for the peripheral that was
 * serviced.
 * @param[out] irq_serviced Out param for the IRQ that was serviced.
 */
void isr_testutils_rv_timer_isr(
    plic_isr_ctx_t plic_ctx, rv_timer_isr_ctx_t rv_timer_ctx,
    top_chip_plic_peripheral_t *peripheral_serviced,
    dif_rv_timer_irq_t *irq_serviced);

/**
 * Services an spi_host IRQ.
 *
 * @param plic_ctx A PLIC ISR context handle.
 * @param spi_host_ctx A(n) spi_host ISR context handle.
 * @param mute_status_irq set to true to disable the serviced status type IRQ.
 * @param[out] peripheral_serviced Out param for the peripheral that was
 * serviced.
 * @param[out] irq_serviced Out param for the IRQ that was serviced.
 */
void isr_testutils_spi_host_isr(
    plic_isr_ctx_t plic_ctx, spi_host_isr_ctx_t spi_host_ctx,
    bool mute_status_irq, top_chip_plic_peripheral_t *peripheral_serviced,
    dif_spi_host_irq_t *irq_serviced);

/**
 * Services an uart IRQ.
 *
 * @param plic_ctx A PLIC ISR context handle.
 * @param uart_ctx A(n) uart ISR context handle.
 * @param mute_status_irq set to true to disable the serviced status type IRQ.
 * @param[out] peripheral_serviced Out param for the peripheral that was
 * serviced.
 * @param[out] irq_serviced Out param for the IRQ that was serviced.
 */
void isr_testutils_uart_isr(plic_isr_ctx_t plic_ctx, uart_isr_ctx_t uart_ctx,
                            bool mute_status_irq,
                            top_chip_plic_peripheral_t *peripheral_serviced,
                            dif_uart_irq_t *irq_serviced);

/**
 * Services an usbdev IRQ.
 *
 * @param plic_ctx A PLIC ISR context handle.
 * @param usbdev_ctx A(n) usbdev ISR context handle.
 * @param mute_status_irq set to true to disable the serviced status type IRQ.
 * @param[out] peripheral_serviced Out param for the peripheral that was
 * serviced.
 * @param[out] irq_serviced Out param for the IRQ that was serviced.
 */
void isr_testutils_usbdev_isr(
    plic_isr_ctx_t plic_ctx, usbdev_isr_ctx_t usbdev_ctx, bool mute_status_irq,
    top_chip_plic_peripheral_t *peripheral_serviced,
    dif_usbdev_irq_t *irq_serviced);

#endif  // OPENTITAN_SW_DEVICE_LIB_TESTING_AUTOGEN_ISR_TESTUTILS_H_
