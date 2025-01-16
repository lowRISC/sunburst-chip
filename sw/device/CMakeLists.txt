# Copyright lowRISC contributors (Sunburst project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 3.13)
include(FetchContent)

if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/cheriot_toolchain.cmake")
endif()

project(sunburst_system_tl_sw LANGUAGES C CXX ASM)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(SUNBURST_SW_TEST_INCLUDES
    "../.."
    "../../.."
    "../../../.."
    "../../../../.."
    "../../../sw/device/regs"
    "../../../../sw/device/regs"
    "../../../../../sw/device/regs"
    "../../../sw/device/lib/base/freestanding"
    "../../../../sw/device/lib/base/freestanding"
    "../../../../../sw/device/lib/base/freestanding"
)

add_library(top_chip OBJECT ../../hw/top_chip/sw/autogen/top_chip.c)
target_include_directories(top_chip PRIVATE ${SUNBURST_SW_TEST_INCLUDES})

add_subdirectory(lib)
add_subdirectory(tests)
