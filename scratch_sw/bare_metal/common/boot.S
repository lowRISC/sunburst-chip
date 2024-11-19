.include "assembly-helpers.s"

  .section .vectors, "ax"
  .p2align 4
  .global _trap_vector
  .type _trap_vector, @function
_trap_vector:
  // Save all the register to the stack
  cincoffset csp, csp, -(8 * 15)
  csc   c1,  1 * 8(csp)
  csc   c2,  2 * 8(csp)
  csc   c3,  3 * 8(csp)
  csc   c4,  4 * 8(csp)
  csc   c5,  5 * 8(csp)
  csc   c6,  6 * 8(csp)
  csc   c7,  7 * 8(csp)
  csc   c8,  8 * 8(csp)
  csc   c9,  9 * 8(csp)
  csc   c10,  10 * 8(csp)
  csc   c11,  11 * 8(csp)
  csc   c12,  12 * 8(csp)
  csc   c13,  13 * 8(csp)
  csc   c14,  14 * 8(csp)
  csc   c15,  15 * 8(csp)

	cspecialr ca0, mtdc
  ccall __trap_vector

.L_isr_exit:
  // Restore all registers from the stack.
  clc   c1,  1 * 8(csp)
  clc   c2,  2 * 8(csp)
  clc   c3,  3 * 8(csp)
  clc   c4,  4 * 8(csp)
  clc   c5,  5 * 8(csp)
  clc   c6,  6 * 8(csp)
  clc   c7,  7 * 8(csp)
  clc   c8,  8 * 8(csp)
  clc   c9,  9 * 8(csp)
  clc   c10,  10 * 8(csp)
  clc   c11,  11 * 8(csp)
  clc   c12,  12 * 8(csp)
  clc   c13,  13 * 8(csp)
  clc   c14,  14 * 8(csp)
  clc   c15,  15 * 8(csp)
  cincoffset csp, csp, (8 * 15)
  mret
  // Set size so vector can be disassembled.
  .size _trap_vector, .-_trap_vector

  .section .text.start, "ax", @progbits

  .globl start
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

  // ca0 (first argument) contains the read-write root
	cmove            ca0, cs0
  // Call the C++ entry point
	ccall            entry_point

	// Infinite loop if the entry point ever returns
1:
	wfi
	j 1b

