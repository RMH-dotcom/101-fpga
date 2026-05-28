/* verilator lint_off DECLFILENAME */

// Specifications:
// - N-tap FIR filter (16 taps, parameterised)
// - Fixed-point arithmetic (e.g., 16-bit input, 16-bit coefficients, correctly sized accumulator to prevent overflow)
// - Coefficients loadable (hardcoded initially, then via register interface)
// - Pipeline the multiply-accumulate chain for timing closure
// - Test with known input: impulse response must equal coefficients

// Block 1: Delay line
// inputs: sample, clock, reset
// outputs: taps
// reg [15:0] r_taps
// Each clock cycle, each register copies the value from the register before it
// i.e. r_taps[1] <= r_taps[0], r_taps[2] <= r_taps[1], etc...
// The oldest r_taps[15] gets overwritten and is gone, and the new sample goes into
// r_taps[0]

// Block 2: Multipliers
// inputs: r_taps, i_coeff
// outputs: o_product
// 16-bit (tap)+ 16-bit (coefficient) = 32-bit output

// Block 3: Accumulator
