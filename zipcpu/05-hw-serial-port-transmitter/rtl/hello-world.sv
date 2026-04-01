/* verilator lint_off DECLFILENAME */
// This file acts as a wrapper that feeds the characters "Hello World!" to the tx.

// Every second:
// for each character in "Hello World!\r\n":
// wait until !tx_busy
// send character to transmitter

module hello_world (
                    input logic i_clk,
                    output logic o_uart_tx
);

  always_ff @(posedge i_clk)
    if (i_clk) begin
    end
endmodule // hello_world
