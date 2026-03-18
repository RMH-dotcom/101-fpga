/* verilator lint_off DECLFILENAME */

// This script comprises of a two module design
// It will:
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

// Block 1: State machine (gated by baud_stb)
// if (i_wr && !o_busy) -> start
// else if (baud_stb)   -> advance state
// The state machine doesn't know about the counter at all -- it just waits for baud_stb to say "go!"

// Block 2: Data register (also gated by baud_stb)
// if (i_wr && !o_busy)  -> load data
// else if (baud_stb)    -> shift right

// Block 3: Counter
// if (i_wr && !o_busy)     -> reset counter, baud_stb = 0
// else if (!baud_stb)      -> count down
// else if (state != IDLE)  -> reload counter

// Important: Dan uses a 9-bit lcl_data (not 10). He loads {i_data, 1'b0}
// The start bit sits at position 0, and 1's shift in from the left naturally becoming the stop bit

module hello_world (
                    input logic       i_wr,
                    input logic       i_clk,
                    input logic [7:0] i_data, // 8-bit input
                    output logic      o_busy,
                    output logic      o_uart_tx
                    );
  // My FPGA ticks 100 million times per second. A UART receiver only expects 115200
  // bits per second. This number (868) is how many clock ticks must pass before I
  // send the next bit.
  parameter    CLOCKS_PER_BAUD = 868; // 100MHz / 115200 baud
  
  typedef enum logic [3:0] {
                IDLE = 4'b0000, // IDLE = 0
                START = 4'b0001, // START = 1
                LAST = 4'd10 // LAST = 10
                } state;
  state is_state ; // Declare state register (where I am in the transmission sequence)
 
  // Signal declarations
  logic [23:0] counter;
  logic [8:0] lcl_data;
  logic       baud_stb;
  
  // Store the byte to transit
  initial counter = 0;
  
  initial {o_busy, is_state} = {1'b0, IDLE}; // By default, set o_busy to off, and the state IDLE
  
// Block 3: Counter
// if (i_wr && !o_busy)     -> reset counter, baud_stb = 0
// else if (!baud_stb)      -> count down
// else if (state != IDLE)  -> reload counter
  always_ff @(posedge i_clk)
    if (i_wr && !o_busy) begin
      counter <= CLOCKS_PER_BAUD - 1'b1; // Begin counting down from 857
      baud_stb <= 1'b0; // Upon reaching 0, wait for receiver's signal
    end
    else if (!baud_stb) begin
      counter <= counter - 1'b1; // Keep counting down
      baud_stb <= (counter == 24'h1); // Has the counter hit 0 now?
    end
    else if (is_state != IDLE) // If baud tick fired in mid-transition,
      counter <= CLOCKS_PER_BAUD - 1'b1; // Reload the counter
endmodule // hello_world
