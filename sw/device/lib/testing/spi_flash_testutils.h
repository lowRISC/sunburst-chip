// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef OPENTITAN_SW_DEVICE_LIB_TESTING_SPI_FLASH_TESTUTILS_H_
#define OPENTITAN_SW_DEVICE_LIB_TESTING_SPI_FLASH_TESTUTILS_H_

#include <stdbool.h>
#include <stdint.h>

#include "sw/device/lib/base/bitfield.h"
#include "sw/device/lib/base/status.h"
#include "sw/device/lib/dif/dif_spi_host.h"

/**
 * A set of typical opcodes for named flash commands.
 */
typedef enum spi_device_flash_opcode {
  kSpiDeviceFlashOpReadJedec = 0x9f,
  kSpiDeviceFlashOpReadSfdp = 0x5a,
  kSpiDeviceFlashOpReadNormal = 0x03,
  kSpiDeviceFlashOpRead4b = 0x13,
  kSpiDeviceFlashOpReadFast = 0x0b,
  kSpiDeviceFlashOpReadFast4b = 0x0c,
  kSpiDeviceFlashOpReadDual = 0x3b,
  kSpiDeviceFlashOpReadQuad = 0x6b,
  kSpiDeviceFlashOpWriteEnable = 0x06,
  kSpiDeviceFlashOpWriteDisable = 0x04,
  kSpiDeviceFlashOpReadStatus1 = 0x05,
  kSpiDeviceFlashOpReadStatus2 = 0x35,
  kSpiDeviceFlashOpReadStatus3 = 0x15,
  kSpiDeviceFlashOpWriteStatus1 = 0x01,
  kSpiDeviceFlashOpWriteStatus2 = 0x31,
  kSpiDeviceFlashOpWriteStatus3 = 0x11,
  kSpiDeviceFlashOpChipErase = 0xc7,
  kSpiDeviceFlashOpSectorErase = 0x20,
  kSpiDeviceFlashOpBlockErase32k = 0x52,
  kSpiDeviceFlashOpBlockErase64k = 0xd8,
  kSpiDeviceFlashOpPageProgram = 0x02,
  kSpiDeviceFlashOpEnter4bAddr = 0xb7,
  kSpiDeviceFlashOpExit4bAddr = 0xe9,
  kSpiDeviceFlashOpResetEnable = 0x66,
  kSpiDeviceFlashOpReset = 0x99,
  kSpiDeviceFlashOpSectorErase4b = 0x21,
  kSpiDeviceFlashOpBlockErase32k4b = 0x5c,
  kSpiDeviceFlashOpBlockErase64k4b = 0xdc,
  kSpiDeviceFlashOpPageProgram4b = 0x12,
} spi_device_flash_opcode_t;

typedef struct spi_flash_testutils_jedec_id {
  uint16_t device_id;
  uint8_t manufacturer_id;
  uint8_t continuation_len;
} spi_flash_testutils_jedec_id_t;

enum {
  // The standard SFDP signature value.
  kSfdpSignature = 0x50444653,
};

/**
 * Transaction width mode.
 */
typedef enum spi_flash_testutils_transaction_width_mode {
  /* Use 1 channel for opcode, 1 channel for address and 1 channel for data. */
  kTransactionWidthMode111 = 0,
  /* Use 1 channel for opcode, 1 channel for address and 2 channels for data. */
  kTransactionWidthMode112,
  /* Use 1 channel for opcode, 2 channels for address and 2 channels for data.
   */
  kTransactionWidthMode122,
  /* Use 2 channels for opcode, 2 channels for address and 2 channels for data.
   */
  kTransactionWidthMode222,
  /* Use 1 channel for opcode, 1 channel for address and 4 channel for data. */
  kTransactionWidthMode114,
  /* Use 1 channel for opcode, 4 channels for address and 4 channels for data.
   */
  kTransactionWidthMode144,
  /* Use 4 channels for opcode, 4 channels for address and 4 channels for data.
   */
  kTransactionWidthMode444,
} spi_flash_testutils_transaction_width_mode_t;

typedef struct spi_flash_testutils_sfdp_header {
  uint32_t signature;
  uint8_t minor;
  uint8_t major;
  uint8_t nph;
  uint8_t reserved;
} spi_flash_testutils_sfdp_header_t;

typedef struct spi_flash_testutils_parameter_header {
  uint8_t param_id;
  uint8_t minor;
  uint8_t major;
  uint8_t length;
  uint8_t table_pointer[3];
  uint8_t pad;
} spi_flash_testutils_parameter_header_t;

