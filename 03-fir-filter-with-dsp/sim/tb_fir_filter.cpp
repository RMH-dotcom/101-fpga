#include <cstdint>
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

  dut->i_clk = 1;  // posedge fires always_ff with reset asserted
  dut->eval();
  dut->i_clk = 0;
  dut->eval();

  dut->i_rst = 1; // release reset
  dut->eval();

  // golden_ref
  // The coefficient memory is a chest with 16 slots. i_coeff_addr is which slot
  // number you're pointing at.
  // i_coeff_data is the item you're holding. i_coeff_we is the "insert" button — nothing goes in until you press it.

  // To stock all 16 slots, you stand in front of the chest, point at slot 0,
  // hold item 0, press insert, then point at slot 1, hold item 1, press insert
  // — 16 times in a row. Each "press insert" is one clock edge with i_coeff_we
  // = 1.  

// Once all slots are stocked, you lower the insert button (i_coeff_we = 0) and start the conveyor belt (i_sample = 0x7FFF).
  int16_t h[16] = {
    -169,
    -107,
    245,
    1400,
    3634,
    6662,
    9628,
    11475,
    11475,
    9628,
    6662,
    3634,
    1400,
    245,
    -107,
    -169
  };

  for (int i = 0; i < 16; i++) {
    dut->i_coeff_we   = 1;     // Turn the "Write Enable" switch ON
    dut->i_coeff_addr = i;     // Set the destination station address index (0 to 15)
    dut->i_coeff_data = h[i]; // Drop your signed recipe integer onto the data wire

    // Drive the Falling Edge of the Clock    
    dut->i_clk = 0;
    contextp->timeInc(1);      // Move world time forward by 1 tick
    dut->eval();               // Hit Enter! Wires stabilize

    // Drive the Rising Edge of the Clock
    dut->i_clk = 1;
    contextp->timeInc(1);      // Move world time forward by 1 tick
    dut->eval();
  }
  dut->i_coeff_we = 0;
  dut->i_sample = 0x7FFF;

  dut->i_clk = 0;
  dut->eval();

  int16_t expected[40] = {
    0,
    -85,
    -54,
    122,
    699,
    1816,
    3330,
    4813,
    5737,
    5737,
    4813,
    3330,
    1816,
    699,
    122,
    -54,
    -85
  };
  
  // Run clock for 40 cycles
  // 1. Advance time by 1
  // 2. Set clock high, eval, clear input to 0 on the first cycle, dump trace
  // 3. Advance time by 1
  // 4. Set clock low, eval, dump trace
  for (int i = 0; i < 40; i++) {
    contextp-> timeInc(1);
    dut->i_clk = 1;
    dut->eval();
    tfp->dump(contextp->time());
    if(i==0) dut->i_sample = 0;

    contextp->timeInc(1);
    dut->i_clk = 0;
    dut->eval();
    tfp->dump(contextp->time());

    // PASS/FAIL check
    if ((int16_t)dut->o_result == expected[i])
      printf("Cycle %d: PASS: Got %d\n", i, expected[i]);
    else
      printf("Cycle %d: FAIL: expected %d, got %d\n", i, expected[i], (int16_t)dut->o_result);
  }
  
  tfp->close();
  delete dut;
  delete tfp;
  delete contextp;
  return 0;
}
