# Copyright lowRISC contributors (Sunburst project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set(NAME ottf)
add_library(${NAME} OBJECT coverage_none.c ottf_console.c ottf_isrs.c ottf_cheriot_isrs.S ottf_main.c status.c ujson_ottf.c ujson_ottf_commands.c)
target_include_directories(${NAME} PRIVATE ${SUNBURST_SW_TEST_INCLUDES})
