#!/bin/bash
# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

rm -r hw/top_chip/ip_autogen/rv_plic/
hw/vendor/lowrisc_ip/util/ipgen.py generate \
  -C hw/vendor/lowrisc_ip/ip_templates/rv_plic/ \
  -c hw/top_chip/data/rv_plic_cfg.hjson -o hw/top_chip/ip_autogen/rv_plic
rm -r hw/top_chip/ip_autogen/rv_plic/doc
rm -r hw/top_chip/ip_autogen/rv_plic/fpv
rm hw/top_chip/ip_autogen/rv_plic/README.md
