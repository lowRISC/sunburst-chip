// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class usb20_agent_cfg extends dv_base_agent_cfg;

  // interface handle used by driver, monitor & the sequencer, via cfg handle
  virtual usb20_block_if bif;
  virtual clk_rst_if clk_rst_if_i;

  `uvm_object_utils_begin(usb20_agent_cfg)
  `uvm_object_utils_end

  `uvm_object_new

  // Exchange the DP/DN signals when driving/monitoring the USB.
  bit pinflip = 1'b0;
  // Use the D/SE0 TX outputs from the DUT rather than DP/DN.
  bit tx_use_d_se0 = 1'b0;

  // If this is set then the driver will not perform bitstuffing on the supplied
  // data, so if the caller supplies a sequence of more than six '1' bits,
  // a bitstuffing violation will occur.
  bit disable_bitstuffing = 1'b0;
  // This flag serves to evaluate the device's functionality,
  // particularly regarding the recognition of a single SE0 bit as an end-of-packet,
  // which necessitates two successive bits otherwise. Once set, it is accompanied by
  // its respective test sequence, followed by the transmission of a single-bit SE0 as EOP.
  bit single_bit_SE0 = 1'b0;

  // --------------------------------------------------------------------------
  // Configuration switches that are RTL-version dependent.
  //
  // - these switches are introduced to limit the injection of bad traffic to
  //   that from which the DUT may presently recover. This bad traffic has
  //   never been observed to occur and clearly should not be generated by
  //   USB host controllers, and as a risk mitigation, the inclusion of more
  //   robust recovery logic as been deferred. 2024/07/24.
  // --------------------------------------------------------------------------

  // RTL has limited ability to recover from an invalid SYNC signal at the start of the packet.
  bit rtl_limited_sync_recovery = 1'b1;

  // RTL has limited ability to detect bit stuffing violations; specifically it does not detect a
  // bit stuffing violation that occurs right at the end of the packet.
  bit rtl_limited_bitstuff_detection = 1'b1;

  // RTL has limited ability to recover from bit stuffing violations; subsequent bits within the
  // packet may be misinterpreted as another SYNC signal.
  bit rtl_limited_bitstuff_recovery = 1'b1;

  // RTL does not recover from missing host handshake in response to an IN DATA packet.
  bit rtl_must_have_host_handshake = 1'b1;

  // RTL does not deassert the `sending` bit of `configin_x` until the host has successfully
  // ACKnowledged an IN packet or it has been marked as `pend` by the hardware.
  bit rtl_sending_clear_requires_ack = 1'b1;

  // RTL will report CRC errors even if the PID is truncated, for DATA packets.
  bit rtl_limited_crc_checking = 1'b1;

  // --------------------------------------------------------------------------

endclass
