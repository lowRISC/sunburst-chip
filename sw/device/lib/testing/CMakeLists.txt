# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set(TESTUTILS
  aon_timer_testutils.c
  i2c_testutils.c
  rand_testutils.c
  rv_core_ibex_testutils.c
  rv_plic_testutils.c
  pinmux_testutils.c
  spi_flash_testutils.c
  spi_host_testutils.c
  uart_testutils.c
  # Treat these as separate for now, but really should be a single library.
  usb_testutils.c
  usb_testutils_controlep.c
  usb_testutils_simpleserial.c
  usb_testutils_streams.c
)

foreach(UTILS ${TESTUTILS})
  get_filename_component(NAME ${UTILS} NAME_WE)
  add_library(${NAME} OBJECT ${UTILS})
  target_include_directories(${NAME} PRIVATE ${SUNBURST_SW_TEST_INCLUDES})
  install(TARGETS ${NAME})
endforeach()

add_subdirectory(autogen)
add_subdirectory(json)
add_subdirectory(test_framework)
