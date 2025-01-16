# Copyright lowRISC contributors (Sunburst project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set(NAME arch)
add_library(${NAME} OBJECT device_sim_dv.c)
target_include_directories(${NAME} PRIVATE ${SUNBURST_SW_TEST_INCLUDES})
