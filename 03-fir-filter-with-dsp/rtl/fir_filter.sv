/* verilator lint_off DECLFILENAME */
module fir_filter
(// Specifications:
// - N-tap FIR filter (16 tap, parameterised)
// - Fixed-point arithmetic (e.g., 16-bit input, 16-bit coefficients, correctly sized accumulator to prevent overflow)
// - Coefficients loadable (hardcoded initially, then via register interface)
// - Pipeline the multiply-accumulate chain for timing closure
// - Test with known input: impulse response must equal coefficients

  input               i_clk,
  input               i_rst,
  input [15:0]        i_sample,
  output logic [15:0] o_result
 );
  logic [15:0] r_tap [0:15];

  // Block 1: Delay line
  // inputs: sample, clock, reset
  // outputs: tap
  // reg [15:0] r_tap
  // Each clock cycle, each register copies the value from the register before it
  // i.e. r_tap[1] <= r_tap[0], r_tap[2] <= r_tap[1], etc...
  // The oldest r_tap[15] gets overwritten and is gone, and the new sample goes into
  // r_tap[0]
  always_ff @(posedge i_clk) begin
    for (int i = 15; i > 0; i--)begin
      r_tap[i] <= r_tap[i-1];
    end
    r_tap[0] <= i_sample;
  end

  // Block 2: Multipliers
  // inputs: r_tap, i_coeff
  // outputs: o_product
  // 16-bit (tap)+ 16-bit (coefficient) = 32-bit output

  // Block 3: Accumulator
  // inputs: o_product
  // outputs: o_result
  // Sums all 16 o_product. log₂(16) = 4, so 32 + 4 = 36-bit output
  // to undo the Q16 (2^16) scalling, right-shift by 16 bits, so 36-16 = 20-bits
  // to which w then truncate to 16
  endmodule // fir_filter
