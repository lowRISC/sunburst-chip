// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/testing/test_framework/ottf_isrs.h"

#include "sw/device/lib/base/csr.h"
#include "sw/device/lib/base/macros.h"
#include "sw/device/lib/dif/dif_rv_plic.h"
#include "sw/device/lib/runtime/hart.h"
#include "sw/device/lib/runtime/ibex.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/runtime/print.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_macros.h"

#include "hw/top_chip/sw/autogen/top_chip.h"

dif_rv_plic_t ottf_plic;

// Fault reasons from
// https://riscv.org/wp-content/uploads/2017/05/riscv-privileged-v1.10.pdf
static const char *exception_reason[] = {
    "Instruction Misaligned",
    "Instruction Access",
    "Illegal Instruction",
    "Breakpoint",
    "Load Address Misaligned",
    "Load Access Fault",
    "Store Address Misaligned",
    "Store Access Fault",
    "U-mode Ecall",
    "S-mode Ecall",
    "Reserved",
    "M-mode Ecall",
    "Instruction Page Fault",
    "Load Page Fault",
    "Reserved",
    "Store Page Fault",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "CHERIoT Exception",
    "Reserved",
    "Reserved",
    "Reserved",
};

#if OTTF_CHERIOT
static const char *cheriot_exc_reason[] = {
    "None",
    "Bounds Violation",
    "Tag Violation",
    "Seal Violation",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "PERMIT_EXECUTE Violation",
    "PERMIT_LOAD Violation",
    "PERMIT_STORE Violation",
    "Reserved",
    "PERMIT_STORE_CAPABILITY Violation",
    "Reserved",
    "Reserved",
    "PERMIT_ACCESS_SYSTEM_REGISTERS Violation",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
};

static const char *exc_frame[] = {
    "mepcc", "  cra", "  ctp", "  ct0", "  ct1", "  ct2", "  cs0", "  cs1",
    "  ca0", "  ca1", "  ca2", "  ca3", "  ca4", "  ca5", " msts",
};
#else
static const char *exc_frame[] = {
    "mepc", "  ra", "  t0", "  t1", "  t2", "  s0", "  s1", "  a0",
    "  a1", "  a2", "  a3", "  a4", "  a5", "  a6", "  a7", "  s2",
    "  s3", "  s4", "  s5", "  s6", "  s7", "  s8", "  s9", " s10",
    " s11", "  t3", "  t4", "  t5", "  t6", "msts",
};
#endif

