# XDC file for rtl/tx-uart.sv on the Zybo xc7z010clg400-1 development board.

## Clock signal (125 MHz system clock)
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { i_clk }];
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { i_clk }];

## Pmod
set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { o_uart_tx }];