// JESD216F, section 6.4.18:
// The Quad Enable mechanism is bits 20:23 of the 15th dword.
#define SPI_FLASH_QUAD_ENABLE ((bitfield_field32_t){.mask = 7, .index = 20})
#define SPI_FLASH_ADDRESS_MODE ((bitfield_field32_t){.mask = 3, .index = 17})

/**
 * Read out the JEDEC ID from the SPI flash.
 *
 * @param spih A SPI host handle.
 * @param[out] id A pointer to where to store the ID.
 * @return The result of the operation.
 */
OT_WARN_UNUSED_RESULT
status_t spi_flash_testutils_read_id(dif_spi_host_t *spih,
                                     spi_flash_testutils_jedec_id_t *id);

/**
 * Read out the SFDP from the indicated address and place the table contents
 * into the buffer.
 *
 * @param spih A SPI host handle.
 * @param[out] buffer A pointer to a buffer that will hold the SFDP contents.
 * @param length The number of bytes to write into `buffer`.
 * @return The result of the operation.
 */
OT_WARN_UNUSED_RESULT
status_t spi_flash_testutils_read_sfdp(dif_spi_host_t *spih, uint32_t address,
                                       void *buffer, size_t length);

typedef enum spi_flash_status_bit {
  kSpiFlashStatusBitWip = 0x1,
  kSpiFlashStatusBitWel = 0x2,
} spi_flash_status_bit_t;

/**
 * Perform a Read Status command.
 *
 * Issues a Read Status transaction using the requested opcode.
 * In the case of a multi-byte status, the bytes are assembled and returned
 * as a litte-endian word.
 *
 * @param spih A SPI host handle.
 * @param opcode The desired Read Status opcode.
 * @param length The result length (1 to 3 bytes).
 * @return status_t containing either the status register value or an error.
 */
OT_WARN_UNUSED_RESULT
status_t spi_flash_testutils_read_status(dif_spi_host_t *spih, uint8_t opcode,
                                         size_t length);

/**
 * Perform a Write Status command.
 *
 * Issues a Write Status transaction using the requested opcode.
 * In the case of a multi-byte status, the status word bytes are
 * as a litte-endian word.
 *
 * @param spih A SPI host handle.
 * @param opcode The desired Write Status opcode.
 * @param status The status register value to write.
 * @param length The status length (1 to 3 bytes).
 * @return status_t containing either OK or an error.
 */
OT_WARN_UNUSED_RESULT
status_t spi_flash_testutils_write_status(dif_spi_host_t *spih, uint8_t opcode,
                                          uint32_t status, size_t length);
/**
 * Spin wait until a Read Status command shows the downstream SPI flash is no
 * longer busy.
 *
 * @param spih A SPI host handle.
 * @return status_t containing either OK or an error.
 */
OT_WARN_UNUSED_RESULT
status_t spi_flash_testutils_wait_until_not_busy(dif_spi_host_t *spih);

/**
 * Issue the Write Enable command to the downstream SPI flash.
 *
 * @param spih A SPI host handle.
 * @return status_t containing either OK or an error.
 */
OT_WARN_UNUSED_RESULT
status_t spi_flash_testutils_issue_write_enable(dif_spi_host_t *spih);

/**
 * Perform full Chip Erase sequence, including the Write Enable and Chip Erase
 * commands, and poll the status registers in a loop until the WIP bit clears.
 *
 * Does not return until the erase completes.
 *
 * @param spih A SPI host handle.
 * @return status_t containing either OK or an error.
 */
OT_WARN_UNUSED_RESULT
status_t spi_flash_testutils_erase_chip(dif_spi_host_t *spih);

/**
 * Perform full Sector Erase sequence via the requested opcode.
 * The sequence includes the Write Enable and Sector Erase commands,
 * and then polls the status registers in a loop until the WIP
 * bit clears.
 *
 * Does not return until the erase completes.
 *
 * @param spih A SPI host handle.
 * @param opcode The desired erase opcode.
 * @param address An address contained within the desired sector.
 * @param addr_is_4b True if `address` is 4 bytes long, else 3 bytes.
 * @return status_t containing either OK or an error.
 */
OT_WARN_UNUSED_RESULT
status_t spi_flash_testutils_erase_op(dif_spi_host_t *spih, uint8_t opcode,
                                      uint32_t address, bool addr_is_4b);

