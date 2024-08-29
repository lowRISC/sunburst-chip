# Overview

As the name suggests 'scratch_sw' is not intended to be permanent. It exists as
a quick way to build some initial binaries for bringing up the sunburst chip
top-level simulation. Once we have decided on an architecture and build system
for the top-level verification software environment this directory will be
removed.

## bare_metal/
This is derived from sw/cheri in the sonata-system repository contains 'checks'
which are small programs for initial testing and bring-up

CMake is used as the build system, to build binaries run (from the repository
root):

```sh
cmake -B scratch_sw/bare_metal/build -S scratch_sw/bare_metal
cmake --build scratch_sw/bare_metal/build
```
