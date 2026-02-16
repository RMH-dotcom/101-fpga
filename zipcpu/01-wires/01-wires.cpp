#include <stdio.h>
#include <stdlib.h>
#include "verilated.h"
#include "V__0301__02dwires.h"

  int main(int argc, char **argv) {
    // Call commandArgs first
    Verilated::commandArgs(argc, argv);

    // create our design
    V__0301__02dwires *tb = new V__0301__02dwires;

    // Run the design though 20 timesteps (20 times)
    for (int k = 0; k < 20; k++) {
      // We set the switch input to the LSB of our step
      tb->i_sw = k & 1;

      tb->eval();

      // Print results
      printf("k = %2d, ", k);
      printf("sw = %d, ", tb->i_sw);
      printf("led = %d\n", tb->o_led);
    }
  }
