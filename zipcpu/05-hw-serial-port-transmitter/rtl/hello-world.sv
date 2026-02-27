/* verilator lint_off DECLFILENAME */

// This script comprises of a two module design
// It wll:
// 1. Build a serial port transmitter: i_clk, i_wr, o_busy, i_data, o_uart_tx
// 2. Be able to transmit Hello World!: as above
// 3. Clean up the Verilator work
// 4. Simulate a serial port receiver

// A serial transmission:
// - Idles high
// - Begins with a start bit (low), ends with stop bit (high)
// - Sends a byte of data, LSB first

// After:
// - Ten states to the state machine
// - Will still need to slow it down later

module hello_world (
                    input logic i_clk,
                    input logic i_wr,
                    input logic [7:0] i_data,
                    output logic o_busy,
                    output logic o_uart_tx
);

  // Define IDLE, START, LAST and their values
  typedef enum logic [3:0] {
                            IDLE = 4'b0000, // IDLE = 0
                            START = 4'b0001, // START = 1
                            LAST = 4'd10 // LAST = 10
                            } state_t;

  // Store the byte to transit
  logic [9:0]  data_reg; // data_reg holds: start + 8 data + stop

  // Create the actual variable using the above definition
  state_t state;

  initial {o_busy, state} = {1'b0, IDLE}; // By default, set o_busy to off, and the state to idle
    always_ff @(posedge i_clk) // Everytime the clock ticks up (0 to 1), execute the logic below
      if ((i_wr) && (!o_busy)) begin // If the write is requested, and o_busy is NOT busy,
        {o_busy, state} <= {1'b1, START}; //o_busy is turned ON, and the state is active
        data_reg <= {1'b1, i_data, 1'b0}; // {stop, 8 data bits, start}
        end
          else if (state == IDLE) begin // or
            {o_busy, state} <= {1'b0, state}; // Ensure o_busy stays off while waiting in IDLE
            end
              else if (state < LAST) begin // or
                  o_busy <= 1'b1; // o_busy is turned ON
                  state <= state_t'(state + 4'd1); // Increment to the next state (counting up)
                  // Shift right for more data, and 1'b1 in from the left
                  data_reg <= {1'b1, data_reg[9:1]};
                 end
                   else begin // If at LAST,
                     // when the state reaches LAST, stay busy for one more cycle,
                     // but reset the state to IDLE
                   {o_busy, state} <= {1'b1, IDLE};
                  end
  assign o_uart_tx = data_reg[0];
endmodule // hello_world
