.include "assembly-helpers.s"

  .section .text.start, "ax", @progbits
.zero 0x80

  .globl start
  .p2align 2
    .type start,@function
start:
  // ca0 (first argument) contains the read-write root
  cspecialr        ca0, mtdc

  // Clear the revocation bitmap before entering C/C++ code.
  // The bitmap is not cleared upon reset so memset to return it to a
  // pristine state; also prevent Xs in sim.
  //
  // 8KiB with one bit covering each 64 bits (8 bytes) corresponding to 512KiB SRAM.
  li               a1, 0x00300000
  csetaddr         ca1, ca0, a1
  li               a2, 0x2000  // 8KiB.
0:
  csw              zero, 0(ca1)
  cincoffset       ca1, ca1, 4
  addi             a2, a2, -4
  bnez             a2, 0b

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
