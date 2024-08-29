.include "assembly-helpers.s"

  .section .text.start, "ax", @progbits
.zero 0x80

  .globl start
  .p2align 2
    .type start,@function
start:
  // ca0 (first argument) contains the read-write root
  cspecialr        ca0, mtdc

  // No bounds on stack, grows down from the end of IRAM
  li               sp, 0x00230000

  // Zero 2k of stack (prevents Xs in sim)
  csetaddr         ct0, ca0, sp
  li               t1, 0x200
stack_clear_loop:
  cincoffset       ct0, ct0, -4
  csw              zero, 0(ct0)
  add              t1, t1, -1
  bne              t1, zero, stack_clear_loop

  csetaddr         csp, ca0, sp
  auipcc           cra, 0
  // Call the C++ entry point
  la_abs           t0, rom_loader_entry
  csetaddr         cra, cra, t0
  cjalr            cra
