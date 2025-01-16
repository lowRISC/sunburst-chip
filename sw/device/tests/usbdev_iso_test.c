// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// USB Isochronous streaming data test
//
// This test requires interaction with the USB DPI model or a test application
// on the USB host. The test initializes the USB device and configures a set of
// endpoints for data streaming using bulk transfers.
//
// The DPI model mimicks a USB host. After device initialization, it detects
// the assertion of the pullup and first assigns an address to the device.
// For this test it will then repeatedly fetch data via IN requests to
// each stream and propagate that data to the corresponding OUT endpoints.
//
// The data itself is pseudo-randomly generated by the sender and,
// independently, by the receiving code to check that the data has been
// propagated unmodified and without data loss, corruption, replication etc.

#include "sw/device/lib/dif/dif_pinmux.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/runtime/print.h"
#include "sw/device/lib/testing/pinmux_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"
#include "sw/device/lib/testing/usb_testutils.h"
#include "sw/device/lib/testing/usb_testutils_controlep.h"
#include "sw/device/lib/testing/usb_testutils_diags.h"
#include "sw/device/lib/testing/usb_testutils_streams.h"

#include "hw/top_chip/sw/autogen/top_chip.h"  // Generated.

// Number of streams to be tested
//
// Note: because Isochronous streams are guaranteed the requested amount of
// bus bandwidth, the number of concurrent streams that may be supported is
// limited to four if connected through a hub (6 without hub(s)).
#if !defined(NUM_STREAMS) || NUM_STREAMS > 4U
#define NUM_STREAMS 4U
#endif

#define TRANSFER_BYTES_SILICON (4U << 20)
#define TRANSFER_BYTES_FPGA (8U << 16)

// This is appropriate for a Verilator chip simulation with 15 min timeout
#define TRANSFER_BYTES_VERILATOR 0x2400U

// For top-level DV simulation (regression runs, deterministic behavior)
#define TRANSFER_BYTES_DVSIM 0x800U

/**
 * Configuration values for USB.
 */
static const uint8_t config_descriptors[] = {
    USB_CFG_DSCR_HEAD(USB_CFG_DSCR_LEN + NUM_STREAMS * (USB_INTERFACE_DSCR_LEN +
                                                        2 * USB_EP_DSCR_LEN),
                      NUM_STREAMS),

    // Up to 11 interfaces and NUM_STREAMS in the descriptor head specifies how
    // many of the interfaces will be declared to the host
    VEND_INTERFACE_DSCR(0, 2, 0x50, 1),
    USB_EP_DSCR(0, 1U, kUsbTransferTypeIsochronous, USBDEV_MAX_PACKET_SIZE, 1),
    USB_EP_DSCR(1, 1U, kUsbTransferTypeIsochronous, USBDEV_MAX_PACKET_SIZE, 1),

    VEND_INTERFACE_DSCR(1, 2, 0x50, 1),
    USB_EP_DSCR(0, 2U, kUsbTransferTypeIsochronous, USBDEV_MAX_PACKET_SIZE, 1),
    USB_EP_DSCR(1, 2U, kUsbTransferTypeIsochronous, USBDEV_MAX_PACKET_SIZE, 1),

    VEND_INTERFACE_DSCR(2, 2, 0x50, 1),
    USB_EP_DSCR(0, 3U, kUsbTransferTypeIsochronous, USBDEV_MAX_PACKET_SIZE, 1),
    USB_EP_DSCR(1, 3U, kUsbTransferTypeIsochronous, USBDEV_MAX_PACKET_SIZE, 1),

    VEND_INTERFACE_DSCR(3, 2, 0x50, 1),
    USB_EP_DSCR(0, 4U, kUsbTransferTypeIsochronous, USBDEV_MAX_PACKET_SIZE, 1),
    USB_EP_DSCR(1, 4U, kUsbTransferTypeIsochronous, USBDEV_MAX_PACKET_SIZE, 1),

    VEND_INTERFACE_DSCR(4, 2, 0x50, 1),
    USB_EP_DSCR(0, 5U, kUsbTransferTypeIsochronous, USBDEV_MAX_PACKET_SIZE, 1),
    USB_EP_DSCR(1, 5U, kUsbTransferTypeIsochronous, USBDEV_MAX_PACKET_SIZE, 1),

    VEND_INTERFACE_DSCR(5, 2, 0x50, 1),
    USB_EP_DSCR(0, 6U, kUsbTransferTypeIsochronous, USBDEV_MAX_PACKET_SIZE, 1),
    USB_EP_DSCR(1, 6U, kUsbTransferTypeIsochronous, USBDEV_MAX_PACKET_SIZE, 1),
};

