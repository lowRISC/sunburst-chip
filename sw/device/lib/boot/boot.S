// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/// Load the absolute address of a symbol.

.macro la_abs reg, symbol
    lui             \reg, %hi(\symbol)
    addi            \reg, \reg, %lo(\symbol)
.endm

  .section .text.start, "ax", @progbits

  .global start
  .p2align 2
  .type start,@function
start:
  // Enable the ICache; not present in sunburst-chip currently.
  // csrsi            0x7c0, 1

  // Upon reset mtdc contains the read-write root and pcc contains the execution root.
  cspecialr        cs0, mtdc
  auipcc           cs1, 0

  // Clear the revocation bitmap before entering C/C++ code.
  // The bitmap is not cleared upon reset so memset to return it to a
  // pristine state; also prevent Xs in sim.
  //
  // 8KiB with one bit covering each 64 bits (8 bytes) corresponding to 512KiB SRAM.
  li               a1, 0x00300000
  csetaddr         ca1, cs0, a1
  li               a2, 0x2000  // 8KiB.
0:
  csw              zero, 0(ca1)
  cincoffset       ca1, ca1, 4
  addi             a2, a2, -4
  bnez             a2, 0b

  //Set interrupt/exception handlers.
  la_abs           t0, _trap_vector
  csetaddr         ct0, cs1, t0
  cspecialw        mtcc, ct0

  // Set cgp to correct location so globals can be used.
  .extern __global_pointer$
  la_abs           t0, __global_pointer$
  csetaddr         cgp, cs0, t0

  // No bounds on stack, grows down from the end of SRAM
  li               sp, 0x00280000
  csetaddr         csp, cs0, sp

  // Zero 2k of stack (prevents Xs in sim)
  csetaddr         ct0, cs0, sp
  li               t1, 0x200
stack_clear_loop:
  cincoffset       ct0, ct0, -4
  csw              zero, 0(ct0)
  add              t1, t1, -1
  bne              t1, zero, stack_clear_loop

  // Initialise capabiltiies within global static data.
  cmove           ca0, cs0
  lui             a1,%hi(__start___cap_relocs)
  addi            a1,a1,%lo(__start___cap_relocs)
  lui             a2,%hi(__stop___cap_relocs)
  addi            a2,a2,%lo(__stop___cap_relocs)
  cjal            boot_init_globals

  // ca0 (first argument) contains the read-write root
  cmove            ca0, cs0
  // Call the C++ entry point
  ccall            _ottf_main

  // Infinite loop if the entry point ever returns
1:
  wfi
  j 1b
