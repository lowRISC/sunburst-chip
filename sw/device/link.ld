/**
 * Copyright lowRISC contributors.
 * Licensed under the Apache License, Version 2.0, see LICENSE for details.
 * SPDX-License-Identifier: Apache-2.0
 */

ENTRY(start)

/**
 * DV Log offset.
 */
_dv_log_offset = 0x10000;

SECTIONS
{
    /* Cannot yet separate code and data, so place everything in SRAM. */
    /*. = 0x00100000; */

    . = 0x00200000;
    .text :
    {
      /* Note: although CHERIoT does not support vectored interrupts, the core still
         commences execution at an offset of 0x80 bytes */
      . = . + 0x80;
      _text_start = .;
      *(.text.start .text.start.*);
      *(.vectors);
      */boot/*(.text);
      */boot/*(.text.*);
      *(.text .text.* .rodata .rodata.* .data.rel.ro);
      . = ALIGN(4);
      _text_end = .;
      . = ALIGN(64);
    }

    /* Note: extract_sw_logs.py operates on the whole of this section and does not
       consult the _start/_stop symbols presently, so avoid alignment directives. */
    __cap_relocs : {
      __start___cap_relocs = .;
      *(__cap_relocs)
      __stop___cap_relocs = .;
    }

    .data :
    {
      __DATA_BEGIN__ = .;
      . = ALIGN(64);
      *(.data .data.*)
      *(.sdata .sdata.*)
      . = ALIGN(64);
      *(.sbss .sbss.*)
      *(.bss .bss.*)
      . = ALIGN(4);
      __DATA_END__ = .;
      /*
       * CHERI accesses globals using offsets from GP and the linker assumes
       * that GP is located at midpoint of the output section *for each symbol*.
       * This implies that for things to work properly all globals *must* be in
       * the same section and GP set to midpoint of that section.
       */
      __global_pointer$ = __DATA_BEGIN__ + (__DATA_END__ - __DATA_BEGIN__) / 2;
    }

    .logs.fields 0 (INFO): {
      _log_fields_start = .;
      LONG(_dv_log_offset);
      *(.logs.fields)
    }

    /*
     * DWARF debug sections.
     * Symbols in the DWARF debugging sections (and other note sections) are
     * relative to the beginning of the section so we begin them at 0.
     */
    .debug_aranges  0 : { *(.debug_aranges) }
    .debug_pubnames 0 : { *(.debug_pubnames) }
    .debug_info     0 : { *(.debug_info) }
    .debug_abbrev   0 : { *(.debug_abbrev) }
    .debug_line     0 : { *(.debug_line) }
    .debug_frame    0 : { *(.debug_frame) }
    .debug_str      0 : { *(.debug_str) }
    .debug_loc      0 : { *(.debug_loc) }
    .debug_macinfo  0 : { *(.debug_macinfo) }
    .debug_pubtypes 0 : { *(.debug_pubtypes) }
    .debug_ranges   0 : { *(.debug_ranges) }

    /* Other note sections to keep */
    .comment   0 : { *(.comment) }
    .riscv.attributes   0 : { *(.riscv.attributes) }

    /*
     * Discard other sections.
     * This ensures that unknown sections are not arbitrarily placed by the linker.
     * Linker will generate error if a referenced symbol is discarded.
     */
    /DISCARD/ : { *.* }
}
