# Copyright lowRISC contributors (Sunburst project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set(NAME json)
add_library(${NAME} OBJECT command.c gpio.c i2c_target.c mem.c ottf.c pinmux.c pinmux_config.c)
target_include_directories(${NAME} PRIVATE ${SUNBURST_SW_TEST_INCLUDES})
