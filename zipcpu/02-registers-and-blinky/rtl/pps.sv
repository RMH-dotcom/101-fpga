/* verilator lint_off DECLFILENAME */

// Making an LED blink once per second using phase accumulator

module pps ( input logic i_clk, output logic o_led);
   parameter CLOCK_RATE_HZ = 100_000_000;
   parameter [31:0] INCREMENT = (1 << 30) / (CLOCK_RATE_HZ / 4);

   logic [31:0]     counter;

   always_ff @(posedge i_clk)
     counter <= counter + INCREMENT;

   assign o_led = counter[31];
endmodule
