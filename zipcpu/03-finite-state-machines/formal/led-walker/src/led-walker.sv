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

// For formal verification with Yosys
`ifdef FORMAL
   // Check that led_index never goes out of bounds
   always_comb begin
      assert(led_index <= 4'd3);
   end

   // Check that o_led is always a valid "one-hot" value for LED's [3:0]
   // Should only be: 0, 1, 2 and 3
   always_comb begin
      assert($onehot(o_led));
   end

   // Ensure that at least one LED is always on
   always_comb begin
      assert(|o_led);
   end

   // Ensure the walker actually reaches the end
   always_ff @(posedge i_clk) begin
      cover(led_index == 4'd3);
   end
   `endif
endmodule // led_walker
