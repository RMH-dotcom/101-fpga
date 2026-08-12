# FIR Filter (Transpose Form)

## Overview
In this project, I designed a pipelined, fixed-point Finite Impulse Response (FIR) filter implemented in SystemVerilog. The architecture is explicitly designed in **Transpose Form** to optimise timing closure on my Xilinx 7-Series (xc7z010clg400-1) FPGA board by eliminating long combinational adder-tree paths and maximising native DSP48E1 slice inference.

## Architecture
As mentioned above, the FIR architecture is designed in the transpose form configuration:
```text
                        i_sample [15:0] (Broadcast Bus)
             ┌─────────────────┴─────────────────┐
             v                                   v
       [Station 15]                        [Station 14]            ...       [Station 0]
      (l_coeffs)                      (l_coeffs)                    (l_coeffs)
             |                                   |                               |
             v                                   v                               v
      (l_products)                    (l_products)                  (l_products)
             |                                   |                               |
             v                                   v                               v
(Empty) ──> [Reg 15] ───────────────> [    +    ] ──> [Reg 14] ──> ... ──> [    +    ] ──> [Reg 0] ──> (>>>16) ──> [o_result] ──> o_result [15:0]
      (l_regs)                           ^         (l_regs)                     ^         (l_regs)
                                         |                                      |
                                  (l_products)                           (l_products)
```

## Specifications

### Port Table
```
    input                      i_clk,
    input                      i_rst,
    input                      i_coeff_we,
    input [3:0]                i_coeff_addr,
    input signed [15:0]        i_coeff_data,
    input signed [15:0]        i_sample,
    output logic signed [15:0] o_result
```

`i_coeff_addr` 0 writes `l_coeffs[0]`, which is the tap nearest the output (`l_regs[0]`).
`i_coeff_addr` 15 writes `l_coeffs[15]`, the tap farthest from the output.
Coefficients should be loaded as `h[0]` at address 0 through `h[15]` at address 15.

### Bit Widths
Inputs/Outputs: 16 bits wide.

```
    logic signed [31:0] l_products [0:15];
    logic signed [35:0] l_regs [0:15];
    logic signed [15:0] l_coeffs [0:15];
```

Internal Products: 32 bits wide.

Internal Accumulators (l_regs): 36 bits wide. 36 bits prevents overflow when accumulating 16 x 32-bit products (log₂16 = 4 additional bits required).

### Tap Count
The FIR filter design has a tap count of 16.

### Coefficient format
Coefficients use S0.16 fixed-point format (signed, 0 integer bits, 16 fractional bits), representing values in the range [−0.5, +0.5). A coefficient value of 4096 therefore represents 4096 / 65536 = 0.0625. The default reset value is 4096. `i_sample` is a signed integer (no fractional bits). `o_result` recovers the integer part by right-shifting the accumulator by 16 bits.

`Lint`: `make lint` passes with no warnings under Verilator -Wall.

`Reset`: Reset is synchronous and active-low (`!i_rst`), meaning reset maps directly onto the FDRE (synchronous reset) flip-flops that Vivado infers, avoiding the additional timing constraints that asynchronous resets require on ZYBO 7-Series devices.

`Regression`: `make sim` runs all three test blocks (firwin impulse, ramp, and stream) and prints PASS/FAIL per cycle.

## Implementation Results

### Resource Utilisation
```
BUFG: 1
DSP48E1: 16/80 (20%)
LUT1: 1
LUT5: 16
FDRE: 256
FDSE: 16
IBUF: 39
OBUF: 16
```
The one LUT1 is a NOT gate inserted by Vivado to convert the RTL's active-low reset (`!i_rst`) into the active-high signal that the FDRE reset pin expects.

The 16 `DSP48E1` slices absorb the full 576-bit accumulator chain (16 × 36 bits) via their internal PREG and the `PCIN→PCOUT` cascade, which is why no accumulator state appears as fabric flip-flops. The 256 `FDRE` hold the 15 zero-reset bits of each coefficient register plus the 16 `o_result` bits. The 16 `FDSE` hold coefficient bit 12, which is set (not reset) because the default coefficient value 4096 = 2¹² has that bit `HIGH`.

### Timing Analysis Results
Timing was analysed via Out-of-Context (OOC) implementation at a 100 MHz (10 ns) target clock. This is because the Zybo Z7-10 board clock is 125 MHz (8 ns). 100 MHz (10 ns) was chosen as a conservative target slightly below the board clock, to give the router a buffer zone and make the WNS result easy to interpret. The large positive WNS then confirms the design could comfortably close at the actual board frequency.

OOC implementation was used because the design has 55 ports but the Zybo Z7-10 only exposes 50 user IO pins, so a full top-level implementation with physical pin constraints is impossible. OOC synthesis removes the IO placement requirement entirely, allowing Vivado to route and time the core logic in isolation.

| Metric | Value |
|---|---|
| Target Clock | 100 MHz (10.000 ns) |
| WNS | +4.844 ns |
| Failing Endpoints | 0 / 1024 |
| fmax | ~193.9 MHz |

## Verification

