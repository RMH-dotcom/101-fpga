/* verilator lint_off DECLFILENAME */
module spi_slave
  (
   input              i_cs_n,
   input              i_mosi,
   input              i_sclk,
   input              i_clk,
   input              i_rst_l,
   output logic [7:0] o_rx_byte,
   output logic       o_rx_dv,
   output logic       o_miso
   );
  reg [2:0] r_bit_count;
  reg [7:0] r_rx_byte;

  // Block 1: MOSI rx
  always_ff @(posedge i_sclk or negedge i_rst_l)
    begin
      if (!i_rst_l)
        begin
          r_bit_count <= 3'b0;
          r_rx_byte <= 8'b0;
          o_rx_dv <= 1'b0;
        end
      else
        if (i_cs_n == 1'b0) // if activated
          begin
            r_rx_byte <= {i_mosi, r_rx_byte[7:1]};
            r_bit_count <= r_bit_count + 1'b1;
          end
    end
endmodule
