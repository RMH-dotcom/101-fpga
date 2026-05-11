/* verilator lint_off DECLFILENAME */
module spi_top
  #(parameter clks_per_half_bit = 2)
  (
   input              i_clk,
   input              i_rst_l,
   input [7:0]        i_tx_byte,
   input              i_tx_dv,
   output logic       o_tx_ready,
   output logic       o_rx_dv,
   output logic [7:0] o_slave_rx_byte
   );

  wire        w_cs_n;
  wire        w_sclk;
  wire        w_mosi;
  wire        w_miso;

  spi_master #(.clks_per_half_bit(clks_per_half_bit)) u_master
    (
     .i_clk      (i_clk),
     .i_rst_l    (i_rst_l),
     .i_tx_byte  (i_tx_byte),
     .i_tx_dv    (i_tx_dv),
     .o_tx_ready (o_tx_ready),
     /* verilator lint_off PINCONNECTEMPTY */
     .o_rx_byte  (),
     .o_rx_dv    (),
     /* verilator lint_on PINCONNECTEMPTY */
     .o_cs_n     (w_cs_n),
     .o_sclk     (w_sclk),
     .o_mosi     (w_mosi),
     .i_miso     (w_miso)
     );

  spi_slave u_slave
    (
     .i_clk     (i_clk),
     .i_rst_l   (i_rst_l),
     .i_cs_n    (w_cs_n),
     .i_sclk    (w_sclk),
     .i_mosi    (w_mosi),
     .o_miso    (w_miso),
     .o_rx_byte (o_slave_rx_byte),
     .o_rx_dv   (o_rx_dv)
     );

endmodule
