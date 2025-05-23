#!/bin/bash

# Apply vendoring
util/vendor.py hw/vendor/cheriot-debug-module.vendor.hjson
util/vendor.py hw/vendor/lowrisc_ibex.vendor.hjson
util/vendor.py hw/vendor/lowrisc_ip_earlgrey_v1.vendor.hjson
util/vendor.py hw/vendor/lowrisc_ip_main.vendor.hjson
util/vendor.py hw/vendor/lowrisc_sonata.vendor.hjson

# Check if vendoring applied correctly without any diff
if [ -z "$(git status --porcelain)" ]; then
  echo "Vendoring applied correctly"
else
  echo "There are some modifications to apply"
  git status --porcelain
  exit 1
fi
