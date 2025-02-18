// Copyright lowRISC contributors (Sunburst project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/testing/test_framework/ottf_macros.h"

// -----------------------------------------------------------------------------

  /**
   * Compute the MEPCC that will be saved to the stack by the associated ISR
   * handler sub-routine below.
   *
   * This subroutine is only invoked for IRQs that are synchronous. Specifically,
   * this subroutine updates the ISR return address to point to the instruction
   * after the trapped instruction to prevent an endless interrupt cycle.
   *
   * Since we support the RISC-V compressed instructions extension, we need to
   * check if the two least significant bits of the instruction are
   * b11 (0x3), which means that the trapped instruction is not compressed,
   * i.e., the trapped instruction is 32bits = 4bytes. Otherwise, the trapped
   * instruction is 16bits = 2bytes.
   *
   * Before loading the instruction pointed to by the `mepcc` we should check
   * whether the `mepcc` address is invalid by checking the `mcause` register for
   * the `Instruction access fault` code (1u). If it is invalid, return the
   * unmodified `mepcc`, as attempting to load an instruction at an invalid
   * address below will cause another exception.
   */
  .balign 4
  .type compute_mepcc_on_synchronous_irq, @function
compute_mepcc_on_synchronous_irq:
  cspecialr ct0, mepcc
  csrr t1, mcause
  li t2, 0x01
  bne t1, t2, .L_load_mepcc
  cret
.L_load_mepcc:
  clh t2, 0(ct0)
  andi t1, t2, 3
  xori t1, t1, 3
  beqz t1, .L_32bit_trap_instr
  cincoffset ct0, ct0, OTTF_HALF_WORD_SIZE
  cret
.L_32bit_trap_instr:
  cincoffset ct0, ct0, OTTF_WORD_SIZE
  cret
  .size compute_mepcc_on_synchronous_irq, .-compute_mepcc_on_synchronous_irq

// -----------------------------------------------------------------------------

  /**
   * Interrupts and exceptions are not vectored on CHERIoT, so we need to filter
   * them here and dispatch to the appropriate handler.
   */

MachineSoftwareInterrupt = 3
MachineTimerInterrupt    = 7
MachineExternalInterrupt = 11

  .balign 4
  .global _trap_vector
  .type _trap_vector, @function
_trap_vector:
  // Decrease stack pointer in preparation for saving all register to stack.
  cincoffset csp, csp, -OTTF_CONTEXT_SIZE
  // Free up a temporary register, storing ct0 at offset 3.
  csc ct0, 3 * OTTF_CAP_SIZE(csp)
  // Read and check the cause of the interrupt/exception. The `interrupt` bit
  // is at position XLEN-1, and so can be detected using a signed comparison.
  csrr t0, mcause
  bge  t0, zero, handler_exception
  andi t0, t0, 0x1f
  addi t0, t0, -MachineSoftwareInterrupt
  beqz t0, handler_irq_software
  addi t0, t0, MachineSoftwareInterrupt - MachineTimerInterrupt
  beqz t0, handler_irq_timer
  addi t0, t0, MachineTimerInterrupt - MachineExternalInterrupt
  beqz t0, handler_irq_external
  j handler_irq_unknown
  .size _trap_vector, .-_trap_vector

  /**
   * Exception handler.
   */
  .balign 4
  .global handler_exception
  .type handler_exception, @function
handler_exception:
  // Save all registers to the stack.
  csc  cra,  1 * OTTF_CAP_SIZE(csp)
  csc  ctp,  2 * OTTF_CAP_SIZE(csp)
  // ct0 has already been stored at offset 3.
  csc  ct1,  4 * OTTF_CAP_SIZE(csp)
  csc  ct2,  5 * OTTF_CAP_SIZE(csp)
  csc  cs0,  6 * OTTF_CAP_SIZE(csp)
  csc  cs1,  7 * OTTF_CAP_SIZE(csp)
  csc  ca0,  8 * OTTF_CAP_SIZE(csp)
  csc  ca1,  9 * OTTF_CAP_SIZE(csp)
  csc  ca2, 10 * OTTF_CAP_SIZE(csp)
  csc  ca3, 11 * OTTF_CAP_SIZE(csp)
  csc  ca4, 12 * OTTF_CAP_SIZE(csp)
  csc  ca5, 13 * OTTF_CAP_SIZE(csp)

  // Save MSTATUS for the MPIE bit.
  csrr t0, mstatus
  csw t0, 14 * OTTF_CAP_SIZE(csp)

  // Save MEPC to the stack after updating it to the next instruction (since
  // this is a synchronous IRQ).
  cjal compute_mepcc_on_synchronous_irq
  csc ct0, 0(csp)

  // Jump to the exception handler.
  cmove ca0, csp
  cjal ottf_exception_handler

  // Return from ISR.
  j ottf_isr_exit
  .size handler_exception, .-handler_exception

// -----------------------------------------------------------------------------

  /**
   * Software IRQ handler.
   */
  .balign 4
  .global handler_irq_software
  .type handler_irq_software, @function
