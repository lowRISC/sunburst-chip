// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "top_chip_verilator.h"

int main(int argc, char **argv) {
  TopChipVerilator top_chip_verilator(
      "TOP.top_chip_verilator.u_top_chip_system.u_rom.u_rom.gen_generic.u_impl_generic",
      1024, // 1k words = 4kiB
      "TOP.top_chip_verilator.u_top_chip_system.u_sram.u_ram.gen_generic.u_impl_generic",
      128 * 1024 // 128k words = 512 kiB
  );

  return top_chip_verilator.Main(argc, argv);
}