/**
 * Test flags specifying the nature and direction of the data stream(s)
 */
static usbdev_stream_flags_t test_flags;

/**
 * Test descriptor
 */
static uint8_t test_descriptor[USB_TESTUTILS_TEST_DSCR_LEN];

/**
 * USB device context types.
 */
static usb_testutils_ctx_t usbdev;
static usb_testutils_controlep_ctx_t usbdev_control;

/**
 * Pinmux handle
 */
static dif_pinmux_t pinmux;

/**
 * State information for streaming data test
 */
static usb_testutils_streams_ctx_t stream_test;

/**
 * Specify whether to perform verbose logging, for visibility
 *   (Note that this substantially alters the timing of interactions with the
 * DPI model and will increase the simulation time)
 */
static const bool kVerbose = false;

/*
 * These switches may be modified manually to experimentally measure the
 * performance of IN traffic in isolation, or IN/OUT together etc.
 *
 * Are we sending data?
 */
static const bool kSending = true;

/**
 * Are we generating a valid byte sequence?
 */
static const bool kGenerating = true;

/**
 * Retrying is meaningless for this test since we have only Isochronous streams.
 */
static const bool kRetrying = false;

/**
 * Are we expecting to receive data?
 */
static const bool kRecving = true;

/**
 * Send only maximal length packets?
 * (important for performance measurements on the USB, but obviously undesirable
 *  for testing reliability/function)
 */
static const bool kMaxPackets = false;

/**
 * Number of streams to be created
 */
static const unsigned nstreams = NUM_STREAMS;

OTTF_DEFINE_TEST_CONFIG();

