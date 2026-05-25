# SPI Controller

## Project Overview
In this project, I designed and verified a Serial Peripheral Interface (SPI) controller operating in Mode 0 (CPOL=0, CPHA=0).

## Specifications
System Clock Frequency: 125 MHz
SCLK Frequency: 31.25 MHz
Parameterised Clock Divider Range: clks_per_half_bit parameter, default 2

## Architecture
The SPI architecture employs a standard master-slave configuration:

```
Master (FPGA) <---> Slave (SF3 Pmod)
CS ----------------> CS
SCLK --------------> SCLK
MOSI --------------> MOSI
MISO <-------------- MISO
```

### SPI Protocol Details
The controller uses **SPI Mode 0**, where the **Clock Polarity (CPOL) is 0**, meaning the base value of the clock is low and idles in this state.

### Module Breakdown
In terms of modules, I wrote four modules. `spi_master.sv` handles the clock generation, edge detection, bit counting and instantiates data registers. `spi_slave.sv` acts as a receiver. It receives the master's clock and data via MOSI, and responds via MISO. `spi_top.sv` integrates both the master and slaves' modules, because it made testbenching more seamless. `spi_top_hw.sv` was made for hardware and synthesis, implementation and deployment as a way to expose the SPI pins for the board.

### Design Decisions
For the reset strategy, the reset in the sensitivity list in the master module includes `negedge i_rst_l` as well. It is active-low rather than active-high because the buttons on the ZYBO board are active low (pressing pulls to the ground). So the reset releases when a button is pressed, rather that when it's held.

SPI Mode 0 was chosen because it is the simplest and most well documented. The slave module uses system-clock edge detection rather than posedge i_sclk because Verilator cannot reliably detect edges on a derived clock within the same eval() call.

### Signal Description
MOSI and MISO communication was implemented using four wires (CS, SCLK, MOSI, MISO). The **Chip Select** line is an active low signal. While CS is low, the slave samples MOSI on each SCLK edge; the master deasserts CS high to end the transaction. Regarding MOSI and MISO, the MOSI wire sends the bits from the master to the slave module, and the MISO line does the reverse.

### Simulation
Simulation was conducted using a C++ testbench (`tb_spi_master.cpp`). It aimed to record whether or not the bits sent by the master (0xAB, in my case) would be received by the slave. The waveform was exported to `spi.vcd` and inspected in  GTKwave to confirm the correct MOSI shifting and SCLK timing.

### Formal Verification
Formal verification was performed using SymbiYosys (`spi.sby`) with a 20-cycle bound. Two properties were verified. CS low implies the master is busy (o_tx_ready=0), and master idle implies SCLK is low. These are basic protocol invariants. Comprehensive properties such as transaction length and data integrity were verified through simulation rather than formal methods.

## Implementation Results
### Report Utilisation
Look-Up Tables (LUTs): 11/17600 (0.06%)
Flip-Flops (FFs): 16/35200 (0.05%)
IO: 12/100 (12%)
BRAMs: 0, DSPs: 0 — confirms no memory blocks or multiply-accumulate units were needed.

### Timing analysis results:
Target Clock Period (8 ns = 125 MHz)
Worst Negative Slack (WNS): 5.832 ns
Worst Hold Slack (WHS): 0.189 ns
Worst Pulse Width Slack (WPWS): 3.500 ns

Total On-Chip Power: 0.098W
Dynamic: 0.005W (5%)
Static: 0.093W (95%)

As the design is computationally lightweight, the WNS of 5.832 ns on the 8 ns clock means the critical path completes in 8 - 5.832 = 2.168 ns, meaning only approximately 27% of the timing budget was used.

## Hardware Observations
The bitstream was programmed onto the Zybo Z7-10, o_tx_ready LED confirmed the master initialised to idle state. The hardware verification of SPI transactions was not completed due to the sub-microsecond transaction speed requiring a logic analyser.

## Key Problems Solved
During the development of this SPI controller, two significant challenges arose and were successfully fixed. I initially wrote `i_rst_l = 0` in the test bench. This forced no transition on the signal. So to create an actual negedge, I set `i_rst_l` to 1 first, then pull it to 0. Regarding the second bug, I initially wrote `if (r_bit_count == 7` in the TX path block, which caused the master to terminate the transaction after the 7th trailing edge, instead of the first. And because of that, the 8th bit was on MOSI, but the CS fired high before the slave could sample it on the 8th leading edge.