/**
 * Perform full Sector Erase sequence via the standard Sector Erase opcode.
 * The sequence includes the Write Enable and Sector Erase commands,
 * and then polls the status registers in a loop until the WIP
 * bit clears.
 * Does not return until the erase completes.
 *
 * @param spih A SPI host handle.
 * @param address An address contained within the desired sector.
 * @param addr_is_4b True if `address` is 4 bytes long, else 3 bytes.
 * @return status_t containing either OK or an error.
 */
OT_WARN_UNUSED_RESULT
status_t spi_flash_testutils_erase_sector(dif_spi_host_t *spih,
                                          uint32_t address, bool addr_is_4b);

/**
 * Perform full 32 kB block erase.
 * The sequence includes the Write Enable and Block Erase commands,
 * and then polls the status registers in a loop until the WIP
 * bit clears.
 * Does not return until the erase completes.
 *
 * @param spih A SPI host handle.
 * @param address An address contained within the desired block.
 * @param addr_is_4b True if `address` is 4 bytes long, else 3 bytes.
 * @return status_t containing either OK or an error.
 */
status_t spi_flash_testutils_erase_block32k(dif_spi_host_t *spih,
                                            uint32_t address, bool addr_is_4b);

/**
 * Perform full 64 kB block erase.
 * The sequence includes the Write Enable and Block Erase commands,
 * and then polls the status registers in a loop until the WIP
 * bit clears.
 * Does not return until the erase completes.
 *
 * @param spih A SPI host handle.
 * @param address An address contained within the desired block.
 * @param addr_is_4b True if `address` is 4 bytes long, else 3 bytes.
 * @return status_t containing either OK or an error.
 */
status_t spi_flash_testutils_erase_block64k(dif_spi_host_t *spih,
                                            uint32_t address, bool addr_is_4b);
/**
 * Perform full Page Program sequence via the requested opcode.
 * The sequence includes the Write Enable and Page Program commands,
 * and then polls the status registers in a loop until the WIP bit
 * clears.
 *
 * Does not return until the programming operation completes.
 *
 * @param spih A SPI host handle.
 * @param opcode The desired program opcode.
 * @param payload A pointer to the payload to be written to the page.
 * @param length Number of bytes in the payload. Must be less than or equal to
 *               256 bytes.
 * @param address The start address where the payload programming should begin.
 *                Note that an address + length that crosses a page boundary may
 *                wrap around to the start of the page.
 * @param addr_is_4b True if `address` is 4 bytes long, else 3 bytes.
 * @param page_program_mode The width of the transaction sections (opcode,
 * address and data).
 * @return status_t containing either OK or an error.
 */
OT_WARN_UNUSED_RESULT
status_t spi_flash_testutils_program_op(
    dif_spi_host_t *spih, uint8_t opcode, const void *payload, size_t length,
    uint32_t address, bool addr_is_4b,
    spi_flash_testutils_transaction_width_mode_t page_program_mode);

/**
 * Perform full Page Program sequence via the standard page program opcode.
 * The sequence includes the Write Enable and Page Program commands,
 * and then polls the status registers in a loop until the WIP bit
 * clears.
 *
 * Does not return until the programming operation completes.
 *
 * @param spih A SPI host handle.
 * @param payload A pointer to the payload to be written to the page.
 * @param length Number of bytes in the payload. Must be less than or equal to
 *               256 bytes.
 * @param address The start address where the payload programming should begin.
 *                Note that an address + length that crosses a page boundary may
 *                wrap around to the start of the page.
 * @param addr_is_4b True if `address` is 4 bytes long, else 3 bytes.
 * @return status_t containing either OK or an error.
 */
OT_WARN_UNUSED_RESULT
status_t spi_flash_testutils_program_page(dif_spi_host_t *spih,
                                          const void *payload, size_t length,
                                          uint32_t address, bool addr_is_4b);
/**
 * Perform full Page Program sequence via the quad page program opcode.
 * The sequence includes the Write Enable and Page Program commands,
 * and then polls the status registers in a loop until the WIP bit
 * clears.
 *
 * Does not return until the programming operation completes.
 *
 * @param spih A SPI host handle.
 * @param opcode The program page quad opcode as it varies across parts.
 * @param payload A pointer to the payload to be written to the page.
 * @param length Number of bytes in the payload. Must be less than or equal to
 *               256 bytes.
 * @param address The start address where the payload programming should begin.
 *                Note that an address + length that crosses a page boundary may
 *                wrap around to the start of the page.
 * @param addr_is_4b True if `address` is 4 bytes long, else 3 bytes.
 * @param addr_width The width of the transaction addressing section.
 * @return status_t containing either OK or an error.
 */
