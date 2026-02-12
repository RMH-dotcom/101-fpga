// Create a module that implements an AND gate.

// The circuit now has three wires (a, b, and out).
// Wires a and b already have values driven onto them by the input ports.
// But wire out is not driven by anything.

module create_and_gate (
    input  a,
    input  b,
    output out
);
  assign out = a & b;
endmodule
