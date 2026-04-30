#include <cstdint>
#include <stdio.h>
#include <stdlib.h>
#include "verilated.h"
#include "Vtx_uart.h"

int main(int arg, char **argv) { // take inputs
  // Using VerilatedContext as a bp, build a room in the RAM, and name it contextp.
  VerilatedContext *contextp = new VerilatedContext;

  // Using Vtx_uart as a bp, build a second room, but in the chip, and use the
  // rules from the room I named contextp,
  // and I am naming this new room (chip) dut.
  Vtx_uart *dut = new Vtx_uart{contextp};

  dut->i_data = 0x55; // Carry this byte.
  dut->i_wr = 1;      // Prime the trigger (i_wr). Prepare to send the byte.
  dut->i_clk = 0;     // Hammer is back. Ensure we start from a 'low' state.
  dut->eval();

  int cycles = 0;
  int bit_count = 0;
  uint_fast16_t captured = 0; // Storage container that can hold 16 bits of data.
  while (!contextp->gotFinish() && cycles < 50000) {
    dut->i_clk ^= 1;
    dut->eval();

    if (dut->i_clk == 1 && cycles >= 1084 && (cycles - 1084) % 2170 == 0 && bit_count < 10) {
      printf("sample: cycle=%d tx=%d\n", cycles, dut->o_uart_tx);
      captured = (captured >> 1) | ((uint_fast16_t)dut->o_uart_tx << 9);
      bit_count++;
    }

    contextp->timeInc(1);

    if (cycles == 1)
      dut->i_wr = 0;

    cycles++;
  }

  if ((captured & 0x3FF) == 0x2AA)
    printf("PASS\n");
  else
    printf("FAIL: captured=0x%03X expected=0x2AA\n", captured & 0x3FF);

  return 0;
}
