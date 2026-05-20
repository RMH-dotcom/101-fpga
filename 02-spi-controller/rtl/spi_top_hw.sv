/* verilator lint_off DECLFILENAME */
module spi_top_hw
  #(parameter clks_per_half_bit = 2)
  (
   input        i_clk,
   input        i_rst_l,
   input [3:0]  i_tx_byte,
   input        i_tx_dv,
   output logic o_tx_ready,
   output logic o_rx_dv,
   output       o_cs_n,
   output       o_sclk,
   output       o_mosi,
   input        i_miso
   );

  spi_master #(.clks_per_half_bit(clks_per_half_bit)) u_master
    (
     .i_clk      (i_clk),
     .i_rst_l    (i_rst_l),
     .i_tx_byte  ({4'b0, i_tx_byte}),
     .i_tx_dv    (i_tx_dv),
     .o_tx_ready (o_tx_ready),
     /* verilator lint_off PINCONNECTEMPTY */
     .o_rx_byte  (),
     .o_rx_dv    (),
     /* verilator lint_on PINCONNECTEMPTY */
     .o_cs_n     (o_cs_n),
     .o_sclk     (o_sclk),
     .o_mosi     (o_mosi),
     .i_miso     (i_miso)
     );
endmodule
