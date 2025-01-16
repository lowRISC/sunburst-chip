// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef OPENTITAN_HW_TOP_CHIP_SW_AUTOGEN_TOP_CHIP_H_
#define OPENTITAN_HW_TOP_CHIP_SW_AUTOGEN_TOP_CHIP_H_

// NOTE: Manually edited until there is a proper top-level hjson description.

/**
 * @file
 * @brief Top-specific Definitions
 *
 * This file contains preprocessor and type definitions for use within the
 * device C/C++ codebase.
 *
 * These definitions are for information that depends on the top-specific chip
 * configuration, which includes:
 * - Device Memory Information (for Peripherals and Memory)
 * - PLIC Interrupt ID Names and Source Mappings
 * - Alert ID Names and Source Mappings
 * - Pinmux Pin/Select Names
 * - Power Manager Wakeups
 */

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Peripheral base address for uart0 in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_UART0_BASE_ADDR 0x40300000u

/**
 * Peripheral size for uart0 in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_UART0_BASE_ADDR and
 * `TOP_CHIP_UART0_BASE_ADDR + TOP_CHIP_UART0_SIZE_BYTES`.
 */
#define TOP_CHIP_UART0_SIZE_BYTES 0x40u

/**
 * Peripheral base address for uart1 in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_UART1_BASE_ADDR 0x40010000u

/**
 * Peripheral size for uart1 in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_UART1_BASE_ADDR and
 * `TOP_CHIP_UART1_BASE_ADDR + TOP_CHIP_UART1_SIZE_BYTES`.
 */
#define TOP_CHIP_UART1_SIZE_BYTES 0x40u

/**
 * Peripheral base address for uart2 in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_UART2_BASE_ADDR 0x40020000u

/**
 * Peripheral size for uart2 in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_UART2_BASE_ADDR and
 * `TOP_CHIP_UART2_BASE_ADDR + TOP_CHIP_UART2_SIZE_BYTES`.
 */
#define TOP_CHIP_UART2_SIZE_BYTES 0x40u

/**
 * Peripheral base address for uart3 in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_UART3_BASE_ADDR 0x40030000u

/**
 * Peripheral size for uart3 in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_UART3_BASE_ADDR and
 * `TOP_CHIP_UART3_BASE_ADDR + TOP_CHIP_UART3_SIZE_BYTES`.
 */
#define TOP_CHIP_UART3_SIZE_BYTES 0x40u

/**
 * Peripheral base address for gpio in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_GPIO_BASE_ADDR 0x40002000u

/**
 * Peripheral size for gpio in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_GPIO_BASE_ADDR and
 * `TOP_CHIP_GPIO_BASE_ADDR + TOP_CHIP_GPIO_SIZE_BYTES`.
 */
#define TOP_CHIP_GPIO_SIZE_BYTES 0x40u

/**
 * Peripheral base address for spi_device in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_SPI_DEVICE_BASE_ADDR 0x40050000u

/**
 * Peripheral size for spi_device in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_SPI_DEVICE_BASE_ADDR and
 * `TOP_CHIP_SPI_DEVICE_BASE_ADDR + TOP_CHIP_SPI_DEVICE_SIZE_BYTES`.
 */
#define TOP_CHIP_SPI_DEVICE_SIZE_BYTES 0x2000u

/**
 * Peripheral base address for i2c0 in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_I2C0_BASE_ADDR 0x40100000u

/**
 * Peripheral size for i2c0 in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_I2C0_BASE_ADDR and
 * `TOP_CHIP_I2C0_BASE_ADDR + TOP_CHIP_I2C0_SIZE_BYTES`.
 */
#define TOP_CHIP_I2C0_SIZE_BYTES 0x80u

/**
 * Peripheral base address for i2c1 in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_I2C1_BASE_ADDR 0x40101000u

/**
 * Peripheral size for i2c1 in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_I2C1_BASE_ADDR and
 * `TOP_CHIP_I2C1_BASE_ADDR + TOP_CHIP_I2C1_SIZE_BYTES`.
 */
#define TOP_CHIP_I2C1_SIZE_BYTES 0x80u

/**
 * Peripheral base address for i2c2 in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_I2C2_BASE_ADDR 0x400A0000u

/**
 * Peripheral size for i2c2 in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_I2C2_BASE_ADDR and
 * `TOP_CHIP_I2C2_BASE_ADDR + TOP_CHIP_I2C2_SIZE_BYTES`.
 */
#define TOP_CHIP_I2C2_SIZE_BYTES 0x80u

/**
 * Peripheral base address for pattgen in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_PATTGEN_BASE_ADDR 0x40500000u

/**
 * Peripheral size for pattgen in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_PATTGEN_BASE_ADDR and
 * `TOP_CHIP_PATTGEN_BASE_ADDR + TOP_CHIP_PATTGEN_SIZE_BYTES`.
 */
#define TOP_CHIP_PATTGEN_SIZE_BYTES 0x40u

/**
 * Peripheral base address for rv_timer in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_RV_TIMER_BASE_ADDR 0x40100000u

/**
 * Peripheral size for rv_timer in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_RV_TIMER_BASE_ADDR and
 * `TOP_CHIP_RV_TIMER_BASE_ADDR + TOP_CHIP_RV_TIMER_SIZE_BYTES`.
 */
#define TOP_CHIP_RV_TIMER_SIZE_BYTES 0x200u

/**
 * Peripheral base address for core device on otp_ctrl in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_OTP_CTRL_CORE_BASE_ADDR 0x40130000u

/**
 * Peripheral size for core device on otp_ctrl in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_OTP_CTRL_CORE_BASE_ADDR and
 * `TOP_CHIP_OTP_CTRL_CORE_BASE_ADDR + TOP_CHIP_OTP_CTRL_CORE_SIZE_BYTES`.
 */
#define TOP_CHIP_OTP_CTRL_CORE_SIZE_BYTES 0x1000u

/**
 * Peripheral base address for prim device on otp_ctrl in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_OTP_CTRL_PRIM_BASE_ADDR 0x40138000u

/**
 * Peripheral size for prim device on otp_ctrl in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_OTP_CTRL_PRIM_BASE_ADDR and
 * `TOP_CHIP_OTP_CTRL_PRIM_BASE_ADDR + TOP_CHIP_OTP_CTRL_PRIM_SIZE_BYTES`.
 */
#define TOP_CHIP_OTP_CTRL_PRIM_SIZE_BYTES 0x20u

/**
 * Peripheral base address for lc_ctrl in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_LC_CTRL_BASE_ADDR 0x40140000u

/**
 * Peripheral size for lc_ctrl in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_LC_CTRL_BASE_ADDR and
 * `TOP_CHIP_LC_CTRL_BASE_ADDR + TOP_CHIP_LC_CTRL_SIZE_BYTES`.
 */
#define TOP_CHIP_LC_CTRL_SIZE_BYTES 0x100u

/**
 * Peripheral base address for alert_handler in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_ALERT_HANDLER_BASE_ADDR 0x40150000u

/**
 * Peripheral size for alert_handler in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_ALERT_HANDLER_BASE_ADDR and
 * `TOP_CHIP_ALERT_HANDLER_BASE_ADDR + TOP_CHIP_ALERT_HANDLER_SIZE_BYTES`.
 */
#define TOP_CHIP_ALERT_HANDLER_SIZE_BYTES 0x800u

/**
 * Peripheral base address for spi_host0 in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_SPI_HOST0_BASE_ADDR 0x40200000u

/**
 * Peripheral size for spi_host0 in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_SPI_HOST0_BASE_ADDR and
 * `TOP_CHIP_SPI_HOST0_BASE_ADDR + TOP_CHIP_SPI_HOST0_SIZE_BYTES`.
 */
#define TOP_CHIP_SPI_HOST0_SIZE_BYTES 0x40u

/**
 * Peripheral base address for spi_host1 in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_SPI_HOST1_BASE_ADDR 0x40201000u

/**
 * Peripheral size for spi_host1 in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_SPI_HOST1_BASE_ADDR and
 * `TOP_CHIP_SPI_HOST1_BASE_ADDR + TOP_CHIP_SPI_HOST1_SIZE_BYTES`.
 */
#define TOP_CHIP_SPI_HOST1_SIZE_BYTES 0x40u

/**
 * Peripheral base address for usbdev in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_USBDEV_BASE_ADDR 0x40400000u

/**
 * Peripheral size for usbdev in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_USBDEV_BASE_ADDR and
 * `TOP_CHIP_USBDEV_BASE_ADDR + TOP_CHIP_USBDEV_SIZE_BYTES`.
 */
#define TOP_CHIP_USBDEV_SIZE_BYTES 0x1000u

/**
 * Peripheral base address for pwrmgr_aon in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_PWRMGR_AON_BASE_ADDR 0x40400000u

/**
 * Peripheral size for pwrmgr_aon in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_PWRMGR_AON_BASE_ADDR and
 * `TOP_CHIP_PWRMGR_AON_BASE_ADDR + TOP_CHIP_PWRMGR_AON_SIZE_BYTES`.
 */
#define TOP_CHIP_PWRMGR_AON_SIZE_BYTES 0x80u

/**
 * Peripheral base address for rstmgr_aon in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_RSTMGR_AON_BASE_ADDR 0x40410000u

/**
 * Peripheral size for rstmgr_aon in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_RSTMGR_AON_BASE_ADDR and
 * `TOP_CHIP_RSTMGR_AON_BASE_ADDR + TOP_CHIP_RSTMGR_AON_SIZE_BYTES`.
 */
#define TOP_CHIP_RSTMGR_AON_SIZE_BYTES 0x80u

/**
 * Peripheral base address for clkmgr_aon in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_CLKMGR_AON_BASE_ADDR 0x40420000u

/**
 * Peripheral size for clkmgr_aon in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_CLKMGR_AON_BASE_ADDR and
 * `TOP_CHIP_CLKMGR_AON_BASE_ADDR + TOP_CHIP_CLKMGR_AON_SIZE_BYTES`.
 */
#define TOP_CHIP_CLKMGR_AON_SIZE_BYTES 0x80u

/**
 * Peripheral base address for sysrst_ctrl_aon in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_SYSRST_CTRL_AON_BASE_ADDR 0x40430000u

/**
 * Peripheral size for sysrst_ctrl_aon in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_SYSRST_CTRL_AON_BASE_ADDR and
 * `TOP_CHIP_SYSRST_CTRL_AON_BASE_ADDR + TOP_CHIP_SYSRST_CTRL_AON_SIZE_BYTES`.
 */
