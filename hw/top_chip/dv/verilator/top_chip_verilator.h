// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "verilated_toplevel.h"
#include "verilator_memutil.h"

class TopChipVerilator {
 public:
  TopChipVerilator(const char* rom_hier_path, int rom_size_words,
      const char *ram_hier_path, int ram_size_words);
  virtual ~TopChipVerilator() {}
  virtual int Main(int argc, char **argv);


 protected:
  top_chip_verilator _top;
  VerilatorMemUtil _memutil;
  MemArea _ram;
  MemArea _rom;

  virtual int Setup(int argc, char **argv, bool &exit_app);
  virtual void Run();
  virtual bool Finish();
};
