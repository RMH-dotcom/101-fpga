# ZipCPU Tutorial Journal: 01-wires

**Date:** 15 February 2026
**Board:** Zybo Z7-10 (xc7z010clg400-1)
**Objective:** Learn fundamental FPGA workflow through simple passthrough design

---

## Design Overview

**Module:** `thruwire`
**Functionality:** Direct connection between switch input and LED output
**Verilog:**

```verilog
module thruwire (
    input  i_sw,   // Physical switch
    output o_led   // Physical LED
);
  assign o_led = i_sw;
endmodule
```

**Purpose:** Introduction to combinatorial logic and the concept that Verilog describes hardware connections, not sequential code execution.

---

## Workflow 1: Iverilog Simulation (Initial Attempt)

### Compilation

Attempted Icarus Verilog compilation to generate VVP executable:

```bash
iverilog -o 01-wires.out 01-wires.v
```

**Result:** Successfully generated `01-wires.out` (VVP format executable).

### Issue Identified

No testbench was written. The design module cannot be simulated in isolation without a testbench to:

- Instantiate the `thruwire` module
- Drive input signals (`i_sw`)
- Monitor output signals (`o_led`)
- Generate VCD waveform files for GTKWave visualisation

**Lesson Learnt:** Simulation requires a separate testbench module, even for trivial designs. This workflow was abandoned in favour of direct hardware testing.

---

## Workflow 2: Vivado GUI Synthesis and Hardware Programming

### Synthesis Process

1. Created Vivado project using GUI
2. Added RTL source: `01-wires.v`
3. Added constraints: `01-wires.xdc` (Zybo Z7 master constraints, modified)
4. Ran synthesis → implementation → bitstream generation

### Hardware Programming Challenges

**Initial Problem:** Vivado Hardware Manager could not detect the Zybo Z7 board.

**Root Cause:** Linux kernel driver `ftdi_sio` was claiming the FTDI FT2232H JTAG interface (USB device 1-6:1.0), preventing Vivado's `hw_server` from accessing the device.

**Solution Applied:**

1. Unbound FTDI driver manually:
   ```bash
   echo "1-6:1.0" > /sys/bus/usb/drivers/ftdi_sio/unbind
   ```
2. Set USB device permissions:
   ```bash
   chmod 666 /dev/bus/usb/001/006
   ```
3. Killed and restarted `hw_server`

**Permanent Fix:** Added udev rule to `/home/nixoslaptopmak/Projects/NixOS-Config-Symlink/security-hardening.nix`:

```nix
SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", \
  ATTRS{manufacturer}=="Digilent", MODE="0666", GROUP="users"
```

### Hardware Verification

**Result:** Successfully programmed bitstream to FPGA.

**Observed Behaviour:**

- **ON LED:** Illuminated (power indicator)
- **DONE LED:** Illuminated (configuration complete)
- **LD0 LED:** Followed switch state (SW0)
  - Switch down → LED off
  - Switch up → LED on

**Conclusion:** Hardware verification confirmed correct operation of the passthrough logic.

---

## Workflow 3: Verilator Simulation with C++ Testbench

### Rationale

Learnt that professional FPGA development follows a **simulation-first methodology**:

1. Write testbench and simulate extensively
2. Verify functionality in simulation
3. Only then synthesise for hardware

For simple designs like `01-wires`, simulation seems redundant. However, for complex projects (UART, SPI, AXI-Lite), hardware debugging becomes impractical without waveform analysis.

### Verilator Model Generation

Generated C++ model from Verilog RTL:

```bash
verilator --cc 01-wires.v
```

**Output:** C++ class model in `obj_dir/`:

- `V__0301__02dwires.h` (header)
- `V__0301__02dwires.cpp` (implementation)
- `V__0301__02dwires__ALL.a` (compiled library)

**Note:** The generated class name (`V__0301__02dwires`) appears to be derived from file path/naming, not the module name (`thruwire`).

### C++ Testbench Development

Created `01-wires.cpp` to instantiate and test the Verilator model:

```cpp
#include <stdio.h>
#include <stdlib.h>
#include "verilated.h"
#include "V__0301__02dwires.h"

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  V__0301__02dwires *tb = new V__0301__02dwires;

  for (int k = 0; k < 20; k++) {
    tb->i_sw = k & 1;  // Toggle switch on odd iterations
    tb->eval();        // Evaluate model
    printf("k = %2d, sw = %d, led = %d\n", k, tb->i_sw, tb->o_led);
  }
}
```

**Initial Errors Encountered:**

1. Incorrect spacing in `#include` directives (`# include` instead of `#include`)
2. Wrong class name (`V01-wires` instead of `V__0301__02dwires`)
3. Missing arrow operator (`tb i_sw` instead of `tb->i_sw`)
4. Spaces in format strings and identifiers (`%2 d`, `i s w`, `o l e d`)
5. Missing required headers (`verilated.h`, model header)

