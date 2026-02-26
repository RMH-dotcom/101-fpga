/* verilator lint_off DECLFILENAME */

// This script comprises of a two module design
// It wll:
// 1. Build a serial port transmitter: i_clk, i_wr, o_busy, i_data, o_uart_tx
// 2. Be able to transmit Hello World!: as above
// 3. Clean up the Verilator work
// 4. Simulate a serial port receiver

module hello_world (
                    input logic i_clk
);
