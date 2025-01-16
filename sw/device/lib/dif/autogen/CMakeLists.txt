# Copyright lowRISC contributors (Sunburst project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set(DIFS
  dif_aon_timer_autogen.c
  dif_gpio_autogen.c
  dif_i2c_autogen.c
  dif_pattgen_autogen.c
  dif_pinmux_autogen.c
  dif_pwm_autogen.c
  dif_rv_core_ibex_autogen.c
  dif_rv_plic_autogen.c
  dif_rv_timer_autogen.c
  dif_spi_host_autogen.c
  dif_uart_autogen.c
  dif_usbdev_autogen.c
)

foreach(DIF ${DIFS})
  get_filename_component(NAME ${DIF} NAME_WE)
  add_library(${NAME} OBJECT ${DIF})
  target_include_directories(${NAME} PRIVATE ${SUNBURST_SW_TEST_INCLUDES})
  install(TARGETS ${NAME})
endforeach()
