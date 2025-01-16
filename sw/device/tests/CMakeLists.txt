# Copyright lowRISC contributors (Sunburst project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
set(TESTS
  aon_timer_irq_test.c
  aon_timer_smoketest.c
  gpio_intr_test.c
  gpio_pinmux_test.c
  gpio_smoketest.c
  i2c_host_override_test.c
  i2c_target_smbus_arp_test.c
  pattgen_ios_test.c
  plic_sw_irq_test.c
  pwm_smoketest.c
  rv_plic_smoketest.c
  rv_timer_smoketest.c
  rv_timer_systick_test.c
  spi_host_config_test.c
  spi_host_irq_test.c
  spi_host_smoketest.c
  spi_host_winbond_flash_test.c
  uart_baud_rate_test.c
  uart_loopback_test.c
  uart_parity_break_test.c
  uart_smoketest.c
# Needs (dif_)clkmgr:
#  uart_tx_rx_test.c
  usbdev_config_host_test.c
  usbdev_iso_test.c
  usbdev_mem_test.c
  usbdev_mixed_test.c
# Needs (dif_)rstmgr:
#  usbdev_pincfg_test.c
  usbdev_pullup_test.c
  usbdev_setuprx_test.c
  usbdev_stream_test.c
  usbdev_test.c
  usbdev_toggle_restore_test.c
  usbdev_vbus_test.c

  # DV-only tests.
  sim_dv/gpio_test.c
  sim_dv/i2c_device_tx_rx_test.c
  sim_dv/i2c_host_tx_rx_test.c
  sim_dv/spi_host_tx_rx_test.c
)

add_library(spi_host_flash_test_impl OBJECT spi_host_flash_test_impl.c)
target_include_directories(spi_host_flash_test_impl PRIVATE ${SUNBURST_SW_TEST_INCLUDES})

foreach(TEST ${TESTS})
  get_filename_component(NAME ${TEST} NAME_WE)

  add_executable(${NAME} ${TEST})
  target_include_directories(${NAME} PRIVATE ${SUNBURST_SW_TEST_INCLUDES})

  # Top-level
  target_link_libraries(${NAME} top_chip)
  # Arch
  target_link_libraries(${NAME} arch)
  # Boot code
  target_link_libraries(${NAME} boot)
  # Base
  target_link_libraries(${NAME} base)
  # Runtime
  target_link_libraries(${NAME} runtime)
  # Ujson support
  target_link_libraries(${NAME} ujson)
  # DIF autogen code
  target_link_libraries(${NAME} dif_aon_timer_autogen)
  target_link_libraries(${NAME} dif_gpio_autogen)
  target_link_libraries(${NAME} dif_i2c_autogen)
  target_link_libraries(${NAME} dif_pattgen_autogen)
  target_link_libraries(${NAME} dif_pinmux_autogen)
  target_link_libraries(${NAME} dif_pwm_autogen)
  target_link_libraries(${NAME} dif_rv_core_ibex_autogen)
  target_link_libraries(${NAME} dif_rv_plic_autogen)
  target_link_libraries(${NAME} dif_rv_timer_autogen)
  target_link_libraries(${NAME} dif_spi_host_autogen)
  target_link_libraries(${NAME} dif_uart_autogen)
  target_link_libraries(${NAME} dif_usbdev_autogen)
  # DIFs
  target_link_libraries(${NAME} dif_aon_timer)
  target_link_libraries(${NAME} dif_base)
  target_link_libraries(${NAME} dif_gpio)
  target_link_libraries(${NAME} dif_i2c)
  target_link_libraries(${NAME} dif_pattgen)
  target_link_libraries(${NAME} dif_pinmux)
  target_link_libraries(${NAME} dif_pwm)
  target_link_libraries(${NAME} dif_rv_core_ibex)
  target_link_libraries(${NAME} dif_rv_plic)
  target_link_libraries(${NAME} dif_rv_timer)
  target_link_libraries(${NAME} dif_spi_host)
  target_link_libraries(${NAME} dif_uart)
  target_link_libraries(${NAME} dif_usbdev)
  # Test framework
  target_link_libraries(${NAME} ottf)
  # Json support
  target_link_libraries(${NAME} json)
  # Testutils
  target_link_libraries(${NAME} aon_timer_testutils)
  target_link_libraries(${NAME} i2c_testutils)
  target_link_libraries(${NAME} isr_testutils)
  target_link_libraries(${NAME} pinmux_testutils)
  target_link_libraries(${NAME} rand_testutils)
  target_link_libraries(${NAME} rv_core_ibex_testutils)
  target_link_libraries(${NAME} rv_plic_testutils)
  target_link_libraries(${NAME} spi_flash_testutils)
  target_link_libraries(${NAME} spi_host_testutils)
  target_link_libraries(${NAME} uart_testutils)
  target_link_libraries(${NAME} usb_testutils)
  target_link_libraries(${NAME} usb_testutils_controlep)
  target_link_libraries(${NAME} usb_testutils_simpleserial)
  target_link_libraries(${NAME} usb_testutils_streams)
  # SPI host flash test
  target_link_libraries(${NAME} spi_host_flash_test_impl)

  add_custom_command(
    TARGET ${NAME} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary "$<TARGET_FILE:${NAME}>" "$<TARGET_FILE:${NAME}>.bin"
    COMMAND srec_cat "$<TARGET_FILE:${NAME}>.bin" -binary -offset 0x0000 -byte-swap 4 -o "$<TARGET_FILE:${NAME}>.vmem" -vmem
    VERBATIM
  )

  install(TARGETS ${NAME})
endforeach()