### Manual Compilation

Compiled testbench and linked against Verilator libraries:

```bash
VERILATOR_ROOT=/nix/store/k2hr6adz55vyd0kbwdxyhb5bxrpv3p8y-verilator-5.040

g++ -I${VERILATOR_ROOT}/share/verilator/include \
    -I obj_dir/ \
    ${VERILATOR_ROOT}/share/verilator/include/verilated.cpp \
    ${VERILATOR_ROOT}/share/verilator/include/verilated_threads.cpp \
    01-wires.cpp obj_dir/V__0301__02dwires__ALL.a \
    -o 01-wires_sim
```

**Critical Discovery:** Must link against `verilated_threads.cpp` to satisfy `VlThreadPool` dependencies (Verilator 5.x requirement).

### Simulation Results

Executed simulation:

```bash
./01-wires_sim
```

**Output:**

```
k =  0, sw = 0, led = 0
k =  1, sw = 1, led = 1
k =  2, sw = 0, led = 0
k =  3, sw = 1, led = 1
...
```

**Verification:** Output confirmed that `led` correctly tracks `sw` state (passthrough behaviour), matching hardware observations.

---

## Makefile Automation

### Motivation

The manual Verilator compilation command is excessively complex and error-prone. Makefiles provide:

- **Declarative build specification** (similar to NixOS philosophy)
- **Dependency tracking** (rebuild only changed files)
- **Reproducibility** (consistent build process)
- **Industry standard** (expected skill for FPGA roles)

### Makefile Structure Learnt

**Basic syntax:**

```make
target: dependencies
	command   # MUST use TAB character, not spaces
```

**Key concepts:**

1. **Variables:** Define once, use everywhere (`RTL = 01-wires.v`)
2. **Dependencies:** Make rebuilds only when source files change
3. **Phony targets:** Actions rather than files (`.PHONY: clean`)
4. **Default target:** First target runs when typing `make` alone

### Implementation

Created `Makefile` with targets:

- `make sim` → Run Verilator simulation
- `make clean` → Remove generated files
- `make help` → Display available targets

**Modern approach:** Using `verilator --build` flag (simpler than manual compilation):

```make
sim: 01-wires.v 01-wires.cpp
	verilator --cc --exe --build 01-wires.v 01-wires.cpp -o 01-wires_sim
	./obj_dir/01-wires_sim
```

This single command handles:

- Verilog → C++ translation
- C++ compilation
- Linking against Verilator libraries
- Executable generation

---

## Comparison of Simulation Methods

| Aspect                 | Iverilog                  | Verilator                   |
| ---------------------- | ------------------------- | --------------------------- |
| **Testbench Language** | Verilog                   | C++                         |
| **Learning Curve**     | Gentle (Verilog-only)     | Steeper (requires C++)      |
| **Simulation Speed**   | Slower (event-driven)     | Faster (cycle-accurate)     |
| **Waveform Output**    | VCD (native)              | VCD (requires extra code)   |
| **Industry Use**       | Education, small projects | Verification, large designs |
| **Roadmap Phase**      | Phase 1                   | Phase 2+                    |

**Decision:** Use Iverilog for Phase 1 projects (UART, SPI) to focus on Verilog skills. Transition to Verilator in Phase 2 when simulation speed becomes critical.

---

## Lessons Learnt

1. **Simulation-first workflow is essential:** Hardware debugging without waveforms is impractical for anything beyond trivial designs.

2. **Vivado GUI is insufficient:** Professional workflow requires scripted builds (TCL, Makefiles) for reproducibility and automation.

3. **NixOS USB permissions:** FPGA JTAG interfaces require careful udev rule configuration to prevent kernel driver conflicts.

4. **Verilator naming quirks:** Generated class names may not match module names; always check `obj_dir/` output.

5. **Makefiles are declarative build tools:** More similar to NixOS than bash scripts; only rebuild what changed.

6. **Tab characters matter:** Makefiles reject spaces in command lines (historical Unix design decision from 1976).

---

## Next Steps

1. **Complete ZipCPU 01-wires formally:**
   - Write Iverilog testbench (`01-wires_tb.v`)
   - Generate VCD waveform
   - Visualise in GTKWave

2. **Progress to ZipCPU 02-\* tutorial:**
   - Apply Makefile workflow from the start
   - Build simulation habit before hardware testing

## Reference Files

- **RTL:** `01-wires.v` (thruwire module)
- **Constraints:** `01-wires.xdc` (Zybo Z7 pin mappings)
- **Verilator Testbench:** `01-wires.cpp`
- **Build Automation:** `Makefile`
- **Iverilog Output:** `01-wires.out` (VVP format, requires testbench)
- **Verilator Model:** `obj_dir/V__0301__02dwires__ALL.a`

---

**Status:** ZipCPU 01-wires completed via hardware verification. Simulation workflow established but not yet exercised with proper testbench. Ready to proceed to next tutorial with improved methodology.