#define TOP_CHIP_SYSRST_CTRL_AON_SIZE_BYTES 0x100u

/**
 * Peripheral base address for adc_ctrl_aon in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_ADC_CTRL_AON_BASE_ADDR 0x40440000u

/**
 * Peripheral size for adc_ctrl_aon in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_ADC_CTRL_AON_BASE_ADDR and
 * `TOP_CHIP_ADC_CTRL_AON_BASE_ADDR + TOP_CHIP_ADC_CTRL_AON_SIZE_BYTES`.
 */
#define TOP_CHIP_ADC_CTRL_AON_SIZE_BYTES 0x80u

/**
 * Peripheral base address for pwm_aon in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_PWM_AON_BASE_ADDR 0x40600000u

/**
 * Peripheral size for pwm_aon in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_PWM_AON_BASE_ADDR and
 * `TOP_CHIP_PWM_AON_BASE_ADDR + TOP_CHIP_PWM_AON_SIZE_BYTES`.
 */
#define TOP_CHIP_PWM_AON_SIZE_BYTES 0x80u

/**
 * Peripheral base address for pinmux_aon in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_PINMUX_AON_BASE_ADDR 0x40460000u

/**
 * Peripheral size for pinmux_aon in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_PINMUX_AON_BASE_ADDR and
 * `TOP_CHIP_PINMUX_AON_BASE_ADDR + TOP_CHIP_PINMUX_AON_SIZE_BYTES`.
 */
#define TOP_CHIP_PINMUX_AON_SIZE_BYTES 0x1000u

/**
 * Peripheral base address for aon_timer_aon in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_AON_TIMER_AON_BASE_ADDR 0x40470000u

/**
 * Peripheral size for aon_timer_aon in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_AON_TIMER_AON_BASE_ADDR and
 * `TOP_CHIP_AON_TIMER_AON_BASE_ADDR + TOP_CHIP_AON_TIMER_AON_SIZE_BYTES`.
 */
#define TOP_CHIP_AON_TIMER_AON_SIZE_BYTES 0x40u

/**
 * Peripheral base address for ast in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_AST_BASE_ADDR 0x40480000u

/**
 * Peripheral size for ast in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_AST_BASE_ADDR and
 * `TOP_CHIP_AST_BASE_ADDR + TOP_CHIP_AST_SIZE_BYTES`.
 */
#define TOP_CHIP_AST_SIZE_BYTES 0x400u

/**
 * Peripheral base address for sensor_ctrl_aon in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_SENSOR_CTRL_AON_BASE_ADDR 0x40490000u

/**
 * Peripheral size for sensor_ctrl_aon in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_SENSOR_CTRL_AON_BASE_ADDR and
 * `TOP_CHIP_SENSOR_CTRL_AON_BASE_ADDR + TOP_CHIP_SENSOR_CTRL_AON_SIZE_BYTES`.
 */
#define TOP_CHIP_SENSOR_CTRL_AON_SIZE_BYTES 0x80u

/**
 * Peripheral base address for regs device on sram_ctrl_ret_aon in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_SRAM_CTRL_RET_AON_REGS_BASE_ADDR 0x40500000u

/**
 * Peripheral size for regs device on sram_ctrl_ret_aon in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_SRAM_CTRL_RET_AON_REGS_BASE_ADDR and
 * `TOP_CHIP_SRAM_CTRL_RET_AON_REGS_BASE_ADDR + TOP_CHIP_SRAM_CTRL_RET_AON_REGS_SIZE_BYTES`.
 */
#define TOP_CHIP_SRAM_CTRL_RET_AON_REGS_SIZE_BYTES 0x40u

/**
 * Peripheral base address for ram device on sram_ctrl_ret_aon in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_SRAM_CTRL_RET_AON_RAM_BASE_ADDR 0x40600000u

/**
 * Peripheral size for ram device on sram_ctrl_ret_aon in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_SRAM_CTRL_RET_AON_RAM_BASE_ADDR and
 * `TOP_CHIP_SRAM_CTRL_RET_AON_RAM_BASE_ADDR + TOP_CHIP_SRAM_CTRL_RET_AON_RAM_SIZE_BYTES`.
 */
#define TOP_CHIP_SRAM_CTRL_RET_AON_RAM_SIZE_BYTES 0x1000u

/**
 * Peripheral base address for core device on flash_ctrl in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_FLASH_CTRL_CORE_BASE_ADDR 0x41000000u

/**
 * Peripheral size for core device on flash_ctrl in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_FLASH_CTRL_CORE_BASE_ADDR and
 * `TOP_CHIP_FLASH_CTRL_CORE_BASE_ADDR + TOP_CHIP_FLASH_CTRL_CORE_SIZE_BYTES`.
 */
#define TOP_CHIP_FLASH_CTRL_CORE_SIZE_BYTES 0x200u

/**
 * Peripheral base address for prim device on flash_ctrl in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_FLASH_CTRL_PRIM_BASE_ADDR 0x41008000u

/**
 * Peripheral size for prim device on flash_ctrl in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_FLASH_CTRL_PRIM_BASE_ADDR and
 * `TOP_CHIP_FLASH_CTRL_PRIM_BASE_ADDR + TOP_CHIP_FLASH_CTRL_PRIM_SIZE_BYTES`.
 */
#define TOP_CHIP_FLASH_CTRL_PRIM_SIZE_BYTES 0x80u

/**
 * Peripheral base address for mem device on flash_ctrl in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_FLASH_CTRL_MEM_BASE_ADDR 0x20000000u

/**
 * Peripheral size for mem device on flash_ctrl in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_FLASH_CTRL_MEM_BASE_ADDR and
 * `TOP_CHIP_FLASH_CTRL_MEM_BASE_ADDR + TOP_CHIP_FLASH_CTRL_MEM_SIZE_BYTES`.
 */
#define TOP_CHIP_FLASH_CTRL_MEM_SIZE_BYTES 0x100000u

/**
 * Peripheral base address for regs device on rv_dm in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_RV_DM_REGS_BASE_ADDR 0x41200000u

/**
 * Peripheral size for regs device on rv_dm in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_RV_DM_REGS_BASE_ADDR and
 * `TOP_CHIP_RV_DM_REGS_BASE_ADDR + TOP_CHIP_RV_DM_REGS_SIZE_BYTES`.
 */
#define TOP_CHIP_RV_DM_REGS_SIZE_BYTES 0x10u

/**
 * Peripheral base address for mem device on rv_dm in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_RV_DM_MEM_BASE_ADDR 0x10000u

/**
 * Peripheral size for mem device on rv_dm in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_RV_DM_MEM_BASE_ADDR and
 * `TOP_CHIP_RV_DM_MEM_BASE_ADDR + TOP_CHIP_RV_DM_MEM_SIZE_BYTES`.
 */
#define TOP_CHIP_RV_DM_MEM_SIZE_BYTES 0x1000u

/**
 * Peripheral base address for rv_plic in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_RV_PLIC_BASE_ADDR 0x88000000u

/**
 * Peripheral size for rv_plic in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_RV_PLIC_BASE_ADDR and
 * `TOP_CHIP_RV_PLIC_BASE_ADDR + TOP_CHIP_RV_PLIC_SIZE_BYTES`.
 */
#define TOP_CHIP_RV_PLIC_SIZE_BYTES 0x8000000u

/**
 * Peripheral base address for aes in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_AES_BASE_ADDR 0x41100000u

/**
 * Peripheral size for aes in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_AES_BASE_ADDR and
 * `TOP_CHIP_AES_BASE_ADDR + TOP_CHIP_AES_SIZE_BYTES`.
 */
#define TOP_CHIP_AES_SIZE_BYTES 0x100u

/**
 * Peripheral base address for hmac in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_HMAC_BASE_ADDR 0x41110000u

/**
 * Peripheral size for hmac in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_HMAC_BASE_ADDR and
 * `TOP_CHIP_HMAC_BASE_ADDR + TOP_CHIP_HMAC_SIZE_BYTES`.
 */
#define TOP_CHIP_HMAC_SIZE_BYTES 0x2000u

/**
 * Peripheral base address for kmac in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_KMAC_BASE_ADDR 0x41120000u

/**
 * Peripheral size for kmac in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_KMAC_BASE_ADDR and
 * `TOP_CHIP_KMAC_BASE_ADDR + TOP_CHIP_KMAC_SIZE_BYTES`.
 */
#define TOP_CHIP_KMAC_SIZE_BYTES 0x1000u

/**
 * Peripheral base address for otbn in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_OTBN_BASE_ADDR 0x41130000u

/**
 * Peripheral size for otbn in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_OTBN_BASE_ADDR and
 * `TOP_CHIP_OTBN_BASE_ADDR + TOP_CHIP_OTBN_SIZE_BYTES`.
 */
#define TOP_CHIP_OTBN_SIZE_BYTES 0x10000u

/**
 * Peripheral base address for keymgr in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_KEYMGR_BASE_ADDR 0x41140000u

/**
 * Peripheral size for keymgr in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_KEYMGR_BASE_ADDR and
 * `TOP_CHIP_KEYMGR_BASE_ADDR + TOP_CHIP_KEYMGR_SIZE_BYTES`.
 */
#define TOP_CHIP_KEYMGR_SIZE_BYTES 0x100u

/**
 * Peripheral base address for csrng in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_CSRNG_BASE_ADDR 0x41150000u

/**
 * Peripheral size for csrng in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_CSRNG_BASE_ADDR and
 * `TOP_CHIP_CSRNG_BASE_ADDR + TOP_CHIP_CSRNG_SIZE_BYTES`.
 */
#define TOP_CHIP_CSRNG_SIZE_BYTES 0x80u

/**
 * Peripheral base address for entropy_src in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_ENTROPY_SRC_BASE_ADDR 0x41160000u

/**
 * Peripheral size for entropy_src in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_ENTROPY_SRC_BASE_ADDR and
 * `TOP_CHIP_ENTROPY_SRC_BASE_ADDR + TOP_CHIP_ENTROPY_SRC_SIZE_BYTES`.
 */
#define TOP_CHIP_ENTROPY_SRC_SIZE_BYTES 0x100u

/**
 * Peripheral base address for edn0 in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_EDN0_BASE_ADDR 0x41170000u

/**
 * Peripheral size for edn0 in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_EDN0_BASE_ADDR and
 * `TOP_CHIP_EDN0_BASE_ADDR + TOP_CHIP_EDN0_SIZE_BYTES`.
 */
#define TOP_CHIP_EDN0_SIZE_BYTES 0x80u

/**
 * Peripheral base address for edn1 in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_EDN1_BASE_ADDR 0x41180000u

/**
 * Peripheral size for edn1 in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_EDN1_BASE_ADDR and
 * `TOP_CHIP_EDN1_BASE_ADDR + TOP_CHIP_EDN1_SIZE_BYTES`.
 */
#define TOP_CHIP_EDN1_SIZE_BYTES 0x80u

/**
 * Peripheral base address for regs device on sram_ctrl_main in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_SRAM_CTRL_MAIN_REGS_BASE_ADDR 0x411C0000u

/**
 * Peripheral size for regs device on sram_ctrl_main in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_SRAM_CTRL_MAIN_REGS_BASE_ADDR and
 * `TOP_CHIP_SRAM_CTRL_MAIN_REGS_BASE_ADDR + TOP_CHIP_SRAM_CTRL_MAIN_REGS_SIZE_BYTES`.
 */
#define TOP_CHIP_SRAM_CTRL_MAIN_REGS_SIZE_BYTES 0x40u

/**
 * Peripheral base address for ram device on sram_ctrl_main in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_SRAM_CTRL_MAIN_RAM_BASE_ADDR 0x200000u

/**
 * Peripheral size for ram device on sram_ctrl_main in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_SRAM_CTRL_MAIN_RAM_BASE_ADDR and
 * `TOP_CHIP_SRAM_CTRL_MAIN_RAM_BASE_ADDR + TOP_CHIP_SRAM_CTRL_MAIN_RAM_SIZE_BYTES`.
 */
#define TOP_CHIP_SRAM_CTRL_MAIN_RAM_SIZE_BYTES 0x80000u

/**
 * Peripheral base address for regs device on rom_ctrl in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_ROM_CTRL_REGS_BASE_ADDR 0x411E0000u

/**
 * Peripheral size for regs device on rom_ctrl in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_ROM_CTRL_REGS_BASE_ADDR and
 * `TOP_CHIP_ROM_CTRL_REGS_BASE_ADDR + TOP_CHIP_ROM_CTRL_REGS_SIZE_BYTES`.
 */
#define TOP_CHIP_ROM_CTRL_REGS_SIZE_BYTES 0x80u

/**
 * Peripheral base address for rom device on rom_ctrl in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_ROM_CTRL_ROM_BASE_ADDR 0x100000u

/**
 * Peripheral size for rom device on rom_ctrl in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_ROM_CTRL_ROM_BASE_ADDR and
 * `TOP_CHIP_ROM_CTRL_ROM_BASE_ADDR + TOP_CHIP_ROM_CTRL_ROM_SIZE_BYTES`.
 */
#define TOP_CHIP_ROM_CTRL_ROM_SIZE_BYTES 0x1000u

/**
 * Peripheral base address for cfg device on rv_core_ibex in top earlgrey.
 *
 * This should be used with #mmio_region_from_addr to access the memory-mapped
 * registers associated with the peripheral (usually via a DIF).
 */
#define TOP_CHIP_RV_CORE_IBEX_CFG_BASE_ADDR 0x411F0000u

/**
 * Peripheral size for cfg device on rv_core_ibex in top earlgrey.
 *
 * This is the size (in bytes) of the peripheral's reserved memory area. All
 * memory-mapped registers associated with this peripheral should have an
 * address between #TOP_CHIP_RV_CORE_IBEX_CFG_BASE_ADDR and
 * `TOP_CHIP_RV_CORE_IBEX_CFG_BASE_ADDR + TOP_CHIP_RV_CORE_IBEX_CFG_SIZE_BYTES`.
 */
#define TOP_CHIP_RV_CORE_IBEX_CFG_SIZE_BYTES 0x100u


/**
 * Memory base address for ram_ret_aon in top earlgrey.
 */
#define TOP_CHIP_RAM_RET_AON_BASE_ADDR 0x40600000u

/**
 * Memory size for ram_ret_aon in top earlgrey.
 */
#define TOP_CHIP_RAM_RET_AON_SIZE_BYTES 0x1000u

/**
 * Memory base address for eflash in top earlgrey.
 */
#define TOP_CHIP_EFLASH_BASE_ADDR 0x20000000u

/**
 * Memory size for eflash in top earlgrey.
 */
#define TOP_CHIP_EFLASH_SIZE_BYTES 0x100000u

/**
 * Memory base address for ram_main in top earlgrey.
 */
#define TOP_CHIP_RAM_MAIN_BASE_ADDR 0x10000000u

/**
 * Memory size for ram_main in top earlgrey.
 */
#define TOP_CHIP_RAM_MAIN_SIZE_BYTES 0x20000u

/**
 * Memory base address for rom in top earlgrey.
 */
#define TOP_CHIP_ROM_BASE_ADDR 0x8000u

/**
 * Memory size for rom in top earlgrey.
 */
#define TOP_CHIP_ROM_SIZE_BYTES 0x8000u


/**
 * PLIC Interrupt Source Peripheral.
 *
 * Enumeration used to determine which peripheral asserted the corresponding
 * interrupt.
 */
typedef enum top_chip_plic_peripheral {
  kTopChipPlicPeripheralUnknown = 0, /**< Unknown Peripheral */
  kTopChipPlicPeripheralUart0 = 1, /**< uart0 */
  kTopChipPlicPeripheralUart1 = 2, /**< uart1 */
  kTopChipPlicPeripheralGpio = 3, /**< gpio */
  kTopChipPlicPeripheralI2c0 = 4, /**< i2c0 */
  kTopChipPlicPeripheralI2c1 = 5, /**< i2c1 */
  kTopChipPlicPeripheralPattgen = 6, /**< pattgen */
  kTopChipPlicPeripheralRvTimer = 7, /**< rv_timer */
  kTopChipPlicPeripheralSpiHost0 = 8, /**< spi_host0 */
  kTopChipPlicPeripheralSpiHost1 = 9, /**< spi_host1 */
  kTopChipPlicPeripheralUsbdev = 10, /**< usbdev */
  kTopChipPlicPeripheralAonTimerAon = 11, /**< aon_timer_aon */
  kTopChipPlicPeripheralLast = 11, /**< \internal Final PLIC peripheral */
} top_chip_plic_peripheral_t;

/**
 * PLIC Interrupt Source.
 *
 * Enumeration of all PLIC interrupt sources. The interrupt sources belonging to
 * the same peripheral are guaranteed to be consecutive.
 */
