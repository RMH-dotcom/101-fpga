#Physical pins
set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { o_cs_n }];
set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { o_mosi }];
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { i_miso }];
set_property -dict { PACKAGE_PIN K14   IOSTANDARD LVCMOS33 } [get_ports { o_sclk }];

# Clock pins
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { i_clk }]; 
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { i_clk }];

# Reset
set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports { i_rst_l }];