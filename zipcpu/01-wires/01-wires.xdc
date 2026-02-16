# XDC file for 01-wires.v
# fundamental part of any FPGA design maps your ports to the pins.
# This is the purpose of a Constraint File.
# Different vendors use different forms for their constraint files:
# - PCF: Used by Arachne-PNR and NextPNR
# - UCF: Used by ISE for older Xilinx designs
# - XDC: Used by Vivado for newer Xilinx designs
# - QSF: Used by Quartus for Intel chips

# Your board vendor should provide you with a master constraint file
# You’ll still need to
# – Comment-out pins you aren’t using
# – Rename pins to match your Verilog

# Using Xilinx boards (XDC):
set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { i_sw }]; # Switch mapping a la /home/nixoslaptopmak/Projects/101/fpga/Zybo-Z7-Master.xdc

set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { o_led }]; # LED mapping a la /home/nixoslaptopmak/Projects/101/fpga/Zybo-Z7-Master.xdc

# What's next?
# The .xdc file acts as the "bridge" between the code and the physical hardware.
# Here is how that flow looks in practice:

# 1. HDL Design (.v / .vhd): The logic is defined (e.g., "when button is pressed, turn on LED").
# 2. Constraints (.xdc): We tell Vivado which physical pin on the Zynq chip is the "button" and which is the "LED".

# Think: .v = home.nix (emacs packages are installed here) .xdc = .emacs.el (configuring the actual packages)

# 3. Synthesis: Vivado converts the HDL code into a logic gate representation (Netlist).
# 4. Implementation: Vivado physically maps those logic gates and routes the wires inside the FPGA, guided by the .xdc file.
# 5. Bitstream Generation (.bit): Vivado produces the binary file that gets loaded into the FPGA configuration memory.
