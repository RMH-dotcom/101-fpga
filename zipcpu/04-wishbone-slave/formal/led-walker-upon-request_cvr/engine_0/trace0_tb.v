`ifndef VERILATOR
module testbench;
  reg [4095:0] vcdfile;
  reg clock;
`else
module testbench(input clock, output reg genclock);
  initial genclock = 1;
`endif
  reg genclock = 1;
  reg [31:0] cycle = 0;
  reg [0:0] PI_i_wb_stb;
  reg [0:0] PI_i_clk;
  reg [0:0] PI_i_wb_we;
  led_walker_upon_request UUT (
    .i_wb_stb(PI_i_wb_stb),
    .i_clk(PI_i_clk),
    .i_wb_we(PI_i_wb_we)
  );
`ifndef VERILATOR
  initial begin
    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
    #5 clock = 0;
    while (genclock) begin
      #5 clock = 0;
      #5 clock = 1;
    end
  end
`endif
  initial begin
`ifndef VERILATOR
    #1;
`endif
    // UUT.$auto$async2sync.\cc:101:execute$46  = 1'b0;
    // UUT.$auto$async2sync.\cc:110:execute$50  = 1'b1;
    UUT.led_index = 4'b0000;

    // state 0
    PI_i_wb_stb = 1'b0;
    PI_i_clk = 1'b0;
    PI_i_wb_we = 1'b0;
  end
  always @(posedge clock) begin
    // state 1
    if (cycle == 0) begin
      PI_i_wb_stb <= 1'b0;
      PI_i_clk <= 1'b0;
      PI_i_wb_we <= 1'b0;
    end

    // state 2
    if (cycle == 1) begin
      PI_i_wb_stb <= 1'b0;
      PI_i_clk <= 1'b0;
      PI_i_wb_we <= 1'b0;
    end

    // state 3
    if (cycle == 2) begin
      PI_i_wb_stb <= 1'b0;
      PI_i_clk <= 1'b0;
      PI_i_wb_we <= 1'b0;
    end

    // state 4
    if (cycle == 3) begin
      PI_i_wb_stb <= 1'b0;
      PI_i_clk <= 1'b0;
      PI_i_wb_we <= 1'b0;
    end

    genclock <= cycle < 4;
    cycle <= cycle + 1;
  end
endmodule
