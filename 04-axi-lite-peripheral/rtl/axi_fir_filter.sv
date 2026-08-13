/* verilator lint_off DECLFILENAME */
module axi_fir_filter
  (
   input              i_clk,
   input              i_rst,   // keep active low to match the FIR

   // Write address channel (AW)
   input [31:0]       i_awaddr,
   input              i_awvalid,
   output logic       o_awready,

   // Write data channel (W)
   input [31:0]       i_wdata,
   input [3:0]        i_wstrb, // byte enables
   input              i_wvalid,
   output logic       i_wready,

   // Write response channel (B)
   output logic [1:0] o_bresp,
   output logic o_bvalid,
   input i_bready,

   // Read address channel (AR)
   input [31:0] i_araddr,
   input i_arvalid,
   output logic o_arready,

   // Read data channel (R)
   output logic [31:0] o_rdata,
   output logic [1:0] o_rresp,
   output logic o_rvalid,
   input i_rready
   );
  logic               l_coeff_we;
  logic [3:0]         l_coeff_addr;
  logic signed [15:0] l_coeff_data;
  logic signed [15:0] l_sample; // the sample register written by AW/W
  logic signed [15:0] l_result; //wired from FIR's o_result

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
