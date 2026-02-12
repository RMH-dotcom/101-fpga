/* verilator lint_off DECLFILENAME */
// Objectives:
// 1. To get an idea of what combinatorial logic is.

module thruwire (
    input  i_sw, // Need a physical switch
    output o_led // Need a physical LED
);
  assign o_led = i_sw;
endmodule

// fundamental part of any FPGA design maps your ports to the pins.
// This is the purpose of a Constraint File.
// Different vendors use different forms for their constraint files:
// - PCF: Used by Arachne-PNR and NextPNR
// - UCF: Used by ISE for older Xilinx designs
// - XDC: Used by Vivado for newer Xilinx designs
// - QSF: Used by Quartus for Intel chips

// Your board vendor should provide you with a master constraint file.
// You’ll still need to
// – Comment-out pins you aren’t using
// – Rename pins to match your Verilog

// Using Xilinx boards (XDC):
// set_property -dict {PACKAGE_PIN E22 IOSTANDARD LVCMOS12} [get_ports {i_sw}] // Input wire

// set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS25} [get_ports {o_led}] // Output wire