typedef enum top_chip_plic_irq_id {
  kTopChipPlicIrqIdNone = 0, /**< No Interrupt */
  kTopChipPlicIrqIdUart0TxWatermark = 1, /**< uart0_tx_watermark */
  kTopChipPlicIrqIdUart0RxWatermark = 2, /**< uart0_rx_watermark */
  kTopChipPlicIrqIdUart0TxDone = 3, /**< uart0_tx_done */
  kTopChipPlicIrqIdUart0RxOverflow = 4, /**< uart0_rx_overflow */
  kTopChipPlicIrqIdUart0RxFrameErr = 5, /**< uart0_rx_frame_err */
  kTopChipPlicIrqIdUart0RxBreakErr = 6, /**< uart0_rx_break_err */
  kTopChipPlicIrqIdUart0RxTimeout = 7, /**< uart0_rx_timeout */
  kTopChipPlicIrqIdUart0RxParityErr = 8, /**< uart0_rx_parity_err */
  kTopChipPlicIrqIdUart0TxEmpty = 9, /**< uart0_tx_empty */
  kTopChipPlicIrqIdUart1TxWatermark = 10, /**< uart1_tx_watermark */
  kTopChipPlicIrqIdUart1RxWatermark = 11, /**< uart1_rx_watermark */
  kTopChipPlicIrqIdUart1TxDone = 12, /**< uart1_tx_done */
  kTopChipPlicIrqIdUart1RxOverflow = 13, /**< uart1_rx_overflow */
  kTopChipPlicIrqIdUart1RxFrameErr = 14, /**< uart1_rx_frame_err */
  kTopChipPlicIrqIdUart1RxBreakErr = 15, /**< uart1_rx_break_err */
  kTopChipPlicIrqIdUart1RxTimeout = 16, /**< uart1_rx_timeout */
  kTopChipPlicIrqIdUart1RxParityErr = 17, /**< uart1_rx_parity_err */
  kTopChipPlicIrqIdUart1TxEmpty = 18, /**< uart1_tx_empty */
  kTopChipPlicIrqIdUart2TxWatermark = 19, /**< uart2_tx_watermark */
  kTopChipPlicIrqIdUart2RxWatermark = 20, /**< uart2_rx_watermark */
  kTopChipPlicIrqIdUart2TxDone = 21, /**< uart2_tx_done */
  kTopChipPlicIrqIdUart2RxOverflow = 22, /**< uart2_rx_overflow */
  kTopChipPlicIrqIdUart2RxFrameErr = 23, /**< uart2_rx_frame_err */
  kTopChipPlicIrqIdUart2RxBreakErr = 24, /**< uart2_rx_break_err */
  kTopChipPlicIrqIdUart2RxTimeout = 25, /**< uart2_rx_timeout */
  kTopChipPlicIrqIdUart2RxParityErr = 26, /**< uart2_rx_parity_err */
  kTopChipPlicIrqIdUart2TxEmpty = 27, /**< uart2_tx_empty */
  kTopChipPlicIrqIdUart3TxWatermark = 28, /**< uart3_tx_watermark */
  kTopChipPlicIrqIdUart3RxWatermark = 29, /**< uart3_rx_watermark */
  kTopChipPlicIrqIdUart3TxDone = 30, /**< uart3_tx_done */
  kTopChipPlicIrqIdUart3RxOverflow = 31, /**< uart3_rx_overflow */
  kTopChipPlicIrqIdUart3RxFrameErr = 32, /**< uart3_rx_frame_err */
  kTopChipPlicIrqIdUart3RxBreakErr = 33, /**< uart3_rx_break_err */
  kTopChipPlicIrqIdUart3RxTimeout = 34, /**< uart3_rx_timeout */
  kTopChipPlicIrqIdUart3RxParityErr = 35, /**< uart3_rx_parity_err */
  kTopChipPlicIrqIdUart3TxEmpty = 36, /**< uart3_tx_empty */
  kTopChipPlicIrqIdGpioGpio0 = 37, /**< gpio_gpio 0 */
  kTopChipPlicIrqIdGpioGpio1 = 38, /**< gpio_gpio 1 */
  kTopChipPlicIrqIdGpioGpio2 = 39, /**< gpio_gpio 2 */
  kTopChipPlicIrqIdGpioGpio3 = 40, /**< gpio_gpio 3 */
  kTopChipPlicIrqIdGpioGpio4 = 41, /**< gpio_gpio 4 */
  kTopChipPlicIrqIdGpioGpio5 = 42, /**< gpio_gpio 5 */
  kTopChipPlicIrqIdGpioGpio6 = 43, /**< gpio_gpio 6 */
  kTopChipPlicIrqIdGpioGpio7 = 44, /**< gpio_gpio 7 */
  kTopChipPlicIrqIdGpioGpio8 = 45, /**< gpio_gpio 8 */
  kTopChipPlicIrqIdGpioGpio9 = 46, /**< gpio_gpio 9 */
  kTopChipPlicIrqIdGpioGpio10 = 47, /**< gpio_gpio 10 */
  kTopChipPlicIrqIdGpioGpio11 = 48, /**< gpio_gpio 11 */
  kTopChipPlicIrqIdGpioGpio12 = 49, /**< gpio_gpio 12 */
  kTopChipPlicIrqIdGpioGpio13 = 50, /**< gpio_gpio 13 */
  kTopChipPlicIrqIdGpioGpio14 = 51, /**< gpio_gpio 14 */
  kTopChipPlicIrqIdGpioGpio15 = 52, /**< gpio_gpio 15 */
  kTopChipPlicIrqIdGpioGpio16 = 53, /**< gpio_gpio 16 */
  kTopChipPlicIrqIdGpioGpio17 = 54, /**< gpio_gpio 17 */
  kTopChipPlicIrqIdGpioGpio18 = 55, /**< gpio_gpio 18 */
  kTopChipPlicIrqIdGpioGpio19 = 56, /**< gpio_gpio 19 */
  kTopChipPlicIrqIdGpioGpio20 = 57, /**< gpio_gpio 20 */
  kTopChipPlicIrqIdGpioGpio21 = 58, /**< gpio_gpio 21 */
  kTopChipPlicIrqIdGpioGpio22 = 59, /**< gpio_gpio 22 */
  kTopChipPlicIrqIdGpioGpio23 = 60, /**< gpio_gpio 23 */
  kTopChipPlicIrqIdGpioGpio24 = 61, /**< gpio_gpio 24 */
  kTopChipPlicIrqIdGpioGpio25 = 62, /**< gpio_gpio 25 */
  kTopChipPlicIrqIdGpioGpio26 = 63, /**< gpio_gpio 26 */
  kTopChipPlicIrqIdGpioGpio27 = 64, /**< gpio_gpio 27 */
  kTopChipPlicIrqIdGpioGpio28 = 65, /**< gpio_gpio 28 */
  kTopChipPlicIrqIdGpioGpio29 = 66, /**< gpio_gpio 29 */
  kTopChipPlicIrqIdGpioGpio30 = 67, /**< gpio_gpio 30 */
  kTopChipPlicIrqIdGpioGpio31 = 68, /**< gpio_gpio 31 */
  kTopChipPlicIrqIdSpiDeviceUploadCmdfifoNotEmpty = 69, /**< spi_device_upload_cmdfifo_not_empty */
  kTopChipPlicIrqIdSpiDeviceUploadPayloadNotEmpty = 70, /**< spi_device_upload_payload_not_empty */
  kTopChipPlicIrqIdSpiDeviceUploadPayloadOverflow = 71, /**< spi_device_upload_payload_overflow */
  kTopChipPlicIrqIdSpiDeviceReadbufWatermark = 72, /**< spi_device_readbuf_watermark */
  kTopChipPlicIrqIdSpiDeviceReadbufFlip = 73, /**< spi_device_readbuf_flip */
  kTopChipPlicIrqIdSpiDeviceTpmHeaderNotEmpty = 74, /**< spi_device_tpm_header_not_empty */
  kTopChipPlicIrqIdSpiDeviceTpmRdfifoCmdEnd = 75, /**< spi_device_tpm_rdfifo_cmd_end */
  kTopChipPlicIrqIdSpiDeviceTpmRdfifoDrop = 76, /**< spi_device_tpm_rdfifo_drop */
  kTopChipPlicIrqIdI2c0FmtThreshold = 77, /**< i2c0_fmt_threshold */
  kTopChipPlicIrqIdI2c0RxThreshold = 78, /**< i2c0_rx_threshold */
  kTopChipPlicIrqIdI2c0AcqThreshold = 79, /**< i2c0_acq_threshold */
  kTopChipPlicIrqIdI2c0RxOverflow = 80, /**< i2c0_rx_overflow */
  kTopChipPlicIrqIdI2c0ControllerHalt = 81, /**< i2c0_controller_halt */
  kTopChipPlicIrqIdI2c0SclInterference = 82, /**< i2c0_scl_interference */
  kTopChipPlicIrqIdI2c0SdaInterference = 83, /**< i2c0_sda_interference */
  kTopChipPlicIrqIdI2c0StretchTimeout = 84, /**< i2c0_stretch_timeout */
  kTopChipPlicIrqIdI2c0SdaUnstable = 85, /**< i2c0_sda_unstable */
  kTopChipPlicIrqIdI2c0CmdComplete = 86, /**< i2c0_cmd_complete */
  kTopChipPlicIrqIdI2c0TxStretch = 87, /**< i2c0_tx_stretch */
  kTopChipPlicIrqIdI2c0TxThreshold = 88, /**< i2c0_tx_threshold */
  kTopChipPlicIrqIdI2c0AcqStretch = 89, /**< i2c0_acq_stretch */
  kTopChipPlicIrqIdI2c0UnexpStop = 90, /**< i2c0_unexp_stop */
  kTopChipPlicIrqIdI2c0HostTimeout = 91, /**< i2c0_host_timeout */
  kTopChipPlicIrqIdI2c1FmtThreshold = 92, /**< i2c1_fmt_threshold */
  kTopChipPlicIrqIdI2c1RxThreshold = 93, /**< i2c1_rx_threshold */
  kTopChipPlicIrqIdI2c1AcqThreshold = 94, /**< i2c1_acq_threshold */
  kTopChipPlicIrqIdI2c1RxOverflow = 95, /**< i2c1_rx_overflow */
  kTopChipPlicIrqIdI2c1ControllerHalt = 96, /**< i2c1_controller_halt */
  kTopChipPlicIrqIdI2c1SclInterference = 97, /**< i2c1_scl_interference */
  kTopChipPlicIrqIdI2c1SdaInterference = 98, /**< i2c1_sda_interference */
  kTopChipPlicIrqIdI2c1StretchTimeout = 99, /**< i2c1_stretch_timeout */
  kTopChipPlicIrqIdI2c1SdaUnstable = 100, /**< i2c1_sda_unstable */
  kTopChipPlicIrqIdI2c1CmdComplete = 101, /**< i2c1_cmd_complete */
  kTopChipPlicIrqIdI2c1TxStretch = 102, /**< i2c1_tx_stretch */
  kTopChipPlicIrqIdI2c1TxThreshold = 103, /**< i2c1_tx_threshold */
  kTopChipPlicIrqIdI2c1AcqStretch = 104, /**< i2c1_acq_stretch */
  kTopChipPlicIrqIdI2c1UnexpStop = 105, /**< i2c1_unexp_stop */
  kTopChipPlicIrqIdI2c1HostTimeout = 106, /**< i2c1_host_timeout */
  kTopChipPlicIrqIdI2c2FmtThreshold = 107, /**< i2c2_fmt_threshold */
  kTopChipPlicIrqIdI2c2RxThreshold = 108, /**< i2c2_rx_threshold */
  kTopChipPlicIrqIdI2c2AcqThreshold = 109, /**< i2c2_acq_threshold */
  kTopChipPlicIrqIdI2c2RxOverflow = 110, /**< i2c2_rx_overflow */
  kTopChipPlicIrqIdI2c2ControllerHalt = 111, /**< i2c2_controller_halt */
  kTopChipPlicIrqIdI2c2SclInterference = 112, /**< i2c2_scl_interference */
  kTopChipPlicIrqIdI2c2SdaInterference = 113, /**< i2c2_sda_interference */
  kTopChipPlicIrqIdI2c2StretchTimeout = 114, /**< i2c2_stretch_timeout */
  kTopChipPlicIrqIdI2c2SdaUnstable = 115, /**< i2c2_sda_unstable */
  kTopChipPlicIrqIdI2c2CmdComplete = 116, /**< i2c2_cmd_complete */
  kTopChipPlicIrqIdI2c2TxStretch = 117, /**< i2c2_tx_stretch */
  kTopChipPlicIrqIdI2c2TxThreshold = 118, /**< i2c2_tx_threshold */
  kTopChipPlicIrqIdI2c2AcqStretch = 119, /**< i2c2_acq_stretch */
  kTopChipPlicIrqIdI2c2UnexpStop = 120, /**< i2c2_unexp_stop */
  kTopChipPlicIrqIdI2c2HostTimeout = 121, /**< i2c2_host_timeout */
  kTopChipPlicIrqIdPattgenDoneCh0 = 122, /**< pattgen_done_ch0 */
  kTopChipPlicIrqIdPattgenDoneCh1 = 123, /**< pattgen_done_ch1 */
  kTopChipPlicIrqIdRvTimerTimerExpiredHart0Timer0 = 124, /**< rv_timer_timer_expired_hart0_timer0 */
  kTopChipPlicIrqIdOtpCtrlOtpOperationDone = 125, /**< otp_ctrl_otp_operation_done */
  kTopChipPlicIrqIdOtpCtrlOtpError = 126, /**< otp_ctrl_otp_error */
  kTopChipPlicIrqIdAlertHandlerClassa = 127, /**< alert_handler_classa */
  kTopChipPlicIrqIdAlertHandlerClassb = 128, /**< alert_handler_classb */
  kTopChipPlicIrqIdAlertHandlerClassc = 129, /**< alert_handler_classc */
  kTopChipPlicIrqIdAlertHandlerClassd = 130, /**< alert_handler_classd */
  kTopChipPlicIrqIdSpiHost0Error = 131, /**< spi_host0_error */
  kTopChipPlicIrqIdSpiHost0SpiEvent = 132, /**< spi_host0_spi_event */
  kTopChipPlicIrqIdSpiHost1Error = 133, /**< spi_host1_error */
  kTopChipPlicIrqIdSpiHost1SpiEvent = 134, /**< spi_host1_spi_event */
  kTopChipPlicIrqIdUsbdevPktReceived = 135, /**< usbdev_pkt_received */
  kTopChipPlicIrqIdUsbdevPktSent = 136, /**< usbdev_pkt_sent */
  kTopChipPlicIrqIdUsbdevDisconnected = 137, /**< usbdev_disconnected */
  kTopChipPlicIrqIdUsbdevHostLost = 138, /**< usbdev_host_lost */
  kTopChipPlicIrqIdUsbdevLinkReset = 139, /**< usbdev_link_reset */
  kTopChipPlicIrqIdUsbdevLinkSuspend = 140, /**< usbdev_link_suspend */
  kTopChipPlicIrqIdUsbdevLinkResume = 141, /**< usbdev_link_resume */
  kTopChipPlicIrqIdUsbdevAvOutEmpty = 142, /**< usbdev_av_out_empty */
  kTopChipPlicIrqIdUsbdevRxFull = 143, /**< usbdev_rx_full */
  kTopChipPlicIrqIdUsbdevAvOverflow = 144, /**< usbdev_av_overflow */
  kTopChipPlicIrqIdUsbdevLinkInErr = 145, /**< usbdev_link_in_err */
  kTopChipPlicIrqIdUsbdevRxCrcErr = 146, /**< usbdev_rx_crc_err */
  kTopChipPlicIrqIdUsbdevRxPidErr = 147, /**< usbdev_rx_pid_err */
  kTopChipPlicIrqIdUsbdevRxBitstuffErr = 148, /**< usbdev_rx_bitstuff_err */
  kTopChipPlicIrqIdUsbdevFrame = 149, /**< usbdev_frame */
  kTopChipPlicIrqIdUsbdevPowered = 150, /**< usbdev_powered */
  kTopChipPlicIrqIdUsbdevLinkOutErr = 151, /**< usbdev_link_out_err */
  kTopChipPlicIrqIdUsbdevAvSetupEmpty = 152, /**< usbdev_av_setup_empty */
  kTopChipPlicIrqIdPwrmgrAonWakeup = 153, /**< pwrmgr_aon_wakeup */
  kTopChipPlicIrqIdSysrstCtrlAonEventDetected = 154, /**< sysrst_ctrl_aon_event_detected */
  kTopChipPlicIrqIdAdcCtrlAonMatchPending = 155, /**< adc_ctrl_aon_match_pending */
  kTopChipPlicIrqIdAonTimerAonWkupTimerExpired = 156, /**< aon_timer_aon_wkup_timer_expired */
  kTopChipPlicIrqIdAonTimerAonWdogTimerBark = 157, /**< aon_timer_aon_wdog_timer_bark */
  kTopChipPlicIrqIdSensorCtrlAonIoStatusChange = 158, /**< sensor_ctrl_aon_io_status_change */
  kTopChipPlicIrqIdSensorCtrlAonInitStatusChange = 159, /**< sensor_ctrl_aon_init_status_change */
  kTopChipPlicIrqIdFlashCtrlProgEmpty = 160, /**< flash_ctrl_prog_empty */
  kTopChipPlicIrqIdFlashCtrlProgLvl = 161, /**< flash_ctrl_prog_lvl */
  kTopChipPlicIrqIdFlashCtrlRdFull = 162, /**< flash_ctrl_rd_full */
  kTopChipPlicIrqIdFlashCtrlRdLvl = 163, /**< flash_ctrl_rd_lvl */
  kTopChipPlicIrqIdFlashCtrlOpDone = 164, /**< flash_ctrl_op_done */
  kTopChipPlicIrqIdFlashCtrlCorrErr = 165, /**< flash_ctrl_corr_err */
  kTopChipPlicIrqIdHmacHmacDone = 166, /**< hmac_hmac_done */
  kTopChipPlicIrqIdHmacFifoEmpty = 167, /**< hmac_fifo_empty */
  kTopChipPlicIrqIdHmacHmacErr = 168, /**< hmac_hmac_err */
  kTopChipPlicIrqIdKmacKmacDone = 169, /**< kmac_kmac_done */
  kTopChipPlicIrqIdKmacFifoEmpty = 170, /**< kmac_fifo_empty */
  kTopChipPlicIrqIdKmacKmacErr = 171, /**< kmac_kmac_err */
  kTopChipPlicIrqIdOtbnDone = 172, /**< otbn_done */
  kTopChipPlicIrqIdKeymgrOpDone = 173, /**< keymgr_op_done */
  kTopChipPlicIrqIdCsrngCsCmdReqDone = 174, /**< csrng_cs_cmd_req_done */
  kTopChipPlicIrqIdCsrngCsEntropyReq = 175, /**< csrng_cs_entropy_req */
  kTopChipPlicIrqIdCsrngCsHwInstExc = 176, /**< csrng_cs_hw_inst_exc */
  kTopChipPlicIrqIdCsrngCsFatalErr = 177, /**< csrng_cs_fatal_err */
  kTopChipPlicIrqIdEntropySrcEsEntropyValid = 178, /**< entropy_src_es_entropy_valid */
  kTopChipPlicIrqIdEntropySrcEsHealthTestFailed = 179, /**< entropy_src_es_health_test_failed */
  kTopChipPlicIrqIdEntropySrcEsObserveFifoReady = 180, /**< entropy_src_es_observe_fifo_ready */
  kTopChipPlicIrqIdEntropySrcEsFatalErr = 181, /**< entropy_src_es_fatal_err */
  kTopChipPlicIrqIdEdn0EdnCmdReqDone = 182, /**< edn0_edn_cmd_req_done */
  kTopChipPlicIrqIdEdn0EdnFatalErr = 183, /**< edn0_edn_fatal_err */
  kTopChipPlicIrqIdEdn1EdnCmdReqDone = 184, /**< edn1_edn_cmd_req_done */
  kTopChipPlicIrqIdEdn1EdnFatalErr = 185, /**< edn1_edn_fatal_err */
  kTopChipPlicIrqIdLast = 185, /**< \internal The Last Valid Interrupt ID. */
} top_chip_plic_irq_id_t;

