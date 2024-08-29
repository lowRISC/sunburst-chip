// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <cassert>
#include <fstream>
#include <iostream>

#include "top_chip_verilator.h"
#include "verilated_toplevel.h"
#include "verilator_memutil.h"
#include "verilator_sim_ctrl.h"

TopChipVerilator::TopChipVerilator(const char* rom_hier_path, int rom_size_words,
    const char *ram_hier_path, int ram_size_words)
    : _rom(rom_hier_path, rom_size_words, 4),
      _ram(ram_hier_path, ram_size_words, 4) {}

int TopChipVerilator::Main(int argc, char **argv) {
  bool exit_app;
  int ret_code = Setup(argc, argv, exit_app);

  if (exit_app) {
    return ret_code;
  }

  Run();

  if (!Finish()) {
    return 1;
  }

  return 0;
}

int TopChipVerilator::Setup(int argc, char **argv, bool &exit_app) {
  VerilatorSimCtrl &simctrl = VerilatorSimCtrl::GetInstance();

  simctrl.SetTop(&_top, &_top.clk_i, &_top.rst_ni,
                 VerilatorSimCtrlFlags::ResetPolarityNegative);

  _memutil.RegisterMemoryArea("rom", 0x100000, &_rom);
  _memutil.RegisterMemoryArea("ram", 0x200000, &_ram);
  simctrl.RegisterExtension(&_memutil);

  exit_app = false;
  return simctrl.ParseCommandArgs(argc, argv, exit_app);
}

void TopChipVerilator::Run() {
  VerilatorSimCtrl &simctrl = VerilatorSimCtrl::GetInstance();

  std::cout << "Simulation of Sunburst Chip" << std::endl
            << "===========================" << std::endl
            << std::endl;

  simctrl.RunSimulation();
}

bool TopChipVerilator::Finish() {
  VerilatorSimCtrl &simctrl = VerilatorSimCtrl::GetInstance();

  if (!simctrl.WasSimulationSuccessful()) {
    return false;
  }

  return true;
}
