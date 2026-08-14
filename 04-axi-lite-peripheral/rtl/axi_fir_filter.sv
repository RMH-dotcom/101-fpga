/* verilator lint_off DECLFILENAME */
module axi_fir_filter
  (
   // strb stands for strobe.
   // It's a 4-bit mask indicating which bytes of the 32-bit i_wdata are valid.

   // AXI-Lite data is always 32 bits wide, but sometimes we only want to write 1 or
   //  2 bytes. Each bit of i_wstrb corresponds to one byte:
   // - bit 0 → bytes [7:0]
   // - bit 1 → bytes [15:8]
   // - bit 2 → bytes [23:16]
   // - bit 3 → bytes [31:24]

   // i_wstrb = 4'b1111 means all 4 bytes are valid — the common case.
   // i_wstrb = 4'b0011 means only the lower 2 bytes are valid.

   // For this project we can ignore it and always treat all bytes as valid.
   // our registers are 16-bit and we'll just take i_wdata[15:0]

    input               i_clk,
    input               i_rst,   // keep active low to match the FIR

   // Write address channel (AW)
    input [31:0]        i_awaddr,
    input               i_awvalid,
    output logic        o_awready,

   // Write data channel (W)
    input [31:0]        i_wdata,
    input [3:0]         i_wstrb, // byte enables
    input               i_wvalid,
    output logic        o_wready,

   // Write response channel (B)
    output logic [1:0]  o_bresp,
    output logic        o_bvalid,
    input               i_bready,

   // Read address channel (AR)
    input [31:0]        i_araddr,
    input               i_arvalid,
    output logic        o_arready,

   // Read data channel (R)
    output logic [31:0] o_rdata,
    output logic [1:0]  o_rresp,
    output logic        o_rvalid,
    input               i_rready
   );
  logic               l_coeff_we;
  logic [3:0]         l_coeff_addr;
  logic signed [15:0] l_coeff_data;
  logic signed [15:0] l_sample; // the sample register written by AW/W
  logic signed [15:0] l_result; //wired from FIR's o_result

  // The factory: fir_filter mining outpost
  fir_filter u_fir_filter
    (
     .i_clk (i_clk),
     .i_rst (i_rst),
     .i_coeff_we (l_coeff_we),
     .i_coeff_addr (l_coeff_addr),
     .i_coeff_data (l_coeff_data),
     .i_sample (l_sample),
     .o_result (l_result)
    );

  // Block 1: Write Address (AW) & Write data (W)
  // 1. On reset: clear sample, coeff_we, and all AW/W/B outputs
  // 2. On i_awvalid & i_wvalid: decode i_awaddr, route i_wdata to l_sample or coeff
  // registers, acknowledge with o_awready/o_wready/o_bvalid
  always_ff @(posedge i_clk)
    begin
      if (!i_rst)
        begin
          l_sample <= 1'b0;
          l_coeff_we <= 1'b0;
          o_awready <= 1'b0;
          o_wready <= 1'b0;
          o_bvalid <= 1'b0;
          o_bresp <= 2'b00;
        end
      else
        if (i_awvalid && i_wvalid)
          begin
            o_awready <= 1'b1;
            o_wready <= 1'b1;
            o_bvalid <= 1'b1;
            o_bresp <= 2'b00;

            case (i_awaddr)
              32'h00:
                begin
                  l_sample <= i_wdata[15:0];
                  l_coeff_we <= 1'b0;
                end
              32'h08:
                begin
                  l_coeff_addr <= 4'd0;
                  l_coeff_data <= i_wdata[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h0C:
                begin
                  l_coeff_addr <= 4'd1;
                  l_coeff_data <= i_wdata[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h10:
                begin
                  l_coeff_addr <= 4'd2;
                  l_coeff_data <= i_wdata[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h14:
                begin
                  l_coeff_addr <= 4'd3;
                  l_coeff_data <= i_wdata[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h18:
                begin
                  l_coeff_addr <= 4'd4;
                  l_coeff_data <= i_wdata[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h1C:
                begin
                  l_coeff_addr <= 4'd5;
                  l_coeff_data <= i_wdata[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h20:
                begin
                  l_coeff_addr <= 4'd6;
                  l_coeff_data <= i_wdata[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h24:
                begin
                  l_coeff_addr <= 4'd7;
                  l_coeff_data <= i_wdata[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h28:
                begin
                  l_coeff_addr <= 4'd8;
                  l_coeff_data <= i_wdata[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h2C:
                begin
                  l_coeff_addr <= 4'd9;
                  l_coeff_data <= i_wdata[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h30:
                begin
                  l_coeff_addr <= 4'd10;
                  l_coeff_data <= i_wdata[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h34:
                begin
                  l_coeff_addr <= 4'd11;
                  l_coeff_data <= i_wdata[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h38:
                begin
                  l_coeff_addr <= 4'd12;
                  l_coeff_data <= i_wdata[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h3C:
                begin
                  l_coeff_addr <= 4'd13;
                  l_coeff_data <= i_wdata[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h40:
                begin
                  l_coeff_addr <= 4'd14;
                  l_coeff_data <= i_wdata[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h44:
                begin
                  l_coeff_addr <= 4'd15;
                  l_coeff_data <= i_wdata[15:0];
                  l_coeff_we <= 1'b1;
                end
              default: l_coeff_we <= 1'b0;
            endcase
          end
    end
