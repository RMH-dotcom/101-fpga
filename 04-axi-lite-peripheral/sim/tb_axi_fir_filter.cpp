#include "Vaxi_fir_filter.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <cstdint>
#include <stdio.h>

void tick(Vaxi_fir_filter *dut, VerilatedVcdC *tfp,
          VerilatedContext *contextp) {
  dut->i_clk = 0;
  dut->eval();
  tfp->dump(contextp->time());
  contextp->timeInc(1);
  dut->i_clk = 1;
  dut->eval();
  tfp->dump(contextp->time());
  contextp->timeInc(1);
}

void axi_write(Vaxi_fir_filter *dut, VerilatedVcdC *tfp,
               VerilatedContext *contextp, uint32_t addr, uint32_t data) {
  dut->i_awaddr = addr;
  dut->i_awvalid = 1;
  dut->i_wdata = data;
  dut->i_wstrb = 0xF;
  dut->i_wvalid = 1;

  // Tick until both awready and wready are high
  while (!(dut->o_awready && dut->o_wready))
    tick(dut, tfp, contextp);
  tick(dut, tfp, contextp); // one more to let the slave process

  // Deasset AW and W
  dut->i_awvalid = 0;
  dut->i_wvalid = 0;

  // Wait for bvalid, then assert bready
  while (!dut->o_bvalid)
    tick(dut, tfp, contextp);
  dut->i_bready = 1;
  tick(dut, tfp, contextp);
  dut->i_bready = 0;
}

int main() {
  // Reset
  // Load coefficients: for each of the 16 firwin coefficients, drive a write
  // transaction to the correct address (0x08 through 0x44) Stream samples and
  // read results: drive i_sample writes to 0x00 and read o_result from 0x04
  VerilatedContext *contextp = new VerilatedContext;
  Vaxi_fir_filter *dut = new Vaxi_fir_filter(contextp, "TOP");

  // Tracing
  contextp->traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  dut->trace(tfp, 99);
  tfp->open("axi_fir.vcd");

  // Test block 1: Call axi_write 16 times to load coefficients
  // As in, addresses 0x08 through 0x44, data from the firwin array (like the
  // FIR tb)
  //
  // Reset: pull data at low. i_rst = 0 | !i_rst = 1
  dut->i_rst = 0; // assert reset
  dut->i_clk = 0;
  dut->eval();

  dut->i_clk = 1; // posedge fires always_ff with reset asserted
  dut->eval();
  dut->i_clk = 0;
  dut->eval();

  dut->i_rst = 1; // release reset
  dut->eval();

  int16_t coeff[16] = {
    -169, -439, -573, 0,    1285, 3376, 5974, 8038,
    8038, 5974, 3376, 1285, 0,    -573, -439, -169
  };

  axi_write(dut, tfp, contextp, 0x08, coeff[0]);
  axi_write(dut, tfp, contextp, 0x0C, coeff[1]);
  axi_write(dut, tfp, contextp, 0x10, coeff[2]);
  axi_write(dut, tfp, contextp, 0x14, coeff[3]);
  axi_write(dut, tfp, contextp, 0x18, coeff[4]);
  axi_write(dut, tfp, contextp, 0x1C, coeff[5]);
  axi_write(dut, tfp, contextp, 0x20, coeff[6]);
  axi_write(dut, tfp, contextp, 0x24, coeff[7]);
  axi_write(dut, tfp, contextp, 0x28, coeff[8]);
  axi_write(dut, tfp, contextp, 0x2C, coeff[9]);
  axi_write(dut, tfp, contextp, 0x30, coeff[10]);
  axi_write(dut, tfp, contextp, 0x34, coeff[11]);
  axi_write(dut, tfp, contextp, 0x38, coeff[12]);
  axi_write(dut, tfp, contextp, 0x3C, coeff[13]);
  axi_write(dut, tfp, contextp, 0x40, coeff[14]);
  axi_write(dut, tfp, contextp, 0x44, coeff[15]);

  // Test block 2: Call axi_write once to write the impulse 0x7FFF to 0x00
  axi_write(dut, tfp, contextp, 0x00, 0x7FFF);
  axi_write(dut, tfp, contextp, 0x00, 0x0000); // clear sample

  // Test block 3: Loop 32 cycles: each cycle drive i_arvalid=1, i_araddr=0x04,
  // i_rready=1, tick, read o_rdata, compare against the golden reference
  int32_t expected[32] = {
    0,    -85,  -54,  122,  699,  1816, 3330, 4813,
    5737, 5737, 4813, 3330, 1816, 699,  122,  -54,
    -85,  0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0
  };

  for (int i = 0; i < 32; i++) {
    dut->i_arvalid = 1;
    dut->i_araddr = 0x04;
    dut->i_rready = 1;

    while (!dut->o_rvalid)
      tick(dut, tfp, contextp);
    
    int32_t result = (int32_t)dut->o_rdata;
    dut->i_arvalid = 0;
    tick(dut, tfp, contextp);
      
    if (result == expected[i])
      printf("Cycle %d: PASS: Got %d\n", i, result);
    else
      printf("Cycle %d: FAIL: expected %d, got %d\n", i, expected[i], result);
  }
}
