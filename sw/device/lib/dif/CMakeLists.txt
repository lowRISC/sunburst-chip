# Copyright lowRISC contributors (Sunburst project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set(DIFS
  dif_aon_timer.c
  dif_base.c
  dif_gpio.c
  dif_i2c.c
  dif_pattgen.c
  dif_pinmux.c
  dif_pwm.c
  dif_rv_core_ibex.c
  dif_rv_plic.c
  dif_rv_timer.c
  dif_spi_host.c
  dif_uart.c
  dif_usbdev.c
)

foreach(DIF ${DIFS})
  get_filename_component(NAME ${DIF} NAME_WE)
  add_library(${NAME} OBJECT ${DIF})
  target_include_directories(${NAME} PRIVATE ${SUNBURST_SW_TEST_INCLUDES})
  install(TARGETS ${NAME})
endforeach()

add_subdirectory(autogen)
