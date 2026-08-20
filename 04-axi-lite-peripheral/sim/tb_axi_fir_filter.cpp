#include <cstdint>
#include <stdio.h>
#include "Vaxi_fir_filter.h"
#include "verilated.h"

int main()
{
  // Reset
  // Load coefficients: for each of the 16 firwin coefficients, drive a write transaction to the correct address (0x08 through 0x44)
  // Stream samples and read results: drive i_sample writes to 0x00 and read o_result from 0x04
}
