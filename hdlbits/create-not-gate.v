// Create a module that implements a NOT gate.
// Like C, Verilog has separate bitwise-NOT and logical-NOT operators.
// Since we are working with one bit here, it doesn't matter which one we use.

module create_not_gate (
    input  in,
    output out
);
  assign out = ~in;
endmodule
