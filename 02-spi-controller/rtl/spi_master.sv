/* verilator lint_off DECLFILENAME */
module spi_master
  #(parameter SPI_MODE = 0,
    parameter CLKS_PER_HALF_BIT = 2)

  (
   // Master signals
   input       i_rest,
   input       i_clk,

   // TX (MOSI) signals
   input [7:0] i_tx_byte,
   input       i_tx_dv,
   output reg  o_tx_ready,

   // RX (MISO) signals
   output reg  o_spi_clk,
   input       i_spi_miso,
   output reg  o_spi_mosi
   );

  // SPI interface (all runs at SPI clock domain)
  wire w_cpol;
  wire w_cpha;

  reg [$clog2(clks_per_half_bit*2)-1:0] r_spi_clk_count;
  reg                                   r_spi_clk;
  reg [4:0]                             r_spi_clk_edges;
  reg                                   r_leading_edge;
  reg                                   r_trailing_edge;
  reg                                   r_tx_dv;
  reg [7:0]                             r_tx_byte;
  reg [2:0]                             r_rx_bit_count;
  reg [2:0]                             r_tx_bit_count;

  assign w_cpol = (spi_mode == 2) | (spi_mode == 3);
  assign w_cpha = (spi_mode == 1) | (spi_mode == 3);

  always_ff @(posedge i_clk or negedge i_rat_l) begin
  end
