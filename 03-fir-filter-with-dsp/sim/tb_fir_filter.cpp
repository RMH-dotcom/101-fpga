#include <stdio.h>
#include "Vfir_filter.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main() {
  VerilatedContext *contextp = new VerilatedContext;
  Vfir_filter *dut = new Vfir_filter(contextp, "TOP");

  // Tracing
  contextp->traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  dut->trace(tfp, 99);
  tfp->open("fir.vcd");

  // Reset: pull data at low. i_rst = 0 | !i_rst = 1
  dut->i_rst = 0; // assert reset
  dut->i_clk = 0;
  dut->eval();

  dut->i_rst = 1; // release reset
  dut->eval();

  dut->i_sample = 0x8000;

  // Run clock for 40 cycles
  // 1. Advance time by 1
  // 2. Set clock high, eval, clear input to 0 on the first cycle, dump trace
  // 3. Advance time by 1
  // 4. Set clock low, eval, dump trace
  for (int i = 0; i < 40; i++) {
    contextp-> timeInc(1);
    dut->i_clk = 1;
    dut->eval();
    if(i==0) dut->i_sample = 0;
    tfp->dump(contextp->time());

    contextp->timeInc(1);
    dut->i_clk = 0;
    dut->eval();
    tfp->dump(contextp->time());

    // PASS/FAIL check
    if (i >= 2 && i <= 17) {
      if (dut->o_result == 2048)
        printf("Cycle %d: PASS: Got 2048\n", i);
      else
        printf("Cycle %d: FAIL: expected 2048, got %d\n", i, dut->o_result);
    } else {
      if (dut->o_result == 0)
        printf("Cycle %d: PASS: Got 0\n", i);
      else
        printf("Cycle %d: FAIL: expected 0, got %d\n", i, dut->o_result);
    }
  }
  
  tfp->close();
  delete dut;
  delete tfp;
  delete contextp;
  return 0;
}
