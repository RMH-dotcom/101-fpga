/* verilator lint_off DECLFILENAME */
/* verilator lint_off UNUSEDSIGNAL */
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
    input               i_rst,         // keep active low to match the FIR

   // Write address channel (AW)
    input [31:0]        i_awaddr,
    input               i_awvalid,
    output logic        o_awready,

   // Write data channel (W)
    input [31:0]        i_wdata,
    input [3:0]         i_wstrb,       // byte enables
    input               i_wvalid,
    output logic        o_wready,

   // Write response channel (B)
    output logic [1:0]  o_bresp,
    output logic        o_bvalid,
    input               i_bready,

   // Read address channel (AR)
    input [31:0]        i_araddr,      // from AXI request
    input               i_arvalid,     // "DONE" from AXI request
    output logic        o_arready,     // from AXI request

   // Read data channel (R)
    output logic [31:0] o_rdata,       // from FIR
    output logic [1:0]  o_rresp,
    output logic        o_rvalid,      // "DONE" from FIR
    input               i_rready       // "ACKNOWLEDGE" from AXI
   );
  logic               l_coeff_we;
  logic [3:0]         l_coeff_addr;
  logic signed [15:0] l_coeff_data;
  logic signed [15:0] l_sample; // the sample register written by AW/W
  logic signed [15:0] l_result; //wired from FIR's o_result

  // Internal staging registers for independent write tracks
  logic               l_awready_reg; // AW has arrived, waiting for W
  logic [31:0]        l_awaddr_reg;  // holds i_awaddr until W arrives
  logic               l_wready_reg;  // W has arrived, waiting for AW
  logic [31:0]        l_wdata_reg;   // holds i_wdata until AW arrives

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

  // Block 1: Write Address (AW), Write data (W) & Write Response (B)
  always_ff @(posedge i_clk)
    if (!i_rst)
      begin
        o_wready <= 1'b0;
        o_awready <= 1'b0;
        l_wready_reg <= 1'b0;
        l_awready_reg <= 1'b0;
        l_awaddr_reg <= '0;
        l_wdata_reg <= '0;
        o_bvalid <= 1'b0;
        o_bresp <= 2'b00;
        l_sample <= '0;
        l_coeff_we <= 1'b0;
        l_coeff_addr <= '0;
        l_coeff_data <= '0;
      end // if (!i_rst)
    else
      begin
        // Default strobes down unless intentionally fired
        l_coeff_we <= 1'b0;

        // Phase 1 (AW): when o_awready = 1'b1, save the address into l_awaddr_reg
        if (!l_awready_reg && i_awvalid)
          begin
            l_awready_reg <= 1'b1;
            l_awaddr_reg <= i_awaddr;
            o_awready <= 1'b1;
          end
        else
          o_awready <= 1'b0;

        // Phase 2 (W): when o_wready 1'b1, we save the cargo data into l_wdata_reg
        if (!l_wready_reg && i_wvalid)
          begin
            l_wready_reg <= 1'b1;
            l_wdata_reg <= i_wdata;
            o_wready <= 1'b1;
          end
        else
          o_wready <= 1'b0;

        // when o_bvalid && i_bready = 1'b1, clear
        if (o_bvalid && i_bready)
          o_bvalid <= 1'b0;

        //Phase 3 (B): when l_awready_reg && l_wready_reg = 1'b1, write
        if (l_awready_reg && l_wready_reg && !o_bvalid)
          begin
            o_bvalid <= 1'b1;
            l_awready_reg <= 1'b0; // clear AW ready
            l_wready_reg <= 1'b0; // clear W ready

            case (l_awaddr_reg)
              32'h00: l_sample <= l_wdata_reg[15:0];
              32'h08:
                begin
                  l_coeff_addr <= 4'd0;
                  l_coeff_data <= l_wdata_reg[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h0C:
                begin
                  l_coeff_addr <= 4'd1;
                  l_coeff_data <= l_wdata_reg[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h10:
                begin
                  l_coeff_addr <= 4'd2;
                  l_coeff_data <= l_wdata_reg[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h14:
                begin
                  l_coeff_addr <= 4'd3;
                  l_coeff_data <= l_wdata_reg[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h18:
                begin
                  l_coeff_addr <= 4'd4;
                  l_coeff_data <= l_wdata_reg[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h1C:
                begin
                  l_coeff_addr <= 4'd5;
                  l_coeff_data <= l_wdata_reg[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h20:
                begin
                  l_coeff_addr <= 4'd6;
                  l_coeff_data <= l_wdata_reg[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h24:
                begin
                  l_coeff_addr <= 4'd7;
                  l_coeff_data <= l_wdata_reg[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h28:
                begin
                  l_coeff_addr <= 4'd8;
                  l_coeff_data <= l_wdata_reg[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h2C:
                begin
                  l_coeff_addr <= 4'd9;
                  l_coeff_data <= l_wdata_reg[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h30:
                begin
                  l_coeff_addr <= 4'd10;
                  l_coeff_data <= l_wdata_reg[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h34:
                begin
                  l_coeff_addr <= 4'd11;
                  l_coeff_data <= l_wdata_reg[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h38:
                begin
                  l_coeff_addr <= 4'd12;
                  l_coeff_data <= l_wdata_reg[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h3C:
                begin
                  l_coeff_addr <= 4'd13;
                  l_coeff_data <= l_wdata_reg[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h40:
                begin
                  l_coeff_addr <= 4'd14;
                  l_coeff_data <= l_wdata_reg[15:0];
                  l_coeff_we <= 1'b1;
                end
              32'h44:
                begin
                  l_coeff_addr <= 4'd15;
                  l_coeff_data <= l_wdata_reg[15:0];
                  l_coeff_we <= 1'b1;
                end
              default: l_coeff_we <= 1'b0;
            endcase
          end
      end // else: !if(!i_rst)

  // Block 2: Read Address (AR) & Read Data (R)
  always_ff @(posedge i_clk)
    if (!i_rst)
      begin
        o_arready <= 1'b0;
        o_rdata <= '0;
        o_rvalid <= 1'b0;
        o_rresp <= 2'b00;
      end
    else
      begin
        if (o_rvalid && i_rready)
          begin
            o_rvalid <= 1'b0;
            o_arready <= 1'b0;
          end

        if (i_arvalid && !o_rvalid)
          begin
            o_arready <= 1'b1;
            o_rvalid <= 1'b1;
            o_rresp <= 2'b00;
            case (i_araddr)
              32'h04: o_rdata <= {{16{l_result[15]}}, l_result};
              default: o_rdata <= '0;
            endcase
          end
      end

  // -- IN FACTORIO TERMS --

  // Step 1: l_result 16-bit to 32-bit
  // l_result is a 16-bit signed integer.
  // However, the AXI-Lite Read Data Bus (o_rdata) is 32 bits wide.
  // We can't just place a 16-bit block into a 32-bit cargo wagon without securing it
  // or the signed bit formatting will break.
  // {{16{l_result[15]}}, l_result} will replicate the sign bit (bit 15) 16x to fill
  // the upper half of the cargo wagon.
  // -5(16'hFFFB) safely becomes -5 in 32-bit format (32'hFFFFFFFB).


  // Step 2: Read Address Request (AR Phase)
  // The AXI wrapper sends a schedule (request) train to pick up cargo:
  //
  // Inputs active:
  // The combinator for train i_araddr fires the target reg address 32'h04,
  // and throws the i_arvalid switch high.
  // "The train is ready, and the address is stable".
  //
  // Wrapper action:
  // The AXI wrapper reads i_araddr. If it matchs 32'h04, it prepares the cargo.
  // The AXI wrapper fires the o_arready output high for exactly one clock cycle.
  // "I've acknowledged your request train. It may leave the station."

  // Step 3: Read (R) Phase
  // A unloading train is sent from the wrapper to l_result:
  //
  // Outputs active:
  // An inserter loads the sign-extended data (32'hFFFFFFFB) from the l_result chest
  // into the o_rdata cargo wagon, on the train.
  // l_result 's combinator throws the o_rvalid switch HIGH.
  // "The shipping cargo is sitting on the cargo wagon right now"
  // o_rvalid && i_rready must both = HIGH.
  //
  // On the exactly clock edge where both o_rvalid and i_rready are HIGH simultaneously,
  // the Master's internal input registers snapshot (latch) the 32-bit 'o_rdata' value.
  // In the very next cycle, the wrapper must lower 'o_rvalid' to clear the track,
  // and it must also lower 'o_rvalid' (or 'o_rresp') to conclude the transaction.
endmodule // axi_fir_filter