bool test_main(void) {
  // Context state for streaming test
  usb_testutils_streams_ctx_t *ctx = &stream_test;

  LOG_INFO("Running USBDEV ISO Test");

  // Check we can support the requested number of streams
  CHECK(nstreams && nstreams < USBDEV_NUM_ENDPOINTS);

  // Decide upon the number of bytes to be transferred for the entire test
  uint32_t transfer_bytes = TRANSFER_BYTES_FPGA;
  switch (kDeviceType) {
    case kDeviceSimVerilator:
      transfer_bytes = TRANSFER_BYTES_VERILATOR;
      break;
    case kDeviceSimDV:
      transfer_bytes = TRANSFER_BYTES_DVSIM;
      break;
    case kDeviceSilicon:
      transfer_bytes = TRANSFER_BYTES_SILICON;
      break;
    case kDeviceFpgaCw340:
      break;
    default:
      CHECK(kDeviceType == kDeviceFpgaCw310);
      break;
  }
  transfer_bytes = (transfer_bytes + nstreams - 1) / nstreams;
  LOG_INFO(" - %u stream(s), 0x%x bytes each", nstreams, transfer_bytes);

  CHECK_DIF_OK(dif_pinmux_init(
      mmio_region_from_addr(TOP_CHIP_PINMUX_AON_BASE_ADDR), &pinmux));
  pinmux_testutils_init(&pinmux);
  CHECK_DIF_OK(dif_pinmux_input_select(
      &pinmux, kTopChipPinmuxPeripheralInUsbdevSense,
      kTopChipPinmuxInselIoc7));

  // Construct the test/stream flags to be used
  test_flags = (kSending ? kUsbdevStreamFlagRetrieve : 0U) |
               (kGenerating ? kUsbdevStreamFlagCheck : 0U) |
               (kRetrying ? kUsbdevStreamFlagRetry : 0U) |
               (kRecving ? kUsbdevStreamFlagSend : 0U) |
               // Note: the 'max packets' test flag is not required by the DPI
               (kMaxPackets ? kUsbdevStreamFlagMaxPackets : 0U);

  // Initialize the test descriptor
  // Note: the 'max packets' test flag is not required by the DPI model
  const uint8_t desc[] = {USB_TESTUTILS_TEST_DSCR(
      kUsbTestNumberIso, NUM_STREAMS | (uint8_t)test_flags, 0, 0, 0)};
  memcpy(test_descriptor, desc, sizeof(test_descriptor));

  // Remember context state for usb_testutils context
  ctx->usbdev = &usbdev;

  // Call `usbdev_init` here so that DPI will not start until the
  // simulation has finished all of the printing, which takes a while
  // if `--trace` was passed in.
  CHECK_STATUS_OK(usb_testutils_init(ctx->usbdev, /*pinflip=*/false,
                                     /*en_diff_rcvr=*/true,
                                     /*tx_use_d_se0=*/false));
  CHECK_STATUS_OK(usb_testutils_controlep_init(
      &usbdev_control, ctx->usbdev, 0, config_descriptors,
      sizeof(config_descriptors), test_descriptor, sizeof(test_descriptor)));

  // Proceed only when the device has been configured; this allows host-side
  // software to establish communication.
  CHECK_STATUS_OK(
      usb_testutils_controlep_config_wait(&usbdev_control, &usbdev));

  // Describe the transfer type of each stream;
  // Note: make all of the streams Isochronous streams for now, but later we
  // shall want to test a mix of different transfer types concurrently.
  usb_testutils_transfer_type_t xfr_types[USBUTILS_STREAMS_MAX];
  for (unsigned s = 0U; s < nstreams; s++) {
    xfr_types[s] = kUsbTransferTypeIsochronous;
  }

  // Initialise the state of the streams
  CHECK_STATUS_OK(usb_testutils_streams_init(
      ctx, nstreams, xfr_types, transfer_bytes, test_flags, kVerbose));

  USBUTILS_USER_PROMPT("Start host-side streaming software");

  // Streaming loop; most of the work is done by the usb_testutils_streams base
  //   code and we don't need to specialize its behavior for this test.
  bool done = false;
  do {
    CHECK_STATUS_OK(usb_testutils_streams_service(ctx));

    // See whether any streams still have more work to do
    done = usb_testutils_streams_completed(ctx);
  } while (!done);

  // Determine the total counts of bytes sent and received
  uint32_t tx_bytes = 0U;
  uint32_t rx_bytes = 0U;
  for (uint8_t s = 0U; s < nstreams; s++) {
    uint32_t tx, rx;
    CHECK_STATUS_OK(usb_testutils_stream_status(ctx, s, NULL, &tx, &rx));
    tx_bytes += tx;
    rx_bytes += rx;
  }

  LOG_INFO("USB sent 0x%x byte(s), received and checked 0x%x byte(s)", tx_bytes,
           rx_bytes);

  // Note: since Isochronous streams are susceptible to packet loss we can only
  // perform a lower bounds check on the transmitted and received byte counts.
  if (kSending) {
    CHECK(tx_bytes >= nstreams * transfer_bytes,
          "Unexpected count of byte(s) sent to USB host");
  }
  if (kRecving) {
    CHECK(rx_bytes >= nstreams * transfer_bytes,
          "Unexpected count of byte(s) received from USB host");
  }

  return true;
}
