/**
 * Copyright lowRISC contributors.
 * Licensed under the Apache License, Version 2.0, see LICENSE for details.
 * SPDX-License-Identifier: Apache-2.0
 */

SECTIONS
{
    /* Cannot yet separate code and data, so place everything in SRAM. */
    /*. = 0x00100000; */
    . = 0x00200000;
    _start = .;

    .rom_loader :
    {
        *(.text.start);
        *(.vectors);
        *(.text .text.* .rodata .rodata.* .data.rel.ro);
        . = ALIGN(4);
    }

    .data :
    {
        __DATA_BEGIN__ = .;
        *(.data .data.*)
        *(.sdata .sdata.*)
        *(.sbss .sbss.*)
        *(.bss .bss.*)
        __DATA_END__ = .;
        /*
         * CHERI accesses globals using offsets from GP and the linker assumes
         * that GP is located at midpoint of the output section *for each symbol*.
         * This implies that for things to work properly all globals *must* be in
         * the same section and GP set to midpoint of that section.
         */
        __global_pointer$ = __DATA_BEGIN__ + (__DATA_END__ - __DATA_BEGIN__) / 2;
    }


    /*
     * Start DV Sections
     * The following sections are used by DV to implement logging in an
     * alternate way, which enables simulation speed up by completely avoiding
     * any string format processing or even the actual transmission of log data
     * to a real peripheral.
     *
     * These sections are marked as dummy so that they can still be extracted
     * using readelf or similar utilities. As such, the content in these sections
     * is not relevant for the actual SW code and can be safely discarded.
     */

    /*
     * DV Log offset.
     *
     * The value of _dv_log_offset has to be different to other boot stages.
     *
     * Note: The method of defining _dv_log_offset must avoid causing linking
     *       errors when using a CHERI toolchain, even if it looks weird.
     */
    .logs.offset 0 (INFO) : {
      _dv_log_offset = . + 0x10000;
    }

    /*
     * The following section contains log fields constructed from the logs using
     * the log_fields_t struct defined in sw/device/lib/runtime/log.h. The size of
     * each log field is fixed - 20 bytes. To distinguish between the fields of
     * different ELF files we add an offset to the address. We register that offset
     * here as a header before the log fields.
     */
    .logs.fields 0 (INFO): {
        LONG(_dv_log_offset);
        *(.logs.fields)
    }

    /*
     * End DV Sections
     */

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
