/* verilator lint_off DECLFILENAME */

// Making the LED's activate across valid LED's and back
// Only one LED should be active at any time
// One LED should always be active at any given time

module led_walker ( input logic i_clk, output logic [3:0] o_led);
   logic [3:0] led_index;
   initial led_index = 0; // Initialise led_index to index 0 at the beginning of the simulation

   always_ff @(posedge i_clk) begin
     if // When the clock signal (i_clk) transitions from 0 to 3,
       (led_index >= 4'd3) // Check if we've reached the 4th LED (0 to 3)
       led_index <= 0; // If TRUE: Rollover back to the start
     else
       led_index <= led_index + 1'b1; // If FALSE: Increment to the next LED
   end

   // DEcode led_index to one-hot LED output
   assign o_led = (4'd1 << led_index);
endmodule // led_walker
