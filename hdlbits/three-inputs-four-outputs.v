// Just learned:
// A module in verilog is the blueprint of the circuitry that
// will be synthesised onto the FPGA chip.
// Vivado just describes which paths the circultry will take.
// Physical pins are basically "doors" that connect to the
// outside world (buttons, LEDs, etc).
// Module input/outputs map to physical pins. For sub-modules,
// they're internal wires.

// Task: Create a module with 3 inputs and 4 outputs that behaves like wires
// that makes these connections.
// a -> w
// b -> x
// b -> y
// c -> z

module top_module ( input a,b,c, output w,x,y,z );
        assign {w,x,y,z} = {a,b,b,c};
endmodule
