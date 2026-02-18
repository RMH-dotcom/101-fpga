// verilator testbench
// We need to toggle the clock input for anything to happen

#include <cstdint>
#include <stdio.h>
#include <stdlib.h>
#include "verilated.h"
#include "Vblinky.h"
#include "verilated_vcd_c.h"

void tick(Vblinky *tb, VerilatedVcdC *trace, uint64_t &tickcount) {
  tickcount++;

      tb->eval();
      if (trace) trace->dump(tickcount * 10 - 2);

      tb->i_clk = 1;
      tb->eval();
      if (trace) trace->dump(tickcount * 10);

      tb->i_clk = 0;
      tb->eval();
      if (trace)
        trace->dump(tickcount * 10 + 5);
      if (trace)
        trace->flush();      
  }

  int main(int argc, char **argv) {
      Verilated::commandArgs(argc, argv);
      Verilated::traceEverOn(true);
      Vblinky *tb = new Vblinky;

      VerilatedVcdC *trace = new VerilatedVcdC;
      tb->trace(trace, 99);
      trace->open("build/blinky.vcd");

      uint64_t tickcount = 0;
      int last_led = tb->o_led;

      for (int k = 0; k < (1 << 12); k++) {
          tick(tb, trace, tickcount);

          if (last_led != tb->o_led) {
              printf("k = %7d, led = %d\n", k, tb->o_led);
          }
          last_led = tb->o_led;
      }

      trace->close();
      delete trace;
      delete tb;
      return 0;
  }
