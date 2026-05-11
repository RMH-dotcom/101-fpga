#include <stdio.h>
#include "Vspi_top.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main() {
  VerilatedContext *contextp = new VerilatedContext;
  Vspi_top *dut = new Vspi_top(contextp, "TOP");

  // Enable tracing
  contextp->traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;
  dut->trace(tfp, 99);
  tfp->open("spi.vcd");
  
  // Reset: start high, pull low (creates negedge), release high
  dut->i_clk   = 0;
  dut->i_rst_l = 1;
  dut->eval();
  dut->i_rst_l = 0;
  dut->eval();
  dut->i_rst_l = 1;
  dut->eval();

  // Load byte to send
  dut->i_tx_byte = 0xAB;
  dut->i_tx_dv   = 1;
  dut->eval();

  // Run clock for 64 cycles
  for (int i = 0; i < 64; i++) {
    contextp->timeInc(1);
    dut->i_clk = 1;
    dut->eval();
    tfp->dump(contextp->time());
    if (i == 0) dut->i_tx_dv = 0;
    contextp->timeInc(1);
    dut->i_clk = 0;
    dut->eval();
    tfp->dump(contextp->time());
  }
  tfp->close();

  printf("Received: 0x%02X\n", (int)dut->o_slave_rx_byte);
  if (dut->o_slave_rx_byte == 0xAB)
    printf("PASS\n");
  else
    printf("FAIL\n");

  return 0;
}
