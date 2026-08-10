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
 // Every tick, they all output a fresh item into their respective output chests (products[i]).

 // The Inserters (The Adders):
 // The subsequent inserters are smart Filter Inserters combined with an Assembly function.
 // Inserter 1 looks at the chest at Station 0 (regs[0]), grabs that item, combines it with the fresh item from Assembler 1 (products[1]), and drops the result into the chest at Station 1 (regs[1]).

 input                      i_clk,
 input                      i_rst,
 input                      i_coeff_we,   // write-enable
 input [3:0]                i_coeff_addr, // address
 input signed [15:0]        i_coeff_data, // data
 input signed [15:0]        i_sample,
 output logic signed [15:0] o_result
 );
  logic signed [31:0] l_products [0:15]; // 32-bit wide, and there's 16 of them
  logic signed [35:0] l_regs [0:15];
  logic signed [15:0] l_coeffs [0:15];

  // Block 1: Multipliers
  // i_sample is directed to all 16 multipliers silmultaneously
  // Each (i_sample * i_coeff)
  always_comb
    begin
      for (int i = 0; i < 16; i++)
        begin
          l_products[i] = i_sample * l_coeffs[i];
        end
    end

  // Block 2: Accumulator
  // l_regs[i] <= l_products[i] + l_regs[prev i]
  // Final: output <= l_regs[final i] >> 16
  always_ff @(posedge i_clk)
    if (!i_rst)
      begin
        for (int i = 0; i < 16; i++)
          begin
            l_regs[i] <= '0;
            l_coeffs[i] <= 16'd4096;
          end
        o_result <= '0;
      end
    else
      begin
        if (i_coeff_we)
          begin
            l_coeffs[i_coeff_addr] <= i_coeff_data;
          end

        l_regs[15] <= 36'(l_products[15]);

        for (int i = 0; i < 15; i++)
          l_regs[i] <= 36'(l_products[i]) + l_regs[i+1];

        o_result <= 16'(l_regs[0] >> 16); // right-shift all register items by 16
      end // else: !if(!i_rst)

`ifdef FORMAL
  reg f_past_valid = 0;
  always @(posedge i_clk)
    f_past_valid <= 1;

  // On cycle 0, reset must be asserted.
  // After that first cycle, l_regs are all 0 and the bound holds inductively.
  always @(*)
    begin
      if (!f_past_valid)
        assume(!i_rst);
    end

  always @(posedge i_clk)
    begin
      if (f_past_valid)
        begin
          if ($past(!i_rst))
            assert(o_result == 0);
        end
    end // always @ (posedge i_clk)
`endif
endmodule // fir_filter