/**
 * PLIC Interrupt Source to Peripheral Map
 *
 * This array is a mapping from `top_chip_plic_irq_id_t` to
 * `top_chip_plic_peripheral_t`.
 */
extern const top_chip_plic_peripheral_t
    top_chip_plic_interrupt_for_peripheral[32];

/**
 * PLIC Interrupt Target.
 *
 * Enumeration used to determine which set of IE, CC, threshold registers to
 * access for a given interrupt target.
 */
typedef enum top_chip_plic_target {
  kTopChipPlicTargetIbex0 = 0, /**< Ibex Core 0 */
  kTopChipPlicTargetLast = 0, /**< \internal Final PLIC target */
} top_chip_plic_target_t;

#define PINMUX_MIO_PERIPH_INSEL_IDX_OFFSET 2

// PERIPH_INSEL ranges from 0 to NUM_MIO_PADS + 2 -1}
//  0 and 1 are tied to value 0 and 1
#define NUM_MIO_PADS 47
#define NUM_DIO_PADS 16

#define PINMUX_PERIPH_OUTSEL_IDX_OFFSET 3

/**
 * Pinmux Peripheral Input.
 */
typedef enum top_chip_pinmux_peripheral_in {
  kTopChipPinmuxPeripheralInGpioGpio0 = 0, /**< Peripheral Input 0 */
  kTopChipPinmuxPeripheralInGpioGpio1 = 1, /**< Peripheral Input 1 */
  kTopChipPinmuxPeripheralInGpioGpio2 = 2, /**< Peripheral Input 2 */
  kTopChipPinmuxPeripheralInGpioGpio3 = 3, /**< Peripheral Input 3 */
  kTopChipPinmuxPeripheralInGpioGpio4 = 4, /**< Peripheral Input 4 */
  kTopChipPinmuxPeripheralInGpioGpio5 = 5, /**< Peripheral Input 5 */
  kTopChipPinmuxPeripheralInGpioGpio6 = 6, /**< Peripheral Input 6 */
  kTopChipPinmuxPeripheralInGpioGpio7 = 7, /**< Peripheral Input 7 */
  kTopChipPinmuxPeripheralInGpioGpio8 = 8, /**< Peripheral Input 8 */
  kTopChipPinmuxPeripheralInGpioGpio9 = 9, /**< Peripheral Input 9 */
  kTopChipPinmuxPeripheralInGpioGpio10 = 10, /**< Peripheral Input 10 */
  kTopChipPinmuxPeripheralInGpioGpio11 = 11, /**< Peripheral Input 11 */
  kTopChipPinmuxPeripheralInGpioGpio12 = 12, /**< Peripheral Input 12 */
  kTopChipPinmuxPeripheralInGpioGpio13 = 13, /**< Peripheral Input 13 */
  kTopChipPinmuxPeripheralInGpioGpio14 = 14, /**< Peripheral Input 14 */
  kTopChipPinmuxPeripheralInGpioGpio15 = 15, /**< Peripheral Input 15 */
  kTopChipPinmuxPeripheralInGpioGpio16 = 16, /**< Peripheral Input 16 */
  kTopChipPinmuxPeripheralInGpioGpio17 = 17, /**< Peripheral Input 17 */
  kTopChipPinmuxPeripheralInGpioGpio18 = 18, /**< Peripheral Input 18 */
  kTopChipPinmuxPeripheralInGpioGpio19 = 19, /**< Peripheral Input 19 */
  kTopChipPinmuxPeripheralInGpioGpio20 = 20, /**< Peripheral Input 20 */
  kTopChipPinmuxPeripheralInGpioGpio21 = 21, /**< Peripheral Input 21 */
  kTopChipPinmuxPeripheralInGpioGpio22 = 22, /**< Peripheral Input 22 */
  kTopChipPinmuxPeripheralInGpioGpio23 = 23, /**< Peripheral Input 23 */
  kTopChipPinmuxPeripheralInGpioGpio24 = 24, /**< Peripheral Input 24 */
  kTopChipPinmuxPeripheralInGpioGpio25 = 25, /**< Peripheral Input 25 */
  kTopChipPinmuxPeripheralInGpioGpio26 = 26, /**< Peripheral Input 26 */
  kTopChipPinmuxPeripheralInGpioGpio27 = 27, /**< Peripheral Input 27 */
  kTopChipPinmuxPeripheralInGpioGpio28 = 28, /**< Peripheral Input 28 */
  kTopChipPinmuxPeripheralInGpioGpio29 = 29, /**< Peripheral Input 29 */
  kTopChipPinmuxPeripheralInGpioGpio30 = 30, /**< Peripheral Input 30 */
  kTopChipPinmuxPeripheralInGpioGpio31 = 31, /**< Peripheral Input 31 */
  kTopChipPinmuxPeripheralInI2c0Sda = 32, /**< Peripheral Input 32 */
  kTopChipPinmuxPeripheralInI2c0Scl = 33, /**< Peripheral Input 33 */
  kTopChipPinmuxPeripheralInI2c1Sda = 34, /**< Peripheral Input 34 */
  kTopChipPinmuxPeripheralInI2c1Scl = 35, /**< Peripheral Input 35 */
  kTopChipPinmuxPeripheralInI2c2Sda = 36, /**< Peripheral Input 36 */
  kTopChipPinmuxPeripheralInI2c2Scl = 37, /**< Peripheral Input 37 */
  kTopChipPinmuxPeripheralInSpiHost1Sd0 = 38, /**< Peripheral Input 38 */
  kTopChipPinmuxPeripheralInSpiHost1Sd1 = 39, /**< Peripheral Input 39 */
  kTopChipPinmuxPeripheralInSpiHost1Sd2 = 40, /**< Peripheral Input 40 */
  kTopChipPinmuxPeripheralInSpiHost1Sd3 = 41, /**< Peripheral Input 41 */
  kTopChipPinmuxPeripheralInUart0Rx = 42, /**< Peripheral Input 42 */
  kTopChipPinmuxPeripheralInUart1Rx = 43, /**< Peripheral Input 43 */
  kTopChipPinmuxPeripheralInUart2Rx = 44, /**< Peripheral Input 44 */
  kTopChipPinmuxPeripheralInUart3Rx = 45, /**< Peripheral Input 45 */
  kTopChipPinmuxPeripheralInSpiDeviceTpmCsb = 46, /**< Peripheral Input 46 */
  kTopChipPinmuxPeripheralInFlashCtrlTck = 47, /**< Peripheral Input 47 */
  kTopChipPinmuxPeripheralInFlashCtrlTms = 48, /**< Peripheral Input 48 */
  kTopChipPinmuxPeripheralInFlashCtrlTdi = 49, /**< Peripheral Input 49 */
  kTopChipPinmuxPeripheralInSysrstCtrlAonAcPresent = 50, /**< Peripheral Input 50 */
  kTopChipPinmuxPeripheralInSysrstCtrlAonKey0In = 51, /**< Peripheral Input 51 */
  kTopChipPinmuxPeripheralInSysrstCtrlAonKey1In = 52, /**< Peripheral Input 52 */
  kTopChipPinmuxPeripheralInSysrstCtrlAonKey2In = 53, /**< Peripheral Input 53 */
  kTopChipPinmuxPeripheralInSysrstCtrlAonPwrbIn = 54, /**< Peripheral Input 54 */
  kTopChipPinmuxPeripheralInSysrstCtrlAonLidOpen = 55, /**< Peripheral Input 55 */
  kTopChipPinmuxPeripheralInUsbdevSense = 56, /**< Peripheral Input 56 */
  kTopChipPinmuxPeripheralInLast = 56, /**< \internal Last valid peripheral input */
} top_chip_pinmux_peripheral_in_t;

