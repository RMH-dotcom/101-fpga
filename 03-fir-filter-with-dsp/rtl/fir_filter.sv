/* verilator lint_off DECLFILENAME */

// Block 1: Delay line
// inputs: sample, clock, reset
// outputs: taps
// reg [15:0] r_taps
// Each clock cycle, each register copies the value from the register before it
// i.e. r_taps[1] <= r_taps[0], r_taps[2] <= r_taps[1], etc...
// The oldest r_taps[15] gets overwritten and is gone, and the new sample goes into
// r_taps[0]

// Block 2: Multipliers
// Block 3: Accumulator