handler_irq_software:
  // Save all registers to the stack.
  csc  cra,  1 * OTTF_CAP_SIZE(csp)
  csc  ctp,  2 * OTTF_CAP_SIZE(csp)
  // ct0 has already been stored at offset 3.
  csc  ct1,  4 * OTTF_CAP_SIZE(csp)
  csc  ct2,  5 * OTTF_CAP_SIZE(csp)
  csc  cs0,  6 * OTTF_CAP_SIZE(csp)
  csc  cs1,  7 * OTTF_CAP_SIZE(csp)
  csc  ca0,  8 * OTTF_CAP_SIZE(csp)
  csc  ca1,  9 * OTTF_CAP_SIZE(csp)
  csc  ca2, 10 * OTTF_CAP_SIZE(csp)
  csc  ca3, 11 * OTTF_CAP_SIZE(csp)
  csc  ca4, 12 * OTTF_CAP_SIZE(csp)
  csc  ca5, 13 * OTTF_CAP_SIZE(csp)

  // Save MSTATUS for the MPIE bit.
  csrr t0, mstatus
  csw t0, 14 * OTTF_CAP_SIZE(csp)

  // Save MEPC to the stack.
  // NOTE: this IRQ is asynchronous, therefore, we do not need to modify MEPC.
  cspecialr ct0, mepcc
  csc ct0, 0(csp)

  // Jump to the software ISR.
  cmove ca0, csp
  cjal ottf_software_isr

  // Return from ISR.
  j ottf_isr_exit
  .size handler_irq_software, .-handler_irq_software

// -----------------------------------------------------------------------------

  /**
   * Timer IRQ handler.
   */
  .balign 4
  .global handler_irq_timer
  .type handler_irq_timer, @function
handler_irq_timer:
  // Save all registers to the stack.
  csc  cra,  1 * OTTF_CAP_SIZE(csp)
  csc  ctp,  2 * OTTF_CAP_SIZE(csp)
  // ct0 has already been stored at offset 3.
  csc  ct1,  4 * OTTF_CAP_SIZE(csp)
  csc  ct2,  5 * OTTF_CAP_SIZE(csp)
  csc  cs0,  6 * OTTF_CAP_SIZE(csp)
  csc  cs1,  7 * OTTF_CAP_SIZE(csp)
  csc  ca0,  8 * OTTF_CAP_SIZE(csp)
  csc  ca1,  9 * OTTF_CAP_SIZE(csp)
  csc  ca2, 10 * OTTF_CAP_SIZE(csp)
  csc  ca3, 11 * OTTF_CAP_SIZE(csp)
  csc  ca4, 12 * OTTF_CAP_SIZE(csp)
  csc  ca5, 13 * OTTF_CAP_SIZE(csp)

  // Save MSTATUS for the MPIE bit.
  csrr t0, mstatus
  csw t0, 14 * OTTF_CAP_SIZE(csp)

  // Save MEPC to the stack.
  // NOTE: this IRQ is asynchronous, therefore, we do not need to modify MEPC.
  cspecialr ct0, mepcc
  csc ct0, 0(csp)

  // Jump to timer ISR.
  cmove ca0, csp
  cjal ottf_timer_isr

  // Return from ISR.
  j ottf_isr_exit
  .size handler_irq_timer, .-handler_irq_timer

// -----------------------------------------------------------------------------

  /**
   * External IRQ handler.
   */
  .balign 4
  .global handler_irq_external
  .type handler_irq_external, @function
handler_irq_external:
  // Save all registers to the stack.
  csc  cra,  1 * OTTF_CAP_SIZE(csp)
  csc  ctp,  2 * OTTF_CAP_SIZE(csp)
  // ct0 has already been stored at offset 3.
  csc  ct1,  4 * OTTF_CAP_SIZE(csp)
  csc  ct2,  5 * OTTF_CAP_SIZE(csp)
  csc  cs0,  6 * OTTF_CAP_SIZE(csp)
  csc  cs1,  7 * OTTF_CAP_SIZE(csp)
  csc  ca0,  8 * OTTF_CAP_SIZE(csp)
  csc  ca1,  9 * OTTF_CAP_SIZE(csp)
  csc  ca2, 10 * OTTF_CAP_SIZE(csp)
  csc  ca3, 11 * OTTF_CAP_SIZE(csp)
  csc  ca4, 12 * OTTF_CAP_SIZE(csp)
  csc  ca5, 13 * OTTF_CAP_SIZE(csp)

  // Save MSTATUS for the MPIE bit.
  csrr t0, mstatus
  csw t0, 14 * OTTF_CAP_SIZE(csp)

  // Save MEPC to the stack.
  // NOTE: this IRQ is asynchronous, therefore, we do not need to modify MEPC.
  cspecialr ct0, mepcc
  csc ct0, 0(csp)

  // Jump to external ISR.
  cmove ca0, csp
  cjal ottf_external_isr

  // Return from ISR.
  j ottf_isr_exit
  .size handler_irq_external, .-handler_irq_external

// -----------------------------------------------------------------------------

  /**
   * Unknown IRQ handler.
   */
  .balign 4
  .global handler_irq_unknown
  .type handler_irq_unknown, @function