/**
 * Pinmux MIO Input Selector.
 */
typedef enum top_chip_pinmux_insel {
  kTopChipPinmuxInselConstantZero = 0, /**< Tie constantly to zero */
  kTopChipPinmuxInselConstantOne = 1, /**< Tie constantly to one */
  kTopChipPinmuxInselIoa0 = 2, /**< MIO Pad 0 */
  kTopChipPinmuxInselIoa1 = 3, /**< MIO Pad 1 */
  kTopChipPinmuxInselIoa2 = 4, /**< MIO Pad 2 */
  kTopChipPinmuxInselIoa3 = 5, /**< MIO Pad 3 */
  kTopChipPinmuxInselIoa4 = 6, /**< MIO Pad 4 */
  kTopChipPinmuxInselIoa5 = 7, /**< MIO Pad 5 */
  kTopChipPinmuxInselIoa6 = 8, /**< MIO Pad 6 */
  kTopChipPinmuxInselIoa7 = 9, /**< MIO Pad 7 */
  kTopChipPinmuxInselIoa8 = 10, /**< MIO Pad 8 */
  kTopChipPinmuxInselIob0 = 11, /**< MIO Pad 9 */
  kTopChipPinmuxInselIob1 = 12, /**< MIO Pad 10 */
  kTopChipPinmuxInselIob2 = 13, /**< MIO Pad 11 */
  kTopChipPinmuxInselIob3 = 14, /**< MIO Pad 12 */
  kTopChipPinmuxInselIob4 = 15, /**< MIO Pad 13 */
  kTopChipPinmuxInselIob5 = 16, /**< MIO Pad 14 */
  kTopChipPinmuxInselIob6 = 17, /**< MIO Pad 15 */
  kTopChipPinmuxInselIob7 = 18, /**< MIO Pad 16 */
  kTopChipPinmuxInselIob8 = 19, /**< MIO Pad 17 */
  kTopChipPinmuxInselIob9 = 20, /**< MIO Pad 18 */
  kTopChipPinmuxInselIob10 = 21, /**< MIO Pad 19 */
  kTopChipPinmuxInselIob11 = 22, /**< MIO Pad 20 */
  kTopChipPinmuxInselIob12 = 23, /**< MIO Pad 21 */
  kTopChipPinmuxInselIoc0 = 24, /**< MIO Pad 22 */
  kTopChipPinmuxInselIoc1 = 25, /**< MIO Pad 23 */
  kTopChipPinmuxInselIoc2 = 26, /**< MIO Pad 24 */
  kTopChipPinmuxInselIoc3 = 27, /**< MIO Pad 25 */
  kTopChipPinmuxInselIoc4 = 28, /**< MIO Pad 26 */
  kTopChipPinmuxInselIoc5 = 29, /**< MIO Pad 27 */
  kTopChipPinmuxInselIoc6 = 30, /**< MIO Pad 28 */
  kTopChipPinmuxInselIoc7 = 31, /**< MIO Pad 29 */
  kTopChipPinmuxInselIoc8 = 32, /**< MIO Pad 30 */
  kTopChipPinmuxInselIoc9 = 33, /**< MIO Pad 31 */
  kTopChipPinmuxInselIoc10 = 34, /**< MIO Pad 32 */
  kTopChipPinmuxInselIoc11 = 35, /**< MIO Pad 33 */
  kTopChipPinmuxInselIoc12 = 36, /**< MIO Pad 34 */
  kTopChipPinmuxInselIor0 = 37, /**< MIO Pad 35 */
  kTopChipPinmuxInselIor1 = 38, /**< MIO Pad 36 */
  kTopChipPinmuxInselIor2 = 39, /**< MIO Pad 37 */
  kTopChipPinmuxInselIor3 = 40, /**< MIO Pad 38 */
  kTopChipPinmuxInselIor4 = 41, /**< MIO Pad 39 */
  kTopChipPinmuxInselIor5 = 42, /**< MIO Pad 40 */
  kTopChipPinmuxInselIor6 = 43, /**< MIO Pad 41 */
  kTopChipPinmuxInselIor7 = 44, /**< MIO Pad 42 */
  kTopChipPinmuxInselIor10 = 45, /**< MIO Pad 43 */
  kTopChipPinmuxInselIor11 = 46, /**< MIO Pad 44 */
  kTopChipPinmuxInselIor12 = 47, /**< MIO Pad 45 */
  kTopChipPinmuxInselIor13 = 48, /**< MIO Pad 46 */
  kTopChipPinmuxInselLast = 48, /**< \internal Last valid insel value */
} top_chip_pinmux_insel_t;

/**
 * Pinmux MIO Output.
 */
