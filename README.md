# Sunburst Chip

**Sunburst Chip** is an open-source silicon microcontroller chip design based around the CHERI-enabled [CHERIoT Ibex](https://github.com/microsoft/CherIoT-ibex) RISC-V core.

This repository hosts the logical design, verification environment, and associated bare-metal test software for Sunburst Chip.

Sonata is part of the [Sunburst Project](https://www.sunburst-project.org) funded by [UKRI](https://www.ukri.org/) / [DSbD](https://www.dsbd.tech/) under grant number 107540.

## Overview

Sunburst Chip combines the CHERIoT Ibex core with a useful selection of peripherals (amongst other bits) from the open-source [OpenTitan](https://github.com/lowRISC/opentitan) project, along with some bits from the open-source [Sonata](https://github.com/lowRISC/sonata-system) project.
The [OpenTitan Documentation](https://opentitan.org/book) is a good reference for these peripherals.
They have been imported and patched using a vendoring process defined by files in the vendor sub-directory and enacted by [vendor.py](util/vendor.py).
Note when reading OpenTitan documentation that some OpenTitan-specific features such as alerts and integrity generation have been stripped out for Sunburst Chip using the vendoring patch mechanism.

Much of the verification environment has also been ported from OpenTitan, including top-level (whole-system) and block-level (components in isolation) tests, with some of the complexity stripped out.
The top-level tests are the more interesting for Sunburst Chip, as the blocks themselves are relatively unchanged from their OpenTitan counterparts compared the the wider system.
These top-level tests are mostly integration-focused, ensuring that system-level connections and interactions work as intended.
More comprehensive testing of each block is left to block-level DV, where it is easier and faster.

### Tops

There are three methods of exercising the design as a whole:

- Simulation using **Xcelium** - for Design Verification (DV) testing using a UVM environment.
- Simulation using **Verilator** - for fast and free functional testing.
- (Coming soon) **FPGA** instantiation using a **Sonata XL** board - for physical testing.

These each use a different wrapper around the common system.

![A diagram showing how tb wraps top_chip_asic which wraps top_chip_system, whereas top_chip_verilator and top_chip_sonata_xl wrap top_chip_system directly](sc-tops.svg)

The **Xcelium DV testbench** [*tb.sv*](hw/top_chip/dv/tb/tb.sv) is the only one to instantiate the system using the ASIC-style wrapper [*top_chip_asic.sv*](hw/top_chip/rtl/top_chip_asic.sv).
The **Verilator testbench** is light-weight by comparison, lacking UVM environment and using simpler connections to the system, but keeping some interfaces for test-status and logging output.
The **Sonata XL top-level** instantiates FPGA clocking primitives and maps the limited ports of the design to the many available on the board.

### Top-level DV Environment

Full DV simulation of the system is the more complicated of the execution options.
There are many components involved and many different interfaces between the system under test and the surrounding DV environment.
Tests involve coordination between the embedded software running in the core and the UVM virtual sequence (vseq) orchestrating the wider DV environment.
Some tests, usually those involving external I/O, use custom vseq to randomise, configure, load, stimulate, check, and terminate.
Other tests manage with only the base vseq to load the test-specific software into memory and terminate the simulation when signaled by the core.

![A diagram showing how the test software and virtual sequence interact with the system through interfaces in the "tb" testbench](sc-sim-dv-overview.svg)

A typical top-level test with a custom vseq may operate as follows:

- The **vseq** randomises test parameters, initialises SRAM memory with test software, overwrites software parameters with randomised versions, configures relevant UVM agents with test parameters, waits for system reset, enables UVM agent, waits for status updates from the core.
- The **test software** starts running on the simulated core, drives output transactions, checks input transactions driven by UVM agents, reports fail-status to the testbench if a check fails, reports done-status when finished.
- The **vseq** checks transactions received by UVM agents, terminates the simulation early if one of these checks fails or fail-status is reported by test software, or terminates the simulation normally if done-status is reported and all checks complete.

## Dependencies

[FuseSoC](https://github.com/olofk/fusesoc) is used to handle hardware related build tasks.
It can build Verilator simulations directly and is used by the [DVsim](https://opentitan.org/book/util/dvsim/index.html) tool to generate file lists that DVsim uses to build simulations.
We use a [lowRISC specific fork of FuseSoC](https://github.com/lowRISC/fusesoc/tree/ot-dev) (which was created to handle primitive generation in the early days of OpenTitan).
DVsim itself also has various python dependencies.
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

## Run Verilator simulation

To build a Verilator simulation run:

```sh
NUM_CORES=4
fusesoc --cores-root=. run \
  --target=sim --tool=verilator --setup \
  --build lowrisc:sunburst:top_chip_verilator \
  --verilator_options="-j $NUM_CORES" \
  --make_options="-j $NUM_CORES"
```

*To enable instruction tracing add +define+RVFI to the verilator_options switch in the command above.*

A test program can be built with scratch_sw/ (a suitable CHERIoT toolchain must be available on your path or specified by `CHERIOT_LLVM_BIN`):

```sh
# export CHERIOT_LLVM_BIN=/path/to/cheriot-llvm/bin
cmake -B scratch_sw/bare_metal/build -S scratch_sw/bare_metal
cmake --build scratch_sw/bare_metal/build
```

To run the `chip_check` program this will build run:

```sh
build/lowrisc_sunburst_top_chip_verilator_0/sim-verilator/Vtop_chip_verilator \
  -E ./scratch_sw/bare_metal/build/checks/chip_check
```

You should see a repeated 'Hello from Sonata Chip!' in `uart0.log`.
The simulation should terminate itself with the final output looking something like this:

```
TEST PASSED! Completion signal seen from software
- ../src/lowrisc_sunburst_top_chip_verilator_0/top_chip_verilator.sv:180: Verilog $finish
Received $finish() from Verilog, shutting down simulation.

Simulation statistics
=====================
Executed cycles:  154539
Wallclock time:   0.789 s
Simulation speed: 195867 cycles/s (195.867 kHz)
```

If instruction tracing was enabled `trace_core_00000000.log` will contain a full instruction trace.

Add the `-t` switch to output a wave trace file in `sim.fst` which can be viewed with [gtkwave](https://gtkwave.sourceforge.net/).
Note with wave tracing enabled the simulation is many times slower.
You can use the provided save file to see the GPIO output and the PC of the processor:

```sh
gtkwave util/gpio_and_pc.gtkw
```

## Run Xcelium simulation with dvsim

For now dvsim does not orchestrate any software build.
To run the example smoke test you must have built the `chip_check` program, see the Verilator
instructions above for details on this.
With Xcelium suitably setup in your environment run:

```sh
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/top_chip/dv/top_chip_sim_cfg.hjson
```

This will build and run the Xcelium simulation.
To get a wave trace add `-w shm` to the command.
To increase uvm verbosity to high add `-v h` to the command.

DVSim provides an overall regression report at the end which should report a single 'top_chip_smoke' test as passing.
If you go to `scratch/top_chip_asic.sim.xcelium/main/0.top_chip_smoke/latest` you will find the artifacts from the test run.
These are:

 - `trace_core_00000000.log`: The instruction trace
 - `uart0.log`: The output from uart0
 - `run.log`: The log from the simulation run
 - `waves.shm`: The wave trace (only present when DVsim is run with `-w shm`)

## Run block level DV

Block level DV for all of the IP blocks from OpenTitan can be run directly from this repository, using the dvsim tool.
Below are the dvsim commands to run the smoke test regression for each block on Xcelium.
At the time of writing spi_host was having issues running properly on xcelium but all other blocks pass their smoke regressions:

These commands are run from the repository root.
Logs and other collateral in the `scratch/` directory.
To obtain a wave trace add `-w shm` to the dvsim command options.

```sh
# Run aon_timer smoke regression
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/vendor/lowrisc_ip/ip/aon_timer/dv/aon_timer_sim_cfg.hjson -i smoke --tool xcelium
# Run gpio smoke regression
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/vendor/lowrisc_ip/ip/gpio/dv/gpio_sim_cfg.hjson -i smoke --tool xcelium
# Run i2c smoke regression
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/vendor/lowrisc_ip/ip/i2c/dv/i2c_sim_cfg.hjson -i smoke --tool xcelium
# Run pattgen smoke regression
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/vendor/lowrisc_ip/ip/pattgen/dv/pattgen_sim_cfg.hjson -i smoke --tool xcelium
# Run pwm smoke regression
# Note: pwm is awaiting an updated DV environment.
# ./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/vendor/lowrisc_ip/ip/pwm/dv/pwm_sim_cfg.hjson -i smoke --tool xcelium
# Run rv_timer smoke regression
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/vendor/lowrisc_ip/ip/rv_timer/dv/rv_timer_sim_cfg.hjson -i smoke --tool xcelium
# Run spi_host smoke regression
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/vendor/lowrisc_ip/ip/spi_host/dv/spi_host_sim_cfg.hjson -i smoke --tool xcelium
# Run uart smoke regression
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/vendor/lowrisc_ip/ip/uart/dv/uart_sim_cfg.hjson -i smoke --tool xcelium
# Run usbdev smoke regression
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/vendor/lowrisc_ip/ip/usbdev/dv/usbdev_sim_cfg.hjson -i smoke --tool xcelium
```

## Building and running top-level software tests

The top-level tests imported from the OpenTitan project may be used to perform to test the integrated IP blocks at top/chip-level.
In order to build these top-level tests a suitable CHERIoT toolchain must be available on your path or specified by the `CHERIOT_LLVM_BIN` environment variable.

The software for these tests is located in the directory `/sw/device` and may be built using the following commands from the project root directory:

```sh
# export CHERIOT_LLVM_BIN=/path/to/cheriot-llvm/bin
cmake -B sw/device/build -S sw/device
cmake --build sw/device/build
```

Examples of how to run these tests using Verilator and xcelium are shown below:

### Verilator simulation of top-level `usbdev_vbus_test`

```sh
build/lowrisc_sunburst_top_chip_verilator_0/sim-verilator/Vtop_chip_verilator \
  -E ./sw/device/build/tests/usbdev_vbus_test
```

Please note that presently the following USBDEV tests work only in Xcelium simulation and do not work with Verilator; this is under investigation.

```
usbdev_config_host_test
usbdev_test
usbdev_stream_test
usbdev_mixed_test
usbdev_iso_test
```

### Xcelium simulation of top-level `usbdev_vbus_test` with dvsim

```sh
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/top_chip/dv/top_chip_sim_cfg.hjson -i usbdev_vbus_test
```

## License

Unless otherwise noted, everything in the repository is covered by the [Apache License](https://www.apache.org/licenses/LICENSE-2.0.html), Version 2.0. See the [LICENSE](https://github.com/lowRISC/sonata-system/blob/main/LICENSE) file for more information on licensing.
