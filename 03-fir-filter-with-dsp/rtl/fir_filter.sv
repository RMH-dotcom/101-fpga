/* verilator lint_off DECLFILENAME */

// Specifications:
// - N-tap FIR filter (16 tap, parameterised)
// - Fixed-point arithmetic (e.g., 16-bit input, 16-bit coefficients, correctly sized accumulator to prevent overflow)
// - Coefficients loadable (hardcoded initially, then via register interface)
// - Pipeline the multiply-accumulate chain for timing closure
// - Test with known input: impulse response must equal coefficients

// Block 1: Delay line
// inputs: sample, clock, reset
// outputs: tap
// reg [15:0] r_tap
// Each clock cycle, each register copies the value from the register before it
// i.e. r_tap[1] <= r_tap[0], r_tap[2] <= r_tap[1], etc...
// The oldest r_tap[15] gets overwritten and is gone, and the new sample goes into
// r_tap[0]

// Block 2: Multipliers
// inputs: r_tap, i_coeff
// outputs: o_product
// 16-bit (tap)+ 16-bit (coefficient) = 32-bit output

// Block 3: Accumulator
// inputs: o_product
// outputs: o_result
// Sums all 16 o_product. log₂(16) = 4, so 32 + 4 = 36-bit output