typedef enum top_chip_pinmux_mio_out {
  kTopChipPinmuxMioOutIoa0 = 0, /**< MIO Pad 0 */
  kTopChipPinmuxMioOutIoa1 = 1, /**< MIO Pad 1 */
  kTopChipPinmuxMioOutIoa2 = 2, /**< MIO Pad 2 */
  kTopChipPinmuxMioOutIoa3 = 3, /**< MIO Pad 3 */
  kTopChipPinmuxMioOutIoa4 = 4, /**< MIO Pad 4 */
  kTopChipPinmuxMioOutIoa5 = 5, /**< MIO Pad 5 */
  kTopChipPinmuxMioOutIoa6 = 6, /**< MIO Pad 6 */
  kTopChipPinmuxMioOutIoa7 = 7, /**< MIO Pad 7 */
  kTopChipPinmuxMioOutIoa8 = 8, /**< MIO Pad 8 */
  kTopChipPinmuxMioOutIob0 = 9, /**< MIO Pad 9 */
  kTopChipPinmuxMioOutIob1 = 10, /**< MIO Pad 10 */
  kTopChipPinmuxMioOutIob2 = 11, /**< MIO Pad 11 */
  kTopChipPinmuxMioOutIob3 = 12, /**< MIO Pad 12 */
  kTopChipPinmuxMioOutIob4 = 13, /**< MIO Pad 13 */
  kTopChipPinmuxMioOutIob5 = 14, /**< MIO Pad 14 */
  kTopChipPinmuxMioOutIob6 = 15, /**< MIO Pad 15 */
  kTopChipPinmuxMioOutIob7 = 16, /**< MIO Pad 16 */
  kTopChipPinmuxMioOutIob8 = 17, /**< MIO Pad 17 */
  kTopChipPinmuxMioOutIob9 = 18, /**< MIO Pad 18 */
  kTopChipPinmuxMioOutIob10 = 19, /**< MIO Pad 19 */
  kTopChipPinmuxMioOutIob11 = 20, /**< MIO Pad 20 */
  kTopChipPinmuxMioOutIob12 = 21, /**< MIO Pad 21 */
  kTopChipPinmuxMioOutIoc0 = 22, /**< MIO Pad 22 */
  kTopChipPinmuxMioOutIoc1 = 23, /**< MIO Pad 23 */
  kTopChipPinmuxMioOutIoc2 = 24, /**< MIO Pad 24 */
  kTopChipPinmuxMioOutIoc3 = 25, /**< MIO Pad 25 */
  kTopChipPinmuxMioOutIoc4 = 26, /**< MIO Pad 26 */
  kTopChipPinmuxMioOutIoc5 = 27, /**< MIO Pad 27 */
  kTopChipPinmuxMioOutIoc6 = 28, /**< MIO Pad 28 */
  kTopChipPinmuxMioOutIoc7 = 29, /**< MIO Pad 29 */
  kTopChipPinmuxMioOutIoc8 = 30, /**< MIO Pad 30 */
  kTopChipPinmuxMioOutIoc9 = 31, /**< MIO Pad 31 */
  kTopChipPinmuxMioOutIoc10 = 32, /**< MIO Pad 32 */
  kTopChipPinmuxMioOutIoc11 = 33, /**< MIO Pad 33 */
  kTopChipPinmuxMioOutIoc12 = 34, /**< MIO Pad 34 */
  kTopChipPinmuxMioOutIor0 = 35, /**< MIO Pad 35 */
  kTopChipPinmuxMioOutIor1 = 36, /**< MIO Pad 36 */
  kTopChipPinmuxMioOutIor2 = 37, /**< MIO Pad 37 */
  kTopChipPinmuxMioOutIor3 = 38, /**< MIO Pad 38 */
  kTopChipPinmuxMioOutIor4 = 39, /**< MIO Pad 39 */
  kTopChipPinmuxMioOutIor5 = 40, /**< MIO Pad 40 */
  kTopChipPinmuxMioOutIor6 = 41, /**< MIO Pad 41 */
  kTopChipPinmuxMioOutIor7 = 42, /**< MIO Pad 42 */
  kTopChipPinmuxMioOutIor10 = 43, /**< MIO Pad 43 */
  kTopChipPinmuxMioOutIor11 = 44, /**< MIO Pad 44 */
  kTopChipPinmuxMioOutIor12 = 45, /**< MIO Pad 45 */
  kTopChipPinmuxMioOutIor13 = 46, /**< MIO Pad 46 */
  kTopChipPinmuxMioOutLast = 46, /**< \internal Last valid mio output */
} top_chip_pinmux_mio_out_t;

/**
 * Pinmux Peripheral Output Selector.
 */
typedef enum top_chip_pinmux_outsel {
  kTopChipPinmuxOutselConstantZero = 0, /**< Tie constantly to zero */
  kTopChipPinmuxOutselConstantOne = 1, /**< Tie constantly to one */
  kTopChipPinmuxOutselConstantHighZ = 2, /**< Tie constantly to high-Z */
  kTopChipPinmuxOutselGpioGpio0 = 3, /**< Peripheral Output 0 */
  kTopChipPinmuxOutselGpioGpio1 = 4, /**< Peripheral Output 1 */
  kTopChipPinmuxOutselGpioGpio2 = 5, /**< Peripheral Output 2 */
  kTopChipPinmuxOutselGpioGpio3 = 6, /**< Peripheral Output 3 */
  kTopChipPinmuxOutselGpioGpio4 = 7, /**< Peripheral Output 4 */
  kTopChipPinmuxOutselGpioGpio5 = 8, /**< Peripheral Output 5 */
  kTopChipPinmuxOutselGpioGpio6 = 9, /**< Peripheral Output 6 */
  kTopChipPinmuxOutselGpioGpio7 = 10, /**< Peripheral Output 7 */
  kTopChipPinmuxOutselGpioGpio8 = 11, /**< Peripheral Output 8 */
  kTopChipPinmuxOutselGpioGpio9 = 12, /**< Peripheral Output 9 */
  kTopChipPinmuxOutselGpioGpio10 = 13, /**< Peripheral Output 10 */
  kTopChipPinmuxOutselGpioGpio11 = 14, /**< Peripheral Output 11 */
  kTopChipPinmuxOutselGpioGpio12 = 15, /**< Peripheral Output 12 */
  kTopChipPinmuxOutselGpioGpio13 = 16, /**< Peripheral Output 13 */
  kTopChipPinmuxOutselGpioGpio14 = 17, /**< Peripheral Output 14 */
  kTopChipPinmuxOutselGpioGpio15 = 18, /**< Peripheral Output 15 */
  kTopChipPinmuxOutselGpioGpio16 = 19, /**< Peripheral Output 16 */
  kTopChipPinmuxOutselGpioGpio17 = 20, /**< Peripheral Output 17 */
  kTopChipPinmuxOutselGpioGpio18 = 21, /**< Peripheral Output 18 */
  kTopChipPinmuxOutselGpioGpio19 = 22, /**< Peripheral Output 19 */
  kTopChipPinmuxOutselGpioGpio20 = 23, /**< Peripheral Output 20 */
  kTopChipPinmuxOutselGpioGpio21 = 24, /**< Peripheral Output 21 */
  kTopChipPinmuxOutselGpioGpio22 = 25, /**< Peripheral Output 22 */
  kTopChipPinmuxOutselGpioGpio23 = 26, /**< Peripheral Output 23 */
  kTopChipPinmuxOutselGpioGpio24 = 27, /**< Peripheral Output 24 */
  kTopChipPinmuxOutselGpioGpio25 = 28, /**< Peripheral Output 25 */
  kTopChipPinmuxOutselGpioGpio26 = 29, /**< Peripheral Output 26 */
  kTopChipPinmuxOutselGpioGpio27 = 30, /**< Peripheral Output 27 */
  kTopChipPinmuxOutselGpioGpio28 = 31, /**< Peripheral Output 28 */
  kTopChipPinmuxOutselGpioGpio29 = 32, /**< Peripheral Output 29 */
  kTopChipPinmuxOutselGpioGpio30 = 33, /**< Peripheral Output 30 */
  kTopChipPinmuxOutselGpioGpio31 = 34, /**< Peripheral Output 31 */
  kTopChipPinmuxOutselI2c0Sda = 35, /**< Peripheral Output 32 */
  kTopChipPinmuxOutselI2c0Scl = 36, /**< Peripheral Output 33 */
  kTopChipPinmuxOutselI2c1Sda = 37, /**< Peripheral Output 34 */
  kTopChipPinmuxOutselI2c1Scl = 38, /**< Peripheral Output 35 */
  kTopChipPinmuxOutselI2c2Sda = 39, /**< Peripheral Output 36 */
  kTopChipPinmuxOutselI2c2Scl = 40, /**< Peripheral Output 37 */
  kTopChipPinmuxOutselSpiHost1Sd0 = 41, /**< Peripheral Output 38 */
  kTopChipPinmuxOutselSpiHost1Sd1 = 42, /**< Peripheral Output 39 */
  kTopChipPinmuxOutselSpiHost1Sd2 = 43, /**< Peripheral Output 40 */
  kTopChipPinmuxOutselSpiHost1Sd3 = 44, /**< Peripheral Output 41 */
  kTopChipPinmuxOutselUart0Tx = 45, /**< Peripheral Output 42 */
  kTopChipPinmuxOutselUart1Tx = 46, /**< Peripheral Output 43 */
  kTopChipPinmuxOutselUart2Tx = 47, /**< Peripheral Output 44 */
  kTopChipPinmuxOutselUart3Tx = 48, /**< Peripheral Output 45 */
  kTopChipPinmuxOutselPattgenPda0Tx = 49, /**< Peripheral Output 46 */
  kTopChipPinmuxOutselPattgenPcl0Tx = 50, /**< Peripheral Output 47 */
  kTopChipPinmuxOutselPattgenPda1Tx = 51, /**< Peripheral Output 48 */
  kTopChipPinmuxOutselPattgenPcl1Tx = 52, /**< Peripheral Output 49 */
  kTopChipPinmuxOutselSpiHost1Sck = 53, /**< Peripheral Output 50 */
  kTopChipPinmuxOutselSpiHost1Csb = 54, /**< Peripheral Output 51 */
  kTopChipPinmuxOutselFlashCtrlTdo = 55, /**< Peripheral Output 52 */
  kTopChipPinmuxOutselSensorCtrlAonAstDebugOut0 = 56, /**< Peripheral Output 53 */
  kTopChipPinmuxOutselSensorCtrlAonAstDebugOut1 = 57, /**< Peripheral Output 54 */
  kTopChipPinmuxOutselSensorCtrlAonAstDebugOut2 = 58, /**< Peripheral Output 55 */
  kTopChipPinmuxOutselSensorCtrlAonAstDebugOut3 = 59, /**< Peripheral Output 56 */
  kTopChipPinmuxOutselSensorCtrlAonAstDebugOut4 = 60, /**< Peripheral Output 57 */
  kTopChipPinmuxOutselSensorCtrlAonAstDebugOut5 = 61, /**< Peripheral Output 58 */
  kTopChipPinmuxOutselSensorCtrlAonAstDebugOut6 = 62, /**< Peripheral Output 59 */
  kTopChipPinmuxOutselSensorCtrlAonAstDebugOut7 = 63, /**< Peripheral Output 60 */
  kTopChipPinmuxOutselSensorCtrlAonAstDebugOut8 = 64, /**< Peripheral Output 61 */
  kTopChipPinmuxOutselPwmAonPwm0 = 65, /**< Peripheral Output 62 */
  kTopChipPinmuxOutselPwmAonPwm1 = 66, /**< Peripheral Output 63 */
  kTopChipPinmuxOutselPwmAonPwm2 = 67, /**< Peripheral Output 64 */
  kTopChipPinmuxOutselPwmAonPwm3 = 68, /**< Peripheral Output 65 */
  kTopChipPinmuxOutselPwmAonPwm4 = 69, /**< Peripheral Output 66 */
  kTopChipPinmuxOutselPwmAonPwm5 = 70, /**< Peripheral Output 67 */
  kTopChipPinmuxOutselOtpCtrlTest0 = 71, /**< Peripheral Output 68 */
  kTopChipPinmuxOutselSysrstCtrlAonBatDisable = 72, /**< Peripheral Output 69 */
  kTopChipPinmuxOutselSysrstCtrlAonKey0Out = 73, /**< Peripheral Output 70 */
  kTopChipPinmuxOutselSysrstCtrlAonKey1Out = 74, /**< Peripheral Output 71 */
  kTopChipPinmuxOutselSysrstCtrlAonKey2Out = 75, /**< Peripheral Output 72 */
  kTopChipPinmuxOutselSysrstCtrlAonPwrbOut = 76, /**< Peripheral Output 73 */
  kTopChipPinmuxOutselSysrstCtrlAonZ3Wakeup = 77, /**< Peripheral Output 74 */
  kTopChipPinmuxOutselLast = 77, /**< \internal Last valid outsel value */
} top_chip_pinmux_outsel_t;

