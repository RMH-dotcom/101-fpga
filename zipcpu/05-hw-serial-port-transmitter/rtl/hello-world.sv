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

  logic [26:0] TIMER; // 27 bits (2^27 = 128,000,000, enough for 100M)
  logic [3:0]  character_index; // 4 bits (2^4 = 16, enough for 16 characters)
  logic [7:0]  tx_data;
  logic        tx_stb;
  logic        tx_busy;
  logic        tx_restart;
  initial TIMER = 0;
  initial character_index = 0;
  initial tx_stb = 0;
  initial tx_restart = 0;

  // Block 1: Counter/timer
  // if TIMER == 0  -> reset timer
  // else TIMER - 1 -> resume timer
  always_ff @(posedge i_clk) begin
    if (TIMER == 0) // If timer is off,
      TIMER <= 100_000_000 - 1'b1; // Begin counting down from 100M ticks
    else
      TIMER <= TIMER - 1'b1;
    tx_restart <= (TIMER == 1); // Always runs, every clock
  end

  // Block 2: Character index tracker (gated by tx_restart)
  // if tx_restart          -> send characters (tx_stb = 1)
  // if tx_stb && !tx_busy  -> advance index
  // if last character sent -> stop (tx_stb = 0)
  always_ff @(posedge i_clk) begin
    if (tx_restart)
      tx_stb <= 1;
    else if (tx_stb && !tx_busy)
      tx_stb <= 0;
  end

endmodule // hello_world
