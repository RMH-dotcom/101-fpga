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

  // Test block 1  
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
    dut->i_coeff_we = 1;
    dut->i_coeff_addr = i;
    dut->i_coeff_data = h[i];

    dut->i_clk = 0;
    contextp->timeInc(1);
    dut->eval();

    dut->i_clk = 1;
    contextp->timeInc(1);
    dut->eval();
  }
  dut->i_coeff_we = 0;
  dut->i_sample = 0x7FFF;

  // coeff loop ends clk high
  // pull low so main loop's first rising edge is true  
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

  // Test block 2
  dut->i_rst = 0; // assert reset
  dut->i_clk = 0;
  dut->eval();

  dut->i_clk = 1;  // posedge fires always_ff with reset asserted
  dut->eval();
  dut->i_clk = 0;
  dut->eval();

  dut->i_rst = 1; // release reset
  dut->eval();

  int16_t h_ramp[16] = {
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
  };

  for (int i = 0; i < 16; i++) {
    dut->i_coeff_we = 1;
    dut->i_coeff_addr = i;
    dut->i_coeff_data = h_ramp[i];

    dut->i_clk = 0;
    contextp->timeInc(1);
    dut->eval();

    dut->i_clk = 1;
    contextp->timeInc(1);
    dut->eval();
  }
  dut->i_coeff_we = 0;
  dut->i_sample = 0x7FFF;

  // coeff loop ends clk high
  // pull low so main loop's first rising edge is true  
  dut->i_clk = 0;
  dut->eval();

  int16_t ramp_expected[20] = {
    0,
    0,
    0,
    1,
    1,
    2,
    2,
    3,
    3,
    4,
    4,
    5,
    5,
    6,
    6,
    7,
    7,
    0,
    0,
    0
    };

for (int i = 0; i < 20; i++) {
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
    if ((int16_t)dut->o_result == ramp_expected[i])
      printf("Cycle %d: PASS: Got %d\n", i, ramp_expected[i]);
    else
      printf("Cycle %d: FAIL: expected %d, got %d\n", i, ramp_expected[i], (int16_t)dut->o_result);
  }

  // Test block 3
 dut->i_rst = 0; // assert reset
 dut->i_clk = 0;
 dut->eval();
 
 dut->i_clk = 1;  // posedge fires always_ff with reset asserted
 dut->eval();
 dut->i_clk = 0;
 dut->eval();

 dut->i_rst = 1; // release reset
 dut->eval();

 int16_t stream_in[56] = {
   23654,
   -16973,
   -31908,
   5390,
   29802,
   21575,
   11964,
   -21484,
   22118,
   -26503,
   -15918,
   29910,
   4426,
   -10806,
   14423,
   28020,
   11363,
   27495,
   -16745,
   8322,
   -31083,
   32052,
   -31999,
   26967,
   30187,
   32157,
   23333,
   -30335,
   -27457,
   5051,
   6420,
   -15200,
   20939,
   -12999,
   -4075,
   -26372,
   29419,
   -5288,
   32304,
   8666,
   0,
   0,
   0,
   0,
   0,
   0,
   0,
   0,
   0,
   0,
   0,
   0,
   0,
   0,
   0,
   0
   };

 for (int i = 0; i < 16; i++) {
   dut->i_coeff_we = 1;
   dut->i_coeff_addr = i;
   dut->i_coeff_data = h[i];

   dut->i_clk = 0;
   contextp->timeInc(1);
   dut->eval();

   dut->i_clk = 1;
   contextp->timeInc(1);
   dut->eval();
 }
 dut->i_coeff_we = 0;
 
 // coeff loop ends clk high
 // pull low so main loop's first rising edge is true  
 dut->i_clk = 0;
 dut->eval();

 int16_t stream_expected[56] = {
   0,
   -61,
   5,
   198,
   480,
   744,
   697,
   140,
   -544,
   -834,
   141,
   2210,
   4577,
   6222,
   6170,
   4355,
   1782,
   -64,
   -485,
   877,
   3463,
   6694,
   9399,
   11160,
   10964,
   9193,
   6102,
   2950,
   1394,
   2175,
   5137,
   9005,
   11757,
   11650,
   8827,
   4148,
   -239,
   -3277,
   -4023,
   -3768,
   -3005,
   -2386,
   -1563,
   84,
   2523,
   5209,
   7227,
   7794,
   6745,
   4833,
   2722,
   1170,
   238,
   -7,
   -98,
   -23
   };

 // Run clock for 56 cycles
 // 1. Advance time by 1
 // 2. Set clock high, eval, clear input to 0 on the first cycle, dump trace
 // 3. Advance time by 1
 // 4. Set clock low, eval, dump trace

 for (int i = 0; i < 56; i++) {
   dut->i_sample = stream_in[i];   
   contextp-> timeInc(1);
   dut->i_clk = 1;
   dut->eval();
   tfp->dump(contextp->time());
   
   contextp->timeInc(1);
   dut->i_clk = 0;
   dut->eval();
   tfp->dump(contextp->time());

   // PASS/FAIL check
   if ((int16_t)dut->o_result == stream_expected[i])
     printf("Cycle %d: PASS: Got %d\n", i, stream_expected[i]);
   else
     printf("Cycle %d: FAIL: expected %d, got %d\n", i, stream_expected[i], (int16_t)dut->o_result);
 }
  
 tfp->close();
 delete dut;
 delete tfp;
 delete contextp;
 return 0;
}