handler_irq_unknown:
  // Save all registers to the stack.
  csc  cra,  1 * OTTF_CAP_SIZE(csp)
  csc  ctp,  2 * OTTF_CAP_SIZE(csp)
  // ct0 has already been stored at offset 3.
  csc  ct1,  4 * OTTF_CAP_SIZE(csp)
  csc  ct2,  5 * OTTF_CAP_SIZE(csp)
  csc  cs0,  6 * OTTF_CAP_SIZE(csp)
  csc  cs1,  7 * OTTF_CAP_SIZE(csp)
  csc  ca0,  8 * OTTF_CAP_SIZE(csp)
  csc  ca1,  9 * OTTF_CAP_SIZE(csp)
  csc  ca2, 10 * OTTF_CAP_SIZE(csp)
  csc  ca3, 11 * OTTF_CAP_SIZE(csp)
  csc  ca4, 12 * OTTF_CAP_SIZE(csp)
  csc  ca5, 13 * OTTF_CAP_SIZE(csp)

  // Save MSTATUS for the MPIE bit.
  csrr t0, mstatus
  csw t0, 14 * OTTF_CAP_SIZE(csp)

  // Save MEPC to the stack.
  // NOTE: this IRQ is asynchronous, therefore, we do not need to modify MEPC.
  cspecialr ct0, mepcc
  csc ct0, 0(csp)

  // Jump to generic ISR.
  cmove ca0, csp
  cjal ottf_unknown_isr

  // Return from ISR.
  j ottf_isr_exit
  .size handler_irq_unknown, .-handler_irq_unknown

// -----------------------------------------------------------------------------

  /**
   * Internal IRQ handler.
   */
  .balign 4
  .global handler_irq_internal
  .type handler_irq_internal, @function
handler_irq_internal:
  // Save all registers to the stack.
  csc  cra,  1 * OTTF_CAP_SIZE(csp)
  csc  ctp,  2 * OTTF_CAP_SIZE(csp)
  // ct0 has already been stored at offset 3.
  csc  ct1,  4 * OTTF_CAP_SIZE(csp)
  csc  ct2,  5 * OTTF_CAP_SIZE(csp)
  csc  cs0,  6 * OTTF_CAP_SIZE(csp)
  csc  cs1,  7 * OTTF_CAP_SIZE(csp)
  csc  ca0,  8 * OTTF_CAP_SIZE(csp)
  csc  ca1,  9 * OTTF_CAP_SIZE(csp)
  csc  ca2, 10 * OTTF_CAP_SIZE(csp)
  csc  ca3, 11 * OTTF_CAP_SIZE(csp)
  csc  ca4, 12 * OTTF_CAP_SIZE(csp)
  csc  ca5, 13 * OTTF_CAP_SIZE(csp)

  // Save MSTATUS for the MPIE bit.
  csrr t0, mstatus
  csw t0, 14 * OTTF_CAP_SIZE(csp)

  // Save MEPC to the stack.
  // NOTE: this IRQ is asynchronous, therefore, we do not need to modify MEPC.
  cspecialr ct0, mepcc
  csc ct0, 0(csp)

  // Jump to the internal ISR.
  cmove ca0, csp
  cjal ottf_internal_isr

  // Return from ISR.
  j ottf_isr_exit
  .size handler_irq_internal, .-handler_irq_internal

// -----------------------------------------------------------------------------

  /**
   * ISR exit sub-routine restores registers from the stack.
   */
  .balign 4
  .global ottf_isr_exit
  .type ottf_isr_exit, @function
ottf_isr_exit:
  // Load the correct MEPCC for the next instruction in the current task.
  clc ct0, 0(csp)
  cspecialw mepcc, ct0

  // Load MSTATUS for the MPIE bit.
  clw  t0, 14 * OTTF_CAP_SIZE(csp)
  csrw mstatus, t0

  // Restore all registers from the stack.
  clc  cra,  1 * OTTF_CAP_SIZE(csp)
  clc  ctp,  2 * OTTF_CAP_SIZE(csp)
  clc  ct0,  3 * OTTF_CAP_SIZE(csp)
  clc  ct1,  4 * OTTF_CAP_SIZE(csp)
  clc  ct2,  5 * OTTF_CAP_SIZE(csp)
  clc  cs0,  6 * OTTF_CAP_SIZE(csp)
  clc  cs1,  7 * OTTF_CAP_SIZE(csp)
  clc  ca0,  8 * OTTF_CAP_SIZE(csp)
  clc  ca1,  9 * OTTF_CAP_SIZE(csp)
  clc  ca2, 10 * OTTF_CAP_SIZE(csp)
  clc  ca3, 11 * OTTF_CAP_SIZE(csp)
  clc  ca4, 12 * OTTF_CAP_SIZE(csp)
  clc  ca5, 13 * OTTF_CAP_SIZE(csp)
  cincoffset csp, csp, OTTF_CONTEXT_SIZE

  // This exits the ISR completely, and does not return control flow to the ISR
  // that called this sub-routine.
  mret

  .size ottf_isr_exit, .-ottf_isr_exit
