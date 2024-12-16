// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class top_chip_dv_env_cfg extends uvm_object;
  string mem_image_files[chip_mem_e];
  longint unsigned sys_timeout_cycles = 20_000_000;

  pattgen_agent_cfg m_pattgen_agent_cfg;

  `uvm_object_utils_begin(top_chip_dv_env_cfg)
  `uvm_object_utils_end

  function new (string name="");
    super.new(name);
  endfunction

  virtual function void initialize();
    get_mem_image_files_from_plusargs();

    // create pattgen agent config obj
    m_pattgen_agent_cfg = pattgen_agent_cfg::type_id::create("m_pattgen_agent_cfg");
    m_pattgen_agent_cfg.if_mode = Device;
  endfunction

  function void get_mem_image_files_from_plusargs();
    for (chip_mem_e mem = mem.first(), int i = 0; i < mem.num(); mem = mem.next(), i++) begin
      string image_file;
      string plusarg;

      plusarg = $sformatf("%s_image_file=%%s", mem.name());

      `uvm_info(`gfn, $sformatf("Looking for image for memory %s with plus arg %s", mem.name(), plusarg), UVM_LOW);

      if ($value$plusargs(plusarg, image_file)) begin
        mem_image_files[mem] = image_file;
        `uvm_info(`gfn, $sformatf("Got image file %s for memory %s",
          image_file, mem.name()), UVM_MEDIUM)
      end
    end
  endfunction
endclass