void ottf_generic_fault_print(uint32_t *exc_info, const char *reason,
                              uint32_t mcause) {
  enum { kExcWords = OTTF_CONTEXT_SIZE / OTTF_WORD_SIZE };
  uint32_t mepc = ibex_mepc_read();
  uint32_t mtval = ibex_mtval_read();
  if (exc_info) {
    base_printf("===== Exception Frame @ %08x =====", exc_info);
#if OTTF_CHERIOT
    for (size_t i = 0; i < kExcWords / 2; ++i) {
#else
    for (size_t i = 0; i < kExcWords; ++i) {
#endif
      if (i % 4 == 0) {
        base_printf("\n");
      }
      const char *name = exc_frame[i];
      if (name == NULL)
        continue;
#if OTTF_CHERIOT
      // TODO: Is there a way that we can report the tag bits too, without using CLC which
      // presumably could incur a nested exception?
      base_printf(" %4s=%08x+%08x", name, exc_info[2*i], exc_info[2*i+1]);
#else
      base_printf(" %4s=%08x", name, exc_info[i]);
#endif
    }
    uint32_t *sp = exc_info + kExcWords;
    base_printf("\n");
    uint32_t *ram_start = (uint32_t *)TOP_CHIP_SRAM_CTRL_MAIN_RAM_BASE_ADDR;
    uint32_t *ram_end =
        (uint32_t *)(TOP_CHIP_SRAM_CTRL_MAIN_RAM_BASE_ADDR +
                     TOP_CHIP_SRAM_CTRL_MAIN_RAM_SIZE_BYTES);

    extern const char _text_start[], _text_end[];
    const uint32_t text_start = (uint32_t)_text_start;
    const uint32_t text_end = (uint32_t)_text_end;
    base_printf("===== Call Stack =====\n");
    for (; sp >= ram_start && sp < ram_end; ++sp) {
      uint32_t val = *sp;
      if (val >= text_start && val < text_end) {
        base_printf("    %08x\n", val);
      }
    }
  }
  LOG_ERROR("FAULT: %s. MCAUSE=%08x MEPC=%08x MTVAL=%08x", reason, mcause, mepc,
            mtval);
#if OTTF_CHERIOT
  if ((mcause & kIbexExcMax) == kIbexExcCHERIoT) {
    LOG_ERROR("CHERIoT MTVAL CAUSE: %s.", cheriot_exc_reason[mtval & kIbexExcMax]);
  }
#endif
}

static void generic_fault_handler(uint32_t *exc_info) {
  uint32_t mcause = ibex_mcause_read();
  ottf_generic_fault_print(exc_info, exception_reason[mcause & kIbexExcMax],
                           mcause);
  abort();
}

OT_WEAK
void ottf_exception_handler(uint32_t *exc_info) {
  uint32_t mcause = ibex_mcause_read();

  switch ((ibex_exc_t)(mcause & kIbexExcMax)) {
    case kIbexExcInstrMisaligned:
      ottf_instr_misaligned_fault_handler(exc_info);
      break;
    case kIbexExcInstrAccessFault:
      ottf_instr_access_fault_handler(exc_info);
      break;
    case kIbexExcIllegalInstrFault:
      ottf_illegal_instr_fault_handler(exc_info);
      break;
    case kIbexExcBreakpoint:
      ottf_breakpoint_handler(exc_info);
      break;
    case kIbexExcLoadAccessFault:
      ottf_load_store_fault_handler(exc_info);
      break;
    case kIbexExcStoreAccessFault:
      ottf_load_store_fault_handler(exc_info);
      break;
    case kIbexExcMachineECall:
      ottf_machine_ecall_handler(exc_info);
      break;
    case kIbexExcUserECall:
      ottf_user_ecall_handler(exc_info);
      break;
    case kIbexExcCHERIoT:
      ottf_cheriot_exc_handler(exc_info);
      break;
    default:
      generic_fault_handler(exc_info);
  }
}

OT_WEAK
OT_ALIAS("generic_fault_handler")
void ottf_instr_misaligned_fault_handler(uint32_t *exc_info);

OT_WEAK
OT_ALIAS("generic_fault_handler")
void ottf_instr_access_fault_handler(uint32_t *exc_info);

OT_WEAK
OT_ALIAS("generic_fault_handler")
void ottf_illegal_instr_fault_handler(uint32_t *exc_info);

OT_WEAK
OT_ALIAS("generic_fault_handler")
void ottf_breakpoint_handler(uint32_t *exc_info);

OT_WEAK
OT_ALIAS("generic_fault_handler")
void ottf_load_store_fault_handler(uint32_t *exc_info);

OT_WEAK
OT_ALIAS("generic_fault_handler")
void ottf_machine_ecall_handler(uint32_t *exc_info);

OT_WEAK
OT_ALIAS("generic_fault_handler")
void ottf_user_ecall_handler(uint32_t *exc_info);

OT_WEAK
OT_ALIAS("generic_fault_handler")
void ottf_cheriot_exc_handler(uint32_t *exc_info);

OT_WEAK
void ottf_software_isr(uint32_t *exc_info) {
  ottf_generic_fault_print(exc_info, "Software IRQ", ibex_mcause_read());
  abort();
}

OT_WEAK
void ottf_timer_isr(uint32_t *exc_info) {
  ottf_generic_fault_print(exc_info, "Timer IRQ", ibex_mcause_read());
  abort();
}

OT_WEAK
bool ottf_console_flow_control_isr(uint32_t *exc_info) { return false; }

OT_WEAK
void ottf_external_isr(uint32_t *exc_info) {
  const uint32_t kPlicTarget = kTopChipPlicTargetIbex0;
  dif_rv_plic_irq_id_t plic_irq_id;
  CHECK_DIF_OK(dif_rv_plic_irq_claim(&ottf_plic, kPlicTarget, &plic_irq_id));

// TODO: Complete this; Sunburst chip has a single PLIC IRQ per peripheral.
#if 0
  top_chip_plic_peripheral_t peripheral = (top_chip_plic_peripheral_t)
      top_chip_plic_interrupt_for_peripheral[plic_irq_id];

  if (peripheral == kTopChipPlicPeripheralUart0 &&
      ottf_console_flow_control_isr(exc_info)) {
    // Complete the IRQ at PLIC.
    CHECK_DIF_OK(
        dif_rv_plic_irq_complete(&ottf_plic, kPlicTarget, plic_irq_id));
    return;
  }
#endif
  ottf_generic_fault_print(exc_info, "External IRQ", ibex_mcause_read());
  abort();
}

static void generic_internal_irq_handler(uint32_t *exc_info) {
  ottf_generic_fault_print(exc_info, "Internal IRQ", ibex_mcause_read());
  abort();
}

OT_WEAK
OT_ALIAS("generic_internal_irq_handler")
void ottf_external_nmi_handler(uint32_t *exc_info);

OT_WEAK
OT_ALIAS("generic_internal_irq_handler")
void ottf_load_integrity_error_handler(uint32_t *exc_info);

OT_WEAK
void ottf_internal_isr(uint32_t *exc_info) {
  uint32_t mcause = ibex_mcause_read();
  switch ((ibex_internal_irq_t)(mcause)) {
    case kIbexInternalIrqLoadInteg:
      ottf_load_integrity_error_handler(exc_info);
      break;
    case kIbexInternalIrqNmi:
      ottf_external_nmi_handler(exc_info);
      break;
    default:
      generic_internal_irq_handler(exc_info);
  }
}
