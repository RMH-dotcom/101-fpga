/* verilator lint_off DECLFILENAME */

// LED walker with Wishbone slave interface
// Walks LEDs continuously, wishbone reads return current state

module led_walker_upon_request (
   input logic         i_clk,
   // Wishbone slave interface
   input logic         i_wb_stb,   // 1.   Initialise transaction to output
   /* verilator lint_off UNUSEDSIGNAL */
   input logic         i_wb_we,    // 1.5. Ignore write commands/requests (read-only)
   output logic        o_wb_ack,   // 2.   Acknowledge transaction
   output logic        o_wb_stall, // 2.5. Signal "stall" when busy
   output logic [31:0] o_wb_data,  // 3.   Data output
   // LED output
   output logic [3:0]  o_led
);

   // LED walker FSM state
   logic [3:0] led_index;

   initial led_index = 0;

   // LED walker FSM - runs continuously
   always_ff @(posedge i_clk) begin
      if (led_index >= 4'd3)
         led_index <= 0;
      else
         led_index <= led_index + 1'b1;
   end

   // One-hot encoding for LED output
   assign o_led = (4'd1 << led_index);

   // Wishbone interface - single-cycle read
   assign o_wb_ack   = i_wb_stb;           // Acknowledge transmission immediately
   assign o_wb_stall = 1'b0;               // Never stall
   assign o_wb_data  = {28'h0, o_led};     // Return current LED state

`ifdef FORMAL
   // LED walker assertions
   always_comb begin
      assert(led_index <= 4'd3);
      assert($onehot(o_led));
      assert(|o_led);
   end

   always_ff @(posedge i_clk) begin
      cover(led_index == 4'd3);
   end

   // Wishbone protocol assertions
   always_comb begin
      // Ack only when strobe active
      assert(o_wb_ack == i_wb_stb);
      // Never stall
      assert(o_wb_stall == 1'b0);
   end
`endif

endmodule
