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
    else if (tx_stb && !tx_busy) begin
      character_index <= character_index + 1;
      if (character_index == 4'hf) // if at last character,
        tx_stb <= 0; // then stop
    end
  end

  // Block 3: Lookup table
  always_ff @(posedge i_clk)
    case (character_index)
      default: tx_data <= 8'h0;
      4'h0: tx_data <= "H";
      4'h1: tx_data <= "e";
      4'h2: tx_data <= "l";
      4'h3: tx_data <= "l";
      4'h4: tx_data <= "o";
      4'h5: tx_data <= " ";
      4'h6: tx_data <= "W";
      4'h7: tx_data <= "o";
      4'h8: tx_data <= "r";
      4'h9: tx_data <= "l";
      4'ha: tx_data <= "d";
      4'hb: tx_data <= "!";
      4'hc: tx_data <= "\r";
      4'hd: tx_data <= "\n";
    endcase // case (character_index)

  // Block 4: Instantiating tx_uart
  tx_uart transmitter (
                       .i_clk(i_clk),
                       .i_wr(tx_stb),
                       .i_data(tx_data),
                       .o_uart_tx(o_uart_tx),
                       .o_busy(tx_busy)
                       );

endmodule // hello_world
