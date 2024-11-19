# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set(NAME common)
add_library(${NAME} OBJECT boot.S boot.cc default-handlers.cc)
target_include_directories(${NAME} PRIVATE ${CHERIOT_SDK_INCLUDES})
