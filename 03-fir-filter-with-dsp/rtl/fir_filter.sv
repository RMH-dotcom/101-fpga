/* verilator lint_off DECLFILENAME */
module fir_filter
(// Specifications:
// - N-tap FIR filter (transpose form, 16 tap, parameterised)
// - Fixed-point arithmetic (e.g., 16-bit input, 16-bit coefficients, correctly sized accumulator to prevent overflow)
// - Coefficients loadable (hardcoded initially, then via register interface)
// - Pipeline the multiply-accumulate chain for timing closure
// - Test with known input: impulse response must equal coefficients

 // -- IN FACTORIO TERMS --
 // The Splitters & Assemblers:
 // The main input belt (i_sample) hits a 16-way splitter.
 // It feeds all 16 assemblers simultaneously.
 // Each assembler has its own recipe module (p_coeff).
 // Every tick, they all output a fresh item into their output chest (products[i]).

 // The Inserters (The Adders):
 // The subsequent inserters are smart Filter Inserters combined with an Assembly function.
 // Inserter 1 looks at the chest at Station 0 (regs[0]), grabs that item, combines it with the fresh item from Assembler 1 (products[1]), and drops the result into the chest at Station 1 (regs[1]).

  input               i_clk,
  input               i_rst,
  input [15:0]        i_sample,
  output logic [15:0] o_result
 );
  logic [31:0] l_products [0:15];
  logic [35:0] l_regs [0:15];

  // Block 1: Multipliers
  // i_sample is directed to all 16 multipliers silmultaneously
  // Each (i_sample * i_coeff)

  // Block 2: Accumulator
  // l_regs[i] <= l_products[i] + l_regs[prev i]
  // Final: output <= l_regs[final i] >> 16

  endmodule // fir_filter
