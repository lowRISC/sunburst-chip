# Dependencies

[FuseSoC](https://github.com/olofk/fusesoc) is used to handle hardware related
build tasks.  It can build Verilator simulations directly and is used by the
[DVsim](https://opentitan.org/book/util/dvsim/index.html) tool to generate file
lists that DVsim uses to build simulations.  We use a [lowRISC specific fork of
FuseSoC](https://github.com/lowRISC/fusesoc/tree/ot-dev) (which was created to
handle primitive generation in the early days of OpenTitan).  DVsim itself also
has various python dependencies.  Pip can be used with the
`python-requirements.txt` file to install FuseSoC and the DVsim dependencies.
The version in this repository is just a copy of the OpenTitan file, so likely
contains extra dependencies that aren't required.  You may wish to install the
dependencies in a virtual environment to isolate them from the rest of your
system.  Python 3.9 or higher is required.

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

It is strongly recommended you build Verilator from source as packaged versions
are often very out of date. Verilator v5.026 was used when writing this README.
Instructions to do this can be found in the [Verilator documentation](https://verilator.org/guide/latest/install.html).

# Run Verilator Simulation

To build a Verilator simulation run:

```sh
NUM_CORES=4
fusesoc --cores-root=. run \
  --target=sim --tool=verilator --setup \
  --build lowrisc:sunburst:top_chip_verilator \
  --verilator_options="-j $NUM_CORES" \
  --make_options="-j $NUM_CORES"
```

*To enable instruction tracing add +define+RVFI to the verilator_options switch
in the command above.*

A test program can be built with scratch_sw/ (a suitable CHERIoT toolchain must
be available on your path or specified by `CHERIOT_LLVM_BIN`):

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

You should see a repeated 'Hello from Sonata Chip!' in `uart0.log`.  The
simulation should terminate itself with the final output looking something like
this:

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

If instruction tracing was enabled `trace_core_00000000.log` will contain a full
instruction trace.

Add the `-t` switch to output a wave trace file in `sim.fst` which can be viewed
with [gtkwave](https://gtkwave.sourceforge.net/). Note with wave tracing enabled
the simulation is many times slower. You can use the provided save file to see
the GPIO output and the PC of the processor:

```sh
gtkwave util/gpio_and_pc.gtkw
```

# Run Xcelium Simulation with dvsim

For now dvsim does not orchestrate any software build.  To run the example smoke
test you must have built the `chip_check` program, see the Verilator
instructions above for details on this.  With Xcelium suitably setup in your
environment run:

```sh
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/top_chip/dv/top_chip_sim_cfg.hjson
```

This will build and run the Xcelium simulation. To get a wave trace add `-w shm`
to the command. To increase uvm verbosity to high add `-v h` to the command.

DVSim provides an overall regression report at the end which should report a
single 'top_chip_smoke' test as passing. If you go to
`scratch/top_chip_asic.sim.xcelium/main/0.top_chip_smoke/latest` you will find
the artifacts from the test run. These are:

 - `trace_core_00000000.log`: The instruction trace
 - `uart0.log`: The output from uart0
 - `run.log`: The log from the simulation run
 - `waves.shm`: The wave trace (only present when DVsim is run with `-w shm`)

# Run block level DV

Block level DV for all of the IP blocks from OpenTitan can be run directly from
this repository, using the dvsim tool. Below are the dvsim commands to run the
smoke test regression for each block on Xcelium. At the time of writing spi_host
was having issues running properly on xcelium but all other blocks pass their
smoke regressions:

These commands are run from the repository root. Logs and other collateral in
the `scratch/` directory. To obtain a wave trace add `-w shm` to the dvsim
command options.

```sh
# Run aon_timer smoke regression
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/vendor/lowrisc_ip/ip/aon_timer/dv/aon_timer_sim_cfg.hjson -i smoke --tool xcelium
# Run gpio smoke regression
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/vendor/lowrisc_ip/ip/gpio/dv/gpio_sim_cfg.hjson -i smoke --tool xcelium
# Run i2c smoke regression
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/vendor/lowrisc_ip/ip/i2c/dv/i2c_sim_cfg.hjson -i smoke --tool xcelium
# Run rv_timer smoke regression
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/vendor/lowrisc_ip/ip/rv_timer/dv/rv_timer_sim_cfg.hjson -i smoke --tool xcelium
# Run spi_host smoke regression
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/vendor/lowrisc_ip/ip/spi_host/dv/spi_host_sim_cfg.hjson -i smoke --tool xcelium
# Run uart smoke regression
./hw/vendor/lowrisc_ip/util/dvsim/dvsim.py ./hw/vendor/lowrisc_ip/ip/uart/dv/uart_sim_cfg.hjson -i smoke --tool xcelium
```
