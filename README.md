# VHDL RiscV helper CPU environment for FPGAs

A working and hardware-tested implementation and a instantiation template of open-source soft-core CPUs.
Implemented in platform-independent pure VHDL (or Verilog). The minimalistic design is intended to be included as
part of a bigger FPGA implementation, where some tasks fit better for CPUs.

Code is run from a tightly coupled internal block memory for fast access times, and a registered Wishbone bus interface
is exported from the main entity for attaching slower peripherals. The choice of the cpu type is made with a simple generic setting.

Baremetal makefile with a minimal runtime library is provided as the software, supporting timers, IRQs and bit-bang uart TX
for debugging.

## Baremetal gcc environment

Baremetal folder has a Makefile that builds the software image. The result is stored in a VHDL package, which is included
in the project as a VHDL source. The package also determines the memory size, which is currently 8KB (4x16kb blocks)

## How to use

Take alpus_riscv_cpu_example as a base for your project and modify for your needs. The example has a constant which lets you
choose between SERV or VexRiscV instantiation, depending on the performance that is needed.

Edit config.hpp and main.cpp to start your own software.

## serv/

Serv folder contains olofk's serv (<https://github.com/olofk/serv>).

    Serv: 429LC/291FF/125MHz (Cyclone III) (Benchmark 9070ms @ 125MHz)

## vexriscv/

This folder contains a pre-generated VexRiscV (<https://github.com/SpinalHDL/VexRiscv>)core. The Plus version runs at about
2 to 3 clocks per instruction.
 
    Base: 982LC/536FF/113MHz (Cyclone III) (Benchmark 590ms @ 125MHz)
    Plus: 1162LC/566FF/107MHz (Cyclone III) (Benchmark 440ms @ 125MHz)

## License

I release my code here to public domain, but the CPU cores have an attribution license. See the 
corresponding folders or the Github sites for license details.


