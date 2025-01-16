# Copyright lowRISC contributors (Sunburst project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set(NAME ujson)
add_compile_definitions(OT_PLATFORM_RV32)
add_library(${NAME} OBJECT private_status.c ujson.c)
target_include_directories(${NAME} PRIVATE ${SUNBURST_SW_TEST_INCLUDES})