OT_WARN_UNUSED_RESULT
status_t spi_flash_testutils_program_page_quad(
    dif_spi_host_t *spih, uint8_t opcode, const void *payload, size_t length,
    uint32_t address, bool addr_is_4b, uint8_t addr_width);

/**
 * Perform a read via the requested opcode.
 *
 * @param spih A SPI host handle.
 * @param opcode The desired read opcode.
 * @param[out] payload A pointer to the buffer to receive data from the device.
 * @param length Number of bytes in the buffer. Must be less than or equal to
 *               256 bytes.
 * @param address The start address where the read should begin.
 * @param addr_is_4b True if `address` is 4 bytes long, else 3 bytes.
 * @param width The width of the read (1, 2 or 4 bits).
 * @param dummy The number of dummy cycles required after the address phase.
 * @return status_t containing either OK or an error.
 */
OT_WARN_UNUSED_RESULT
status_t spi_flash_testutils_read_op(dif_spi_host_t *spih, uint8_t opcode,
                                     void *payload, size_t length,
                                     uint32_t address, bool addr_is_4b,
                                     uint8_t width, uint8_t dummy);

/**
 * Enable or disable Quad mode on the EEPROM according to the SFDP-described
 * method.
 *
 * @param spih A SPI host handle.
 * @param method The method to use to enable.  This value should come from the
 *               SFDP quad-enable field described in JESD216 section 6.4.18.
 * @param enable Whether to enable or disable quad mode.
 * @return status_t containing either OK or an error.
 */
OT_WARN_UNUSED_RESULT
status_t spi_flash_testutils_quad_enable(dif_spi_host_t *spih, uint8_t method,
                                         bool enable);
/**
 * Enables 4-bytes addressing mode.
 *
 * @param spih  A SPI host handle.
 * @return status_t containing either OK or an error.
 */
OT_WARN_UNUSED_RESULT
status_t spi_flash_testutils_enter_4byte_address_mode(dif_spi_host_t *spih);

/**
 * Disables 4-bytes addressing mode.
 *
 * @param spih A SPI host handle.
 * @return status_t containing either OK or an error.
 */
OT_WARN_UNUSED_RESULT
status_t spi_flash_testutils_exit_4byte_address_mode(dif_spi_host_t *spih);

/**
 * Get the opcode width of a transaction mode.
 *
 * @param width_mode The transaction width mode.
 * @return The opcode width
 */
inline static dif_spi_host_width_t spi_flash_testutils_get_opcode_width(
    spi_flash_testutils_transaction_width_mode_t width_mode) {
  switch (width_mode) {
    case kTransactionWidthMode222:
      return kDifSpiHostWidthDual;
    case kTransactionWidthMode444:
      return kDifSpiHostWidthQuad;
    default:
      return kDifSpiHostWidthStandard;
  }
};

/**
 * Get the address width of a transaction mode.
 *
 * @param width_mode The transaction width mode.
 * @return The address width
 */
inline static dif_spi_host_width_t spi_flash_testutils_get_address_width(
    spi_flash_testutils_transaction_width_mode_t width_mode) {
  switch (width_mode) {
    case kTransactionWidthMode122:
      return kDifSpiHostWidthDual;
    case kTransactionWidthMode222:
      return kDifSpiHostWidthDual;
    case kTransactionWidthMode144:
      return kDifSpiHostWidthQuad;
    case kTransactionWidthMode444:
      return kDifSpiHostWidthQuad;
    default:
      return kDifSpiHostWidthStandard;
  }
};

/**
 * Get the data width of a transaction mode.
 *
 * @param width_mode The transaction width mode.
 * @return The data width
 */
inline static dif_spi_host_width_t spi_flash_testutils_get_data_width(
    spi_flash_testutils_transaction_width_mode_t width_mode) {
  switch (width_mode) {
    case kTransactionWidthMode111:
      return kDifSpiHostWidthStandard;
    case kTransactionWidthMode112:
      return kDifSpiHostWidthDual;
    case kTransactionWidthMode122:
      return kDifSpiHostWidthDual;
    case kTransactionWidthMode222:
      return kDifSpiHostWidthDual;
    default:
      return kDifSpiHostWidthQuad;
  }
};

#endif  // OPENTITAN_SW_DEVICE_LIB_TESTING_SPI_FLASH_TESTUTILS_H_
