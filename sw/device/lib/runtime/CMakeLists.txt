# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set(NAME runtime)
add_library(${NAME} OBJECT hart.c ibex.c irq.c log.c print.c)
target_include_directories(${NAME} PRIVATE ${SUNBURST_SW_TEST_INCLUDES})