/**
 * Dedicated Pad Selects
 */
typedef enum top_chip_direct_pads {
  kTopChipDirectPadsUsbdevUsbDp = 0, /**<  */
  kTopChipDirectPadsUsbdevUsbDn = 1, /**<  */
  kTopChipDirectPadsSpiHost0Sd0 = 2, /**<  */
  kTopChipDirectPadsSpiHost0Sd1 = 3, /**<  */
  kTopChipDirectPadsSpiHost0Sd2 = 4, /**<  */
  kTopChipDirectPadsSpiHost0Sd3 = 5, /**<  */
  kTopChipDirectPadsSpiDeviceSd0 = 6, /**<  */
  kTopChipDirectPadsSpiDeviceSd1 = 7, /**<  */
  kTopChipDirectPadsSpiDeviceSd2 = 8, /**<  */
  kTopChipDirectPadsSpiDeviceSd3 = 9, /**<  */
  kTopChipDirectPadsSysrstCtrlAonEcRstL = 10, /**<  */
  kTopChipDirectPadsSysrstCtrlAonFlashWpL = 11, /**<  */
  kTopChipDirectPadsSpiDeviceSck = 12, /**<  */
  kTopChipDirectPadsSpiDeviceCsb = 13, /**<  */
  kTopChipDirectPadsSpiHost0Sck = 14, /**<  */
  kTopChipDirectPadsSpiHost0Csb = 15, /**<  */
  kTopChipDirectPadsLast = 15, /**< \internal Last valid direct pad */
} top_chip_direct_pads_t;

/**
 * Muxed Pad Selects
 */
typedef enum top_chip_muxed_pads {
  kTopChipMuxedPadsIoa0 = 0, /**<  */
  kTopChipMuxedPadsIoa1 = 1, /**<  */
  kTopChipMuxedPadsIoa2 = 2, /**<  */
  kTopChipMuxedPadsIoa3 = 3, /**<  */
  kTopChipMuxedPadsIoa4 = 4, /**<  */
  kTopChipMuxedPadsIoa5 = 5, /**<  */
  kTopChipMuxedPadsIoa6 = 6, /**<  */
  kTopChipMuxedPadsIoa7 = 7, /**<  */
  kTopChipMuxedPadsIoa8 = 8, /**<  */
  kTopChipMuxedPadsIob0 = 9, /**<  */
  kTopChipMuxedPadsIob1 = 10, /**<  */
  kTopChipMuxedPadsIob2 = 11, /**<  */
  kTopChipMuxedPadsIob3 = 12, /**<  */
  kTopChipMuxedPadsIob4 = 13, /**<  */
  kTopChipMuxedPadsIob5 = 14, /**<  */
  kTopChipMuxedPadsIob6 = 15, /**<  */
  kTopChipMuxedPadsIob7 = 16, /**<  */
  kTopChipMuxedPadsIob8 = 17, /**<  */
  kTopChipMuxedPadsIob9 = 18, /**<  */
  kTopChipMuxedPadsIob10 = 19, /**<  */
  kTopChipMuxedPadsIob11 = 20, /**<  */
  kTopChipMuxedPadsIob12 = 21, /**<  */
  kTopChipMuxedPadsIoc0 = 22, /**<  */
  kTopChipMuxedPadsIoc1 = 23, /**<  */
  kTopChipMuxedPadsIoc2 = 24, /**<  */
  kTopChipMuxedPadsIoc3 = 25, /**<  */
  kTopChipMuxedPadsIoc4 = 26, /**<  */
  kTopChipMuxedPadsIoc5 = 27, /**<  */
  kTopChipMuxedPadsIoc6 = 28, /**<  */
  kTopChipMuxedPadsIoc7 = 29, /**<  */
  kTopChipMuxedPadsIoc8 = 30, /**<  */
  kTopChipMuxedPadsIoc9 = 31, /**<  */
  kTopChipMuxedPadsIoc10 = 32, /**<  */
  kTopChipMuxedPadsIoc11 = 33, /**<  */
  kTopChipMuxedPadsIoc12 = 34, /**<  */
  kTopChipMuxedPadsIor0 = 35, /**<  */
  kTopChipMuxedPadsIor1 = 36, /**<  */
  kTopChipMuxedPadsIor2 = 37, /**<  */
  kTopChipMuxedPadsIor3 = 38, /**<  */
  kTopChipMuxedPadsIor4 = 39, /**<  */
  kTopChipMuxedPadsIor5 = 40, /**<  */
  kTopChipMuxedPadsIor6 = 41, /**<  */
  kTopChipMuxedPadsIor7 = 42, /**<  */
  kTopChipMuxedPadsIor10 = 43, /**<  */
  kTopChipMuxedPadsIor11 = 44, /**<  */
  kTopChipMuxedPadsIor12 = 45, /**<  */
  kTopChipMuxedPadsIor13 = 46, /**<  */
  kTopChipMuxedPadsLast = 46, /**< \internal Last valid muxed pad */
} top_chip_muxed_pads_t;

/**
 * Power Manager Wakeup Signals
 */
typedef enum top_chip_power_manager_wake_ups {
  kTopChipPowerManagerWakeUpsSysrstCtrlAonWkupReq = 0, /**<  */
  kTopChipPowerManagerWakeUpsAdcCtrlAonWkupReq = 1, /**<  */
  kTopChipPowerManagerWakeUpsPinmuxAonPinWkupReq = 2, /**<  */
  kTopChipPowerManagerWakeUpsPinmuxAonUsbWkupReq = 3, /**<  */
  kTopChipPowerManagerWakeUpsAonTimerAonWkupReq = 4, /**<  */
  kTopChipPowerManagerWakeUpsSensorCtrlAonWkupReq = 5, /**<  */
  kTopChipPowerManagerWakeUpsLast = 5, /**< \internal Last valid pwrmgr wakeup signal */
} top_chip_power_manager_wake_ups_t;

/**
 * Reset Manager Software Controlled Resets
 */
typedef enum top_chip_reset_manager_sw_resets {
  kTopChipResetManagerSwResetsSpiDevice = 0, /**<  */
  kTopChipResetManagerSwResetsSpiHost0 = 1, /**<  */
  kTopChipResetManagerSwResetsSpiHost1 = 2, /**<  */
  kTopChipResetManagerSwResetsUsb = 3, /**<  */
  kTopChipResetManagerSwResetsUsbAon = 4, /**<  */
  kTopChipResetManagerSwResetsI2c0 = 5, /**<  */
  kTopChipResetManagerSwResetsI2c1 = 6, /**<  */
  kTopChipResetManagerSwResetsI2c2 = 7, /**<  */
  kTopChipResetManagerSwResetsLast = 7, /**< \internal Last valid rstmgr software reset request */
} top_chip_reset_manager_sw_resets_t;

/**
 * Power Manager Reset Request Signals
 */
typedef enum top_chip_power_manager_reset_requests {
  kTopChipPowerManagerResetRequestsSysrstCtrlAonRstReq = 0, /**<  */
  kTopChipPowerManagerResetRequestsAonTimerAonAonTimerRstReq = 1, /**<  */
  kTopChipPowerManagerResetRequestsLast = 1, /**< \internal Last valid pwrmgr reset_request signal */
} top_chip_power_manager_reset_requests_t;

/**
 * Clock Manager Software-Controlled ("Gated") Clocks.
 *
 * The Software has full control over these clocks.
 */
typedef enum top_chip_gateable_clocks {
  kTopChipGateableClocksIoDiv4Peri = 0, /**< Clock clk_io_div4_peri in group peri */
  kTopChipGateableClocksIoDiv2Peri = 1, /**< Clock clk_io_div2_peri in group peri */
  kTopChipGateableClocksIoPeri = 2, /**< Clock clk_io_peri in group peri */
  kTopChipGateableClocksUsbPeri = 3, /**< Clock clk_usb_peri in group peri */
  kTopChipGateableClocksLast = 3, /**< \internal Last Valid Gateable Clock */
} top_chip_gateable_clocks_t;

/**
 * Clock Manager Software-Hinted Clocks.
 *
 * The Software has partial control over these clocks. It can ask them to stop,
 * but the clock manager is in control of whether the clock actually is stopped.
 */
typedef enum top_chip_hintable_clocks {
  kTopChipHintableClocksMainAes = 0, /**< Clock clk_main_aes in group trans */
  kTopChipHintableClocksMainHmac = 1, /**< Clock clk_main_hmac in group trans */
  kTopChipHintableClocksMainKmac = 2, /**< Clock clk_main_kmac in group trans */
  kTopChipHintableClocksMainOtbn = 3, /**< Clock clk_main_otbn in group trans */
  kTopChipHintableClocksLast = 3, /**< \internal Last Valid Hintable Clock */
} top_chip_hintable_clocks_t;

/**
 * MMIO Region
 *
 * MMIO region excludes any memory that is separate from the module
 * configuration space, i.e. ROM, main SRAM, and flash are excluded but
 * retention SRAM, spi_device memory, or usbdev memory are included.
 */
#define TOP_CHIP_MMIO_BASE_ADDR 0x40000000u
#define TOP_CHIP_MMIO_SIZE_BYTES 0x10000000u

// Header Extern Guard
#ifdef __cplusplus
}  // extern "C"
#endif

#endif  // OPENTITAN_HW_TOP_CHIP_SW_AUTOGEN_TOP_CHIP_H_
