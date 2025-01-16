// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

  .section .vectors, "ax"
  .p2align 4
  .weak _trap_vector
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

// TODO: Ensure that we at least report the exception on the UART output.
__trap_vector: j __trap_vector
