/* verilator lint_off DECLFILENAME */

// This script comprises of a two module design
// It wll:
// 1. Build a serial port transmitter: i_clk, i_wr, o_busy, i_data, o_uart_tx
// 2. Be able to transmit Hello World!: as above
// 3. Clean up the Verilator work
// 4. Simulate a serial port receiver

module hello_world (
                    input logic i_clk,
                    input logic i_wr,
                    input logic i_data,
                    output logic o_busy,
                    output logic o_uart_tx
);

  initial {o_busy, state} = {1'b0, IDLE}; // By default, set o_busy to off, and the state to idle
  always_ff @(posedge i_clk) // Everytime the clock ticks up (0 to 1), execute the logic below
    if ((i_wr) && (!o_busy)) //If the write is requested, and o_busy is NOT busy,
      {o_busy, state} <= {1'b1, START}; //o_busy is turned ON, and the state is active
        else if (state == IDLE) // or
          {o_busy, state} <= {1'b0, state}; // Ensure  o_busy stays off while waiting in IDLE
             else if (state < LAST) // or
               begin
                 o_busy <= 1'b1; // o_busy is turned ON
                 state <= state + 1; // Increment to the next state (counting up)
                          end else
                            // when the state reaches LAST, stay busy for one more cycle,
                            // but reset the state to IDLE
                            {o_busy, state} <= {1'b1, IDLE};
endmodule // hello_world
