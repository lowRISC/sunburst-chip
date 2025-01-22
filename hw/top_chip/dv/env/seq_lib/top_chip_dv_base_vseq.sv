// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class top_chip_dv_base_vseq extends uvm_sequence;
  `uvm_object_utils(top_chip_dv_base_vseq)
  `uvm_declare_p_sequencer(top_chip_dv_virtual_sequencer)

  `uvm_object_new

  task body();
    // Empty body for base virtual sequence, required to avoid UVM warning
  endtask

  task post_start();
    super.post_start();

    wait_for_sw_test_done();
  endtask

  virtual task wait_for_sw_test_done();
    `uvm_info(`gfn, "Waiting for software to signal test end", UVM_LOW);
    fork
      begin: isolation_thread
        fork
          begin
            // Nice case - test status interface completion signal
            wait(p_sequencer.cfg.sw_test_status_vif.sw_test_done);
            // Pass/Fail message output by sw_test_status_vif
          end
          begin
            // Legacy case - GPIO completion signal
            wait(p_sequencer.ifs.gpio_pins_vif.pins == 32'hDEADBEEF);
            `uvm_info(`gfn, "TEST PASSED! Completion signal seen from software", UVM_LOW);
          end
        join_any
        disable fork;
      end: isolation_thread
    join

  endtask

  // Backdoor-read or override a const symbol in SW to modify the behavior of the test.
  //
  // In the extended test vseq, add this function call to the start of body().
  virtual function void sw_symbol_backdoor_access(input string symbol,
                                                  inout bit [7:0] data[],
                                                  input chip_mem_e mem = ChipMemSRAM,
                                                  input bit does_not_exist_ok = 0,
                                                  input bit is_write = 0);

    bit [bus_params_pkg::BUS_AW-1:0] addr, mem_addr;
    uint size;
    uint addr_mask;
    string sw_dir;
    string sw_basename;
    string image;
    bit ret;

    `DV_CHECK_FATAL(mem inside {ChipMemSRAM, ChipMemROM},
        $sformatf("SW symbol %0s is not expected to appear in %0s mem", symbol, mem))

    // Elf file name checks.
    `DV_CHECK_FATAL(p_sequencer.cfg.mem_image_files.exists(mem))
    `DV_CHECK_STRNE_FATAL(p_sequencer.cfg.mem_image_files[mem], "")

    // Find the symbol in the sw elf file.
    sw_dir = str_utils_pkg::str_path_dirname(.filename(p_sequencer.cfg.mem_image_files[mem]));
    sw_basename = str_utils_pkg::str_path_basename(.filename(p_sequencer.cfg.mem_image_files[mem]), .drop_extn(1'b1));
    image = {sw_dir, "/", sw_basename};
    ret = dv_utils_pkg::sw_symbol_get_addr_size(image, symbol, does_not_exist_ok, addr, size);
    if (!ret) begin
      string msg = $sformatf("Failed to find symbol %0s in %0s", symbol, image);
      if (does_not_exist_ok) begin
        `uvm_info(`gfn, msg, UVM_LOW)
        return;
      end else `uvm_fatal(`gfn, msg)
    end
    `DV_CHECK_EQ_FATAL(size, data.size())

    addr_mask = (2**$clog2(p_sequencer.mem_bkdr_util_h[mem].get_size_bytes()))-1;
    mem_addr = addr & addr_mask;

    if (is_write) begin
      `uvm_info(`gfn, $sformatf({"Overwriting symbol \"%s\" via backdoor in %0s: ",
                               "abs addr = 0x%0h, mem addr = 0x%0h, size = %0d, ",
                               "addr_mask = 0x%0h"},
                              symbol, mem, addr, mem_addr, size, addr_mask), UVM_LOW)
      for (int i = 0; i < size; i++) mem_bkdr_write8(mem, mem_addr + i, data[i]);

      if (mem == ChipMemROM) begin
        // TODO: Get ROM replacement working
        `dv_fatal($sformatf("SW symbol %0s is in ROM, but we cannot yet replace symbols there", symbol))
      end
    end else begin
      `uvm_info(`gfn, $sformatf({"Reading symbol \"%s\" via backdoor in %0s: ",
                             "abs addr = 0x%0h, mem addr = 0x%0h, size = %0d, ",
                             "addr_mask = 0x%0h"},
                            symbol, mem, addr, mem_addr, size, addr_mask), UVM_LOW)
      for (int i = 0; i < size; i++) mem_bkdr_read8(mem, mem_addr + i, data[i]);
    end
  endfunction

  // Backdoor-read a const symbol in SW to make decisions based on SW constants.
  //
  // Wrapper function for reads via sw_symbol_backdoor_access.
  virtual function void sw_symbol_backdoor_read(input string symbol,
                                                inout bit [7:0] data[],
                                                input chip_mem_e mem = ChipMemSRAM,
                                                input bit does_not_exist_ok = 0);

    sw_symbol_backdoor_access(symbol, data, mem, does_not_exist_ok, 0);
    `uvm_info(`gfn, $sformatf("sw_symbol_backdoor_read gets %p", data), UVM_MEDIUM)
  endfunction

  // Backdoor-override a const symbol in SW to modify the behavior of the test.
  //
  // Wrapper function for writes via sw_symbol_backdoor_access.
  virtual function void sw_symbol_backdoor_overwrite(input string symbol,
                                                     input bit [7:0] data[],
                                                     input chip_mem_e mem = ChipMemSRAM,
                                                     input bit does_not_exist_ok = 0);

    sw_symbol_backdoor_access(symbol, data, mem, does_not_exist_ok, 1);
  endfunction

  // General-use function to backdoor write a byte of data to any selected memory type
  virtual function void mem_bkdr_write8(input chip_mem_e mem,
                                        input bit [bus_params_pkg::BUS_AW-1:0] addr,
                                        input byte data);
    byte prev_data;
    if (mem == ChipMemROM) begin
      // TODO: Get ROM access working
      `dv_fatal("Backdoor ROM access not yet supported")
    end else begin // SRAM
      prev_data = p_sequencer.mem_bkdr_util_h[mem].read8(addr);
      p_sequencer.mem_bkdr_util_h[mem].write8(addr, data);
    end
    `uvm_info(`gfn, $sformatf("addr %0h = 0x%0h --> 0x%0h", addr, prev_data, data), UVM_HIGH)
  endfunction

  // General-use function to backdoor read a byte of data from any selected memory type
  virtual function void mem_bkdr_read8(input chip_mem_e mem,
                                       input bit [bus_params_pkg::BUS_AW-1:0] addr,
                                       output byte data);
    if (mem == ChipMemROM) begin
      // TODO: Get ROM access working
      `dv_fatal("Backdoor ROM access not yet supported")
    end else begin // SRAM
      data = p_sequencer.mem_bkdr_util_h[mem].read8(addr);
    end
    `uvm_info(`gfn, $sformatf("addr %0h = 0x%0h", addr, data), UVM_HIGH)
  endfunction

endclass
