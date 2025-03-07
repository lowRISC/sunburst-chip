// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/runtime/log.h"

#include <assert.h>

#include "sw/device/lib/arch/device.h"
#include "sw/device/lib/base/memory.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/runtime/print.h"

/**
 * Ensure that log_fields_t is always 32 bytes.
 *
 * The assertion below helps prevent inadvertent changes to the struct.
 * Please see the description of log_fields_t in log.h for more details.
 */
static_assert(sizeof(log_fields_t) == 32,
              "log_fields_t must always be 32 bytes.");

/**
 * Converts a severity to a static string.
 */
static const char *stringify_severity(log_severity_t severity) {
  switch (severity) {
    case kLogSeverityInfo:
      return "I";
    case kLogSeverityWarn:
      return "W";
    case kLogSeverityError:
      return "E";
    case kLogSeverityFatal:
      return "F";
    default:
      return "?";
  }
}

/**
 * Logs `log` and the values that follow to stdout.
 *
 * @param log the log data to log.
 * @param ... format parameters matching the format string.
 */
void base_log_internal_core(const log_fields_t *log, ...) {
  size_t file_name_len =
      (size_t)(((const char *)memchr(log->file_name, '\0', PTRDIFF_MAX)) -
               log->file_name);
  const char *base_name = memrchr(log->file_name, '/', file_name_len);
  if (base_name == NULL) {
    base_name = log->file_name;
  } else {
    ++base_name;  // Remove the final '/'.
  }

  // A small global counter that increments with each log line. This can be
  // useful for seeing how many times this function has been called, even if
  // nothing was printed for some time.
  static uint16_t global_log_counter = 0;

  base_printf("%s%05d %s:%d] ", stringify_severity(log->severity),
              global_log_counter, base_name, log->line);
  ++global_log_counter;

  va_list args;
  va_start(args, log);
  base_vprintf(log->format, args);
  va_end(args);

  base_printf("\r\n");
}

/**
 * Logs `log` and the values that follow in an efficient, DV-testbench
 * specific way, which bypasses the UART.
 *
 * @param log a pointer to log data to log. Note that this pointer is likely to
 *        be invalid at runtime, since the pointed-to data will have been
 *        stripped from the binary.
 * @param nargs the number of arguments passed to the format string.
 * @param ... format parameters matching the format string.
 */
void base_log_internal_dv(const log_fields_t *log, uint32_t nargs, ...) {
  mmio_region_t log_device = mmio_region_from_addr(kDeviceLogBypassUartAddress);
  mmio_region_write32(log_device, 0x0, (uintptr_t)log);

  va_list args;
  va_start(args, nargs);
  for (int i = 0; i < nargs; ++i) {
    mmio_region_write32(log_device, 0x0, va_arg(args, uint32_t));
  }
  va_end(args);
}

/**
 * Logs `log` and the values that follow in an efficient, DV-testbench
 * specific way, which bypasses the UART.
 *
 * @param format Format specifier string.
 * @param log_offset Byte offset of the log_fields_t structure from the
 *                   start of the .logs.fields section.
 * @param nargs the number of arguments passed to the format string.
 * @param ... format parameters matching the format string.
 */
void base_log_internal_dv_cheri(const char *format, uint32_t log_offset,
                                uint32_t nargs, ...) {
  mmio_region_t log_device = mmio_region_from_addr(kDeviceLogBypassUartAddress);
  mmio_region_write32(log_device, 0x0, log_offset);

  va_list args;
  va_start(args, nargs);
  for (int i = 0; i < nargs; ++i) {
    // Locate the format specifier for this argument.
    if (format) {
      while (*format != '\0') {
        if (*format == '%') {
          if (format[1] != '%') {
            break;
          }
          // Skip %% and continue parsing.
          format++;
        }
        format++;
      }
    }
    bool done = false;
    if (format && *format == '%') {
      // The logging code does not accept standard C-style format specififers;
      // instead alignment and precision are not supported, and there are some
      // non-standard extensions.
      bool non_std = (*++format == '!');
      if (non_std) {
        format++;
      }
      while (*format >= '0' && *format <= '9') {
        format++;
      }
      if (non_std) {
        switch (*format) {
          // These arguments are prefixed by a `size_t` byte count.
          case 'x':
          case 'y':
          case 'X':
          case 'Y': {
            size_t n = va_arg(args, size_t);
            void *ptr = va_arg(args, void *);
            if (sizeof(size_t) > 4u) {
              mmio_region_write32(log_device, 0x0, (uint32_t)n);
              n >>= 32;
            }
            mmio_region_write32(log_device, 0x0, (uint32_t)n);
            mmio_region_write32(log_device, 0x0, __builtin_cheri_address_get(ptr));
            done = true;
          }
          break;
        }
      } else if (*format == 'p' || *format == 's') {
        void *ptr = va_arg(args, void *);
        mmio_region_write32(log_device, 0x0, __builtin_cheri_address_get(ptr));
        done = true;
      }
      format++;
    }
    if (!done) {
      // Most arguments are uint32_t quantities with the interpretation left
      // up to the DV support.
      mmio_region_write32(log_device, 0x0, va_arg(args, uint32_t));
    }
  }
  va_end(args);
}
