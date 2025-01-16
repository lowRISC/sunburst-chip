# Copyright lowRISC contributors (Sunburst project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set(NAME base)
add_compile_definitions(OT_PLATFORM_RV32)
add_library(${NAME} OBJECT bitfield.c crc32.c math.c memory.c mmio.c status.c)
target_include_directories(${NAME} PRIVATE ${SUNBURST_SW_TEST_INCLUDES})
