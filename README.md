# Sunburst Chip

**Sunburst Chip** is an open-source microcontroller chip design based around the CHERI-enabled [CHERIoT Ibex](https://github.com/microsoft/CherIoT-ibex) RISC-V core.

This repository hosts the logical design, verification environment, and associated bare-metal test software for Sunburst Chip.
It has been put together by [lowRISC C.I.C.](https://lowrisc.org/)

Sunburst Chip is part of the [Sunburst Project](https://www.sunburst-project.org) funded by [UKRI](https://www.ukri.org/) / [DSbD](https://www.dsbd.tech/) under grant number 107540.

## Overview

Sunburst Chip combines the CHERIoT Ibex core with a useful selection of peripherals (amongst other bits) from the open-source [OpenTitan](https://github.com/lowRISC/opentitan) project, along with some bits from the open-source [Sonata](https://github.com/lowRISC/sonata-system) project.
The [OpenTitan Documentation](https://opentitan.org/book) is a good reference for these peripherals.
They have been imported and patched using a vendoring process defined by files in the vendor sub-directory and enacted by [vendor.py](util/vendor.py).
Note when reading OpenTitan documentation that some OpenTitan-specific features such as alerts and integrity generation have been stripped out for Sunburst Chip using the vendoring patch mechanism.

Much of the verification environment has also been ported from OpenTitan, including top-level (whole-system) and block-level (components in isolation) tests, with some of the complexity stripped out.
The top-level tests are the more interesting for Sunburst Chip, as the blocks themselves are relatively unchanged from their OpenTitan counterparts compared with the wider system.
These top-level tests are mostly integration-focused, ensuring that system-level connections and interactions work as intended.
More comprehensive testing of each block is left to block-level DV, where it is easier and faster.

### Tops

There are three methods of exercising the design as a whole:

- Simulation using **Xcelium** - for Design Verification (DV) testing using a UVM environment.
- Simulation using **Verilator** - for fast and free functional testing.
- (Coming soon) **FPGA** instantiation using a **Sonata XL** board - for physical testing.

These each use a different top-level module.
Each top-level instantiates the common system (or a module that does), but connects it to a different support environment.

![A diagram showing how tb instantiates top_chip_asic which instantiates top_chip_system, whereas top_chip_verilator and top_chip_sonata_xl instantiate top_chip_system directly](sc-tops.svg)

The **Xcelium DV testbench** [*tb.sv*](hw/top_chip/dv/tb/tb.sv) is the only one to instantiate the ASIC-style [*top_chip_asic.sv*](hw/top_chip/rtl/top_chip_asic.sv) which itself instantiates the common system.
The **Verilator testbench** is light-weight by comparison, lacking UVM environment and using simpler connections to the system, but keeping some interfaces for test-status and logging output.
The **Sonata XL top-level** instantiates FPGA clocking primitives and maps the limited ports of the design to the many available on the board.

### Top-level DV Environment

Full DV simulation of the system is the more complicated of the execution options.
There are many components involved and many different interfaces between the system under test and the surrounding DV environment.
Tests involve coordination between the embedded software running in the core and the UVM virtual sequence (vseq) orchestrating the wider DV environment.
Some tests, usually those involving external I/O, use custom vseq's to randomise, configure, load, stimulate, check, and terminate.
Other tests manage with only the base vseq to load the test-specific software into memory and terminate the simulation when signalled by the core.

![A diagram showing how the test software and virtual sequence interact with the system through interfaces in the "tb" testbench](sc-sim-dv-overview.svg)

A typical top-level test with a custom vseq may operate as follows:

- The **vseq** randomises test parameters, initialises SRAM memory with test software, overwrites software parameters with randomised versions, configures relevant UVM agents with test parameters, waits for system reset, enables UVM agent, waits for status updates from the core.
- The **test software** starts running on the simulated core, drives output transactions, checks input transactions driven by UVM agents, reports fail-status to the testbench if a check fails, reports done-status when finished.
- The **vseq** checks transactions received by UVM agents, terminates the simulation early if one of these checks fails or fail-status is reported by test software, or terminates the simulation normally if done-status is reported and all checks complete.

Top-level tests are defined in [*top_chip_sim_cfg.hjson*](hw/top_chip/dv/top_chip_sim_cfg.hjson).
Each test is primarily defined as a combination of a test program and a vseq.
Optionally, additional plusarg parameters can be specified.
These tests can also be grouped together into regression sets for easy access.

### Key TODOs

Some parts of Sunburst Chip are currently using temporary workarounds that must be removed/replaced before any tapeout.
Key pre-tapeout actions include (but are not be limited to):

- Implement a true random number generator
  - Currently generate pseudo-random numbers in `dif_rv_core_ibex_read_rnd_data`.
  - Possibly want to replicate the interface in [OpenTitan `rv_core_ibex`](https://opentitan.org/book/hw/ip/rv_core_ibex/doc/registers.html#rnd_data) for software compatibility.

## Dependencies

[FuseSoC](https://github.com/olofk/fusesoc) is used to handle hardware related build tasks.
It can build [Verilator](https://verilator.org/) simulations directly and is used by the [DVsim](https://opentitan.org/book/util/dvsim) tool to generate file lists that DVsim uses to build simulations.
We use a [lowRISC specific fork of FuseSoC](https://github.com/lowRISC/fusesoc/tree/ot-dev) (which was created to handle primitive generation in the early days of OpenTitan).
DVsim itself also has various Python dependencies.
Pip can be used with the `python-requirements.txt` file to install FuseSoC and the DVsim dependencies.
The version in this repository is just a copy of the OpenTitan file, so likely contains extra dependencies that aren't required.
You may wish to install the dependencies in a virtual environment to isolate them from the rest of your system.
Python 3.9 or higher is required.

Some packages that you'll need to install to set up the Python environment:

- libxml2-dev
- libxslt-dev
- Cargo, which you can install using [rustup](https://rustup.rs/)

Python environment setup:
```sh
python3 -m venv ./sunburst-py-venv
source ./sunburst-py-venv/bin/activate
pip3 install -r ./python-requirements.txt
```

It is strongly recommended you build Verilator from source as packaged versions are often very out of date.
Verilator v5.026 was used when writing this README.
Instructions to do this can be found in the [Verilator documentation](https://verilator.org/guide/latest/install.html).

## Test software

Test software is built **by the user** using CMake and [CHERIoT LLVM](https://github.com/CHERIoT-Platform/llvm-project).
It is **not automatically built** as part of running a simulation or building an FPGA bitstream.

There are currently two Sunburst Chip software ecosystems in this repository:

- *sw/* - ported OpenTitan top-level bare-metal test software.
- *scratch_sw/* - historical bare-metal software.

Future DV work is expected to be done in *sw/*, now that it exists.

### Build *sw/*

All *sw/* ported OpenTitan test software can be built using the following commands:

```sh
# -- Build *sw/* software --
# Run from the project root directory.
# NOTE: A suitable CHERIoT toolchain must be available on your path
#       or specified by the `CHERIOT_LLVM_BIN` environment variable.

# export CHERIOT_LLVM_BIN=/path/to/cheriot-llvm/bin
cmake -B sw/device/build -S sw/device  # once
cmake --build sw/device/build  # always
```

### Build *scratch_sw/*

All *scratch_sw/* test software can be built using the following commands:

```sh
# -- Build *scratch_sw/* software --
# Run from the project root directory.
# NOTE: A suitable CHERIoT toolchain must be available on your path
#       or specified by the `CHERIOT_LLVM_BIN` environment variable.

# export CHERIOT_LLVM_BIN=/path/to/cheriot-llvm/bin
cmake -B scratch_sw/bare_metal/build -S scratch_sw/bare_metal  # once
cmake --build scratch_sw/bare_metal/build  # always
```

### Run

See the sections on top-level simulation for information on how to run these test programs as part of a simulation.

Please note that presently the following USBDEV tests work only in Xcelium simulation and do not work with Verilator; this is under investigation.

```text
usbdev_config_host_test
usbdev_test
usbdev_stream_test
usbdev_mixed_test
usbdev_iso_test
```

## Top-level Xcelium simulation

The primary simulator for running top-level tests is Xcelium, via DVsim.

Note that DVsim does not build the test software for you.
It must have already been compiled using the instructions in the [Test software section](#Test-software) before you call DVsim.

### Build & run

The **`smoke` regression test set** (defined in top_chip_sim_cfg.hjson) can be built and run under Xcellium using the following commands:

```sh
# -- Build and run top-level `smoke` regression set using Xcelium --
# Run from the project root directory.
# NOTE: test software must have already been built beforehand and Xcelium
#       must be available on your path.
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/top_chip/dv/top_chip_sim_cfg.hjson -i smoke
```

**Single tests** (also defined in top_chip_sim_cfg.hjson) can be specified in the same way, such as `usbdev_vbus_test`:

```sh
# -- Build and run the `usbdev_vbus_test` top-level test using Xcelium --
# Run from the project root directory.
# NOTE: test software must have already been built beforehand and Xcelium
#       must be available on your path.
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/top_chip/dv/top_chip_sim_cfg.hjson -i usbdev_vbus_test
```

You can **increase the number of times each test is run** using the `-rx <multiplier>` option.
For example, `... -i smoke -rx 10` to run the `smoke` regression set 10 times.

**All tests** can be built and run simply by specifying `all` instead of a regression set or test name:

```sh
# -- Build and run all top-level tests 10 times using Xcelium --
# Run from the project root directory.
# NOTE: test software must have already been built beforehand and Xcelium
#       must be available on your path.
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/top_chip/dv/top_chip_sim_cfg.hjson -i all -rx 10
```

### Output

DVSim provides an overall regression report at the end, which should report the number of tests that passed and failed.

Artefacts from a test run are put into a sub-directory of the *scratch/* directory.
The exact location will follow the format `scratch/top_chip_asic.sim.xcelium/<branch>/<seed>.<test>/latest/`.
Typical artefacts include:

- *trace_core_00000000.log* - The instruction trace.
- *uart0.log* - The output from uart0.
- *run.log* - The log from the simulation run.
- *waves.shm* - The wave trace (only present when DVsim is run with `-w shm`).


Additional output, useful for debugging, can be generated using some optional arguments:

- For **waveform output**, add `-w shm` (SHM file) or `-w vcd` (uncompressed VCD file).
- For **increased UVM verbosity**, add `-v m` (medium) or `-v h` (high).

## Top-level Verilator simulation

Verilator can run top-level tests or other programs that do not require UVM agents, other parts of the full DV testbench (e.g. usbdev tests), or 4-state (0/1/Z/X) simulation.
It runs faster than Xcelium and does not require a paid licence, making it handy for developing the core digital logic of the system.
However, it does have limitations, particularly when it comes to external interfaces.
It lacks UVM, and as such has to run without most of the DV environment required to check and drive many of the external interfaces.
It also only supports 2-state simulation (0/1), lacking the high-impedance (Z) and undefined (X) states, and so cannot simulate the more complex electrical behaviour seen on multi-controller external buses (e.g. I^2C).

Note that FuseSoC (the tool used below to build Verilator) does not build the test software for you.
It must have already been compiled using the instructions in the [Test software section](#Test-software) before you run the simulation.

### Build

A Verilator simulator executable for Sunburst Chip can be built using the following commands:

```sh
# -- Build Verilator simulator from *top_chip_verilator.sv* --
# Run from the project root directory.
NUM_CORES=4
fusesoc --cores-root=. run \
  --target=sim --tool=verilator --setup \
  --build lowrisc:sunburst:top_chip_verilator \
  --verilator_options="-j $NUM_CORES" \
  --make_options="-j $NUM_CORES"
```

To enable instruction tracing add `+define+RVFI` to the `verilator_options` switch in the command above.

### Run

Programs can be run with the resulting executable using the following command:

```sh
# -- Run `usbdev_vbus_test` using a Verilator simulator we built earlier --
# Run from the project root directory.
# NOTE: test software must have already been built beforehand.
build/lowrisc_sunburst_top_chip_verilator_0/sim-verilator/Vtop_chip_verilator \
  -E ./sw/device/build/tests/usbdev_vbus_test
```

### Output

Unlike DVsim, the simulation output files end up in the directory the executable was called from.

For most test programs, you should see something in the resulting *uart0.log* or *usb0.log* files.
The simulation should terminate itself with the final output looking something like this:

```log
- ../src/lowrisc_sunburst_top_chip_verilator_0/top_chip_verilator.sv:217: Verilog $finish
Received $finish() from Verilog, shutting down simulation.

Simulation statistics
=====================
Executed cycles:  154539
Wallclock time:   0.789 s
Simulation speed: 195867 cycles/s (195.867 kHz)
```

If instruction tracing was enabled *trace_core_00000000.log* will contain a full instruction trace.

Add the `-t` switch to output a wave trace file in *sim.fst* which can be viewed with [gtkwave](https://gtkwave.sourceforge.net/).
Note, running with wave tracing enabled can significantly increase the runtime of the simulation.
You can use the provided save file to see the GPIO output and the PC of the processor:

```sh
# -- View waves --
# Run from the project root directory.
gtkwave util/gpio_and_pc.gtkw
```

## Block-level Xcelium simulation

Block-level DV for all of the IP blocks vendored from OpenTitan can also be run using DVsim.
Many blocks default to running using VCS, but they can be forced to use Xcelium using the `-t xcelium` option.
The full regression (called nightly) for each of the blocks can be run using Xcelium with these commands:

```sh
# -- Build and run block-level tests using Xcelium --
# Run all the below from the project root directory.
# Run aon_timer regression
hw/vendor/lowrisc_ip/util/dvsim/dvsim.py hw/vendor/lowrisc_ip/ip/aon_timer/dv/aon_timer_sim_cfg.hjson -i nightly --max-parallel 32 --tool xcelium
# Run gpio regression
hw/vendor/lowrisc_ip/util/dvsim/dvsim.py hw/vendor/lowrisc_ip/ip/gpio/dv/gpio_sim_cfg.hjson -i nightly --max-parallel 32 --tool xcelium
# Run i2c smoke regression
# Note: The full I2C regression is experiencing timeouts which is being tracked here: https://github.com/lowRISC/sunburst-chip/issues/42
# The command below just executes the smoke test for now.
hw/vendor/lowrisc_ip/util/dvsim/dvsim.py hw/vendor/lowrisc_ip/ip/i2c/dv/i2c_sim_cfg.hjson -i smoke --max-parallel 32 --tool xcelium
# Run pattgen regression
hw/vendor/lowrisc_ip/util/dvsim/dvsim.py hw/vendor/lowrisc_ip/ip/pattgen/dv/pattgen_sim_cfg.hjson -i nightly --max-parallel 32 --tool xcelium
# Run pwm regression
hw/vendor/lowrisc_ip/util/dvsim/dvsim.py hw/vendor/lowrisc_ip_main/ip/pwm/dv/pwm_sim_cfg.hjson -i nightly --max-parallel 32 --tool xcelium
# Run rv_timer regression
hw/vendor/lowrisc_ip/util/dvsim/dvsim.py hw/vendor/lowrisc_ip/ip/rv_timer/dv/rv_timer_sim_cfg.hjson -i nightly --max-parallel 32 --tool xcelium
# Run spi_host regression
hw/vendor/lowrisc_ip/util/dvsim/dvsim.py hw/vendor/lowrisc_ip/ip/spi_host/dv/spi_host_sim_cfg.hjson -i nightly --max-parallel 32 --tool xcelium
# Run uart regression
hw/vendor/lowrisc_ip/util/dvsim/dvsim.py hw/vendor/lowrisc_ip/ip/uart/dv/uart_sim_cfg.hjson -i nightly --max-parallel 32 --tool xcelium
# Run usbdev regression
hw/vendor/lowrisc_ip/util/dvsim/dvsim.py hw/vendor/lowrisc_ip/ip/usbdev/dv/usbdev_sim_cfg.hjson -i nightly --max-parallel 32 --tool xcelium
```

Like the top-level DVsim tests, artefacts end up under *scratch/* and additional output can be generated using the `-w shm` and `-v h` options.

## Sonata XL board

Sonata XL is an FPGA-based development board developed by [NewAE Technology Inc.](https://www.newae.com/).
It is a larger sibling of the more common Sonata development board and is intended for emulating sunburst-chip.
It features an upgraded FPGA and the addition of two 80-pin board-to-board connectors.
The FPGA in question is an AMD Artix(tm) 7 **XC7A200T**.
This features over four-times the logic cells and memory, and twice the I/O of the XC7A50T used on the Sonata board.

Sonata XL is an open-source design, like the Sonata board it is based on.
As of writing, the design files (incl. schematic printout) for Sonata XL can be found in the [`sonata-a200` sub-directory of the sonata-pcb repository](https://github.com/newaetech/sonata-pcb/tree/main/sonata-a200).
Unlike the Sonata board, Sonata XL boards are not generally available for purchase.

The top-level module for Sonata XL builds is *top_chip_sonata_xl.sv*.
This modules instantiates the common system, provides a starting partial mapping of the system I/O to some of the FPGA I/O and associated onboard headers/devices, and uses FPGA primitives for basic clock and reset generation.

Unfortunately, the core clock had to be significantly reduced in order to get a reliably timing-clean bitstream build.
This clock frequency may be able to be increased with some tweaking of the build and improvements to timing-critical logic paths.
Happily, the other clocks (`peri`pheral, `usb`, `aon`) are able to be run at their intended frequencies, avoiding baud rate issues and the like on the external interfaces.

Note that FuseSoC (the tool used below to build an FPGA bitstream) does not build the test software for you.
It must have already been compiled using the instructions in the [Test software section](#Test-software) before you run the simulation.

At present, **the only way to load software is to build it into the bitstream**.
This is controlled with the `--SRAMInitFile` argument to `fusesoc`.
Sunburst Chip currently lacks a debug module for loading a program into SRAM while live as Sonata does.
It also (for now) lacks a bootloader, and so cannot load a program from onboard Flash.

### Dependencies

FPGA bitstream builds require AMD Vivado to be installed.
This is free for the XC7A200T device used on Sonata XL.
Please find it on AMD's website.

The remaining utilities are optional:

- openFPGALoader: install with `sudo apt install openfpgaloader` then setup udev USB rules as described in the (FPGA development documentation for sonata-system)[https://github.com/lowRISC/sonata-system/blob/main/doc/dev/fpga-development.md].
- uf2conv: install with `python3 -m pip install git+https://github.com/makerdiary/uf2utils.git`.
- picocom: install with `sudo apt install picocom`.

### Build

A Sunburst Chip bitstream for Sonata XL can be built using FuseSoC and Vivado using the following command:

```sh
# -- Build Sonata XL FPGA bitstream from *top_chip_sonata_xl.sv* --
# Run from the project root directory.
# NOTE: Vivado must be available on your path.
fusesoc --cores-root=. run --target=synth --setup --build lowrisc:sunburst:top_chip_sonata_xl \
  --SRAMInitFile=$PWD/scratch_sw/bare_metal/build/checks/chip_check.vmem
```

### Load

There are three ways to load a bitstream onto the FPGA of Sonata XL.

- Over USB to the onboard FTDI USB-to-JTAG interface.
  - Easy, fast, but will have to load again after a power-cycle of the board.
  - Good for active development of the design.
- Using an AMD/Xilinx JTAG programmer of your own.
  - No additional dependencies (use Vivado), but also will have to load again after a power cycle.
  - Note: DIP switches on the underside of the board must be changed in order to use the JTAG headers.
- Saving a bitstream converted to UF2 format to the onboard flash via the onboard RP2040.
  - More time consuming, but will be retained across power-cycles.
  - Good for development of the software or for demos.
  - Can store up to three bitstreams, selectable using the onboard "Bitstream" switch.

A bitstream can be directly loaded over USB using the following command:

```sh
# -- Program the Sonata XL FPGA with a bitstream we built earlier --
# Run from the project root directory.
# NOTE: host must be connected to Sonata XL via the "Main USB" connector and
#       on Linux the required USB rules must have been applied.
openFPGALoader -c ft4232 build/lowrisc_sunburst_top_chip_sonata_xl_0/synth-vivado/lowrisc_sunburst_top_chip_sonata_xl_0.bit
```

A standalone AMD/Xilinx JTAG programmer may be able to be used from Vivado or using a command similar to that above.

Non-volatile loading using Sonata firmware on the RP2040 can be done using the following commands:

```sh
# -- Load onboard flash with a bitstream we built earlier --
# Run from the project root directory.
# NOTE: host must be connected to Sonata XL via the "Main USB" connector and
#       the onboard RP2040 must be running Sonata firmware.

# Convert bitstream to UF2 format for the RP2040 firmware.
uf2conv -b 0x00000000 -f 0x6ce29e6b build/lowrisc_sunburst_top_chip_sonata_xl_0/synth-vivado/lowrisc_sunburst_top_chip_sonata_xl_0.bit -co sonata-xl.bit.slot1.uf2
uf2conv -b 0x10000000 -f 0x6ce29e6b build/lowrisc_sunburst_top_chip_sonata_xl_0/synth-vivado/lowrisc_sunburst_top_chip_sonata_xl_0.bit -co sonata-xl.bit.slot2.uf2
uf2conv -b 0x20000000 -f 0x6ce29e6b build/lowrisc_sunburst_top_chip_sonata_xl_0/synth-vivado/lowrisc_sunburst_top_chip_sonata_xl_0.bit -co sonata-xl.bit.slot3.uf2

# Load into slot1 of the connected Sonata XL board.
# This should take half a minute or so.
# If you do not see a SONATA drive, you may need to update the RP2040 firmware
# (see https://github.com/lowRISC/sonata-system/releases).
cp sonata-xl.bit.slot1.uf2 "/media/$USER/SONATA/"
```

### Output

UART logging output can be received from the FTDI UART-to-USB interface.
This typically appears at `/dev/ttyUSB2`.
The default baud rate for test software is 1.5 Mbaud.

An example terminal utility is `picocom`, which can be used with the following command:

```sh
# -- Connect to Sonata XL UART --
# NOTE: host must be connected to Sonata XL via the "Main USB" connector.
picocom /dev/ttyUSB2 -b 1500000 --imap lfcrlf
# To quit: CTRL-a then CTRL-x
```

## Vendoring

Newer versions of vendored code, or new patches, can be vendored in using the following command:

```sh
# -- Apply patches to vendored OpenTitan IP --
# Run from the project root directory.
# Currently vendored revision (5ad69...) found in lowrisc_ip.lock.hjson
util/vendor.py --update -Dupstream.rev=5ad6963fa71a63b4cc7817fb3bae5052c796bfc1 --verbose hw/vendor/lowrisc_ip_earlgrey_v1.vendor.hjson
```

## Licence

Unless otherwise noted, everything in the repository is covered by the [Apache License](https://www.apache.org/licenses/LICENSE-2.0.html), Version 2.0. See the [LICENSE](https://github.com/lowRISC/sonata-system/blob/main/LICENSE) file for more information on licensing.
