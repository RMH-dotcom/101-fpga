// In verilog, wires are directional. Information flows in only one direction.
// From the source (aka the driver) to the destination (aka the sink).

// A "continuous assignment" (assign left_side = right_side;) is when the
// signal on the right side is driven (transferred) by the wire on the left.
// It's "continuous" because the assignment (the process) continues to run
// even if the signal on the right side changes.
// It carries on, like a wheel.

// (stuff on the left side of the module) -> the module -> (stuff on the right)
// module top_module:
// (input wires) -> an "assign" statement -> (output wires)

module top_module ( input in, output out );
        assign out = in; // We tell the module to take whatever is on the input wire
                        // and drive (transfer) it to the output wire.
endmodule

// Warframe example:
// Thurible (Harrow's 3rd ability) sacrifices shields for energy — extra for
// headshot kills. Conversely, energy gained can be used to recast thurible.
// module harrow_thurible ( input headshot_kill, output shields_gained );
//      assign energy_gained = headshot_kill;
// endmodule