### The Legacy Approach & Its Structural Limitations
In the earliest version of this verification suite, the testbench driven by `tb_fir_filter.cpp` simply utilised a uniform moving-average coefficient set (all taps hardcoded to `4096`). The test sequence fed a single impulse of `0x8000` followed by zeros, asserting that `o_result` equaled `2048` for exactly 16 consecutive clock cycles (Cycles 1–16) before reverting back to `0`. The signedness bug was found when 0x8000 produced `−2048` instead of `2048`.

While this basic test verified raw pipeline latency (confirming it was a 1-cycle latency rather than a 2-cycle structure), because all coefficients were the same, the impulse test was incapable of catching tap-ordering or time-reversal wiring bugs inside the transposed accumulator chain.

### The Transition to Golden-Reference Verification
A Python golden-reference generator script was developed using `scipy.signal.firwin`.

The script employs a 16-tap low-pass filter. `firwin` produces linear-phase (symmetric) coefficients where `h[k] = h[N−1−k]`, meaning a full tap reversal maps the set onto itself and would pass this test silently. The firwin test catches rotations and non-mirror swaps only.

Instead of validating against a smooth 64-bit floating-point routine, the Python script employs 32-bit signed multiplications, 36-bit intermediate accumulations, and the trailing 16-bit arithmetic right-shift truncation (`>> 16`).

These unique, quantised coefficients are loaded into the hardware core via the coefficient inputs `i_coeff_we`, `i_coeff_addr` and `i_coeff_data`. The testbench streams the `0x7FFF` impulse through the newly loaded taps and automatically asserts that the live hardware outputs match the scipy-generated integer answer key line-for-line.

Importantly, the system successfully tracks the signed impulse response of the windowed-sinc filter with zero quantisation or rounding drift, verifying the datapath's integrity.

To close the tap-reversal gap, a second impulse test uses integer ramp coefficients [1, 2, ..., 16], which is an asymmetric set where `h[0] ≠ h[15]`. A full tap reversal would produce a descending ramp response instead of the ascending one, causing an immediate mismatch. This test confirms correct tap ordering end-to-end.

A third test streams 40 random samples through the filter continuously, exercising the adder chain with multiple simultaneous nonzero products on every cycle. The bit-accurate Python model produces a 56-cycle expected output sequence (40 samples plus 16 flush cycles). The hardware matches this line-for-line.

| Behaviour | Status |
|---|---|
| Tap ordering (asymmetric ramp) | Verified |
| Signed datapath and Q16 arithmetic | Verified |
| Adder chain with simultaneous nonzero products | Verified |
| Mid-stream coefficient reload | Not tested — behaviour undefined |
| Saturation | Not applicable — overflow proven impossible by accumulator bound |

### Formal Verification
Formal verification aimed to prove that after any cycle where reset is asserted, `o_result` would be 0 on the next cycle. SymbiYosys with Yices, k-induction, and depth 20 were used.

Originally, the formal verification suite also included accumulator bound assertions. However, the automated proof timed out due to bitvector multiplication complexities, where the solver would still be active past 35 minutes.

The bound is documented as a manual calculation: 16 × 32768² = 17,179,869,184, which is less than the 36-bit signed maximum of 34,359,738,367, which confirms that 36 bits is sufficient to accumulate 16 signed 32-bit products without overflow.

## Design Decisions

### Why Transpose Form?
Transpose form was utilised in this design over direct form, because the design utilises a large number of taps (16), to which - if otherwise, a direct form was used, the adder tree for the 16 taps would limit the maximum clock frequency to a lower number due to the accumulated effect of the coefficient multiplier and adder delays.

By eliminating the long adder tree, and having the inputs multiplied by the coefficients simultaneously, it results in a higher achievable clock frequency, and is overall optimal and efficient.

Had the design utilised lower speeds and number of taps, direct form would have been more convenient.

### Why Runtime-Loadable Coefficients?
In the earliest version, the design utilised 16 hardcoded localparam constants. Upon synthesising with the earliest RTL on Vivado, the Cell Usage table indicated that no DSP48 were used anywhere. Vivado used LUTs and CARRY4 chains instead.
This is the key deliverable the aims of the project required. The reason for this is that, without variable coefficients, Vivado saw the constant multiplication and automatically optimised it into shift-add chains (LUTs + CARRY4) rather than inferring DSP48E1 slices, which is actually more area-efficient for fixed constants. However, it defeated the purpose of this project.


## Other Problems Solved

### Latency Off by One
The testbench expectation was off by one cycle. 2 cycles of latency were incorrectly assumed, instead of one. As a result, cycles 1 and 17 failed. The actual latency is 1 cycle, not 2, because non-blocking assignments in `always_ff` mean `o_result` reads `l_regs[0]` from the previous clock edge. This was subsequently confirmed by the golden reference test, which independently predicted the same 1-cycle delay.

## Conclusion
The FIR filter has 55 ports `(i_clk, i_rst, i_coeff_we, 4-bit addr, 16-bit coeff data, 16-bit sample, 16-bit result)` but the Zybo Z7-10 only exposes 50 user IO pins. It won't fit as a standalone top-level module. As a result, a bitstream has not been generated. However, DSP48 inference has been verified at synthesis stage. Additionally, out-of-context (OOC) implementation succeeded and provided real timing data.
