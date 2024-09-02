// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class top_chip_dv_env extends uvm_env;
  `uvm_component_utils(top_chip_dv_env)
  `uvm_component_new

  top_chip_dv_env_cfg cfg;

  mem_bkdr_util mem_bkdr_util_h[chip_mem_e];

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    for (chip_mem_e mem = mem.first(), int i = 0; i < mem.num(); mem = mem.next(), i++) begin
      string inst = $sformatf("mem_bkdr_util[%0s]", mem.name());

      if (!uvm_config_db#(mem_bkdr_util)::get(this, "", inst, mem_bkdr_util_h[mem])) begin
        `uvm_fatal(`gfn, {"failed to get ", inst, " from uvm_config_db"})
      end
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    load_memories();
  endtask

  task load_memories();
    foreach (cfg.mem_image_files[m]) begin
      if (cfg.mem_image_files[m] != "") begin
        `uvm_info(`gfn, $sformatf("Initializing memory %s with image %s", m.name(),
          cfg.mem_image_files[m]), UVM_LOW)

        mem_bkdr_util_h[m].load_mem_from_file(cfg.mem_image_files[m]);
      end
    end
  endtask
endclass
