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
  reg       r_sclk_prev;
  wire      w_sclk_rise = i_sclk && !r_sclk_prev;

  // Block 1: MOSI rx
  always_ff @(posedge i_clk or negedge i_rst_l)
    begin
      if (!i_rst_l)
        begin
          r_bit_count <= 3'b0;
          r_rx_byte   <= 8'b0;
          o_rx_dv     <= 1'b0;
          r_sclk_prev <= 1'b0;
        end
      else
        begin
          r_sclk_prev <= i_sclk;
          if (i_cs_n == 1'b0 && w_sclk_rise)
            begin
              r_rx_byte   <= {r_rx_byte[6:0], i_mosi};
              r_bit_count <= r_bit_count + 1'b1;
              if (r_bit_count == 7)
                o_rx_dv <= 1'b1;
              else
                o_rx_dv <= 1'b0;
            end
        end
    end // always_ff @ (posedge i_sclk or negedge i_rst_l)

  // Block 2: MISO tx
  assign o_miso = 1'b0;
  assign o_rx_byte = r_rx_byte;
endmodule
