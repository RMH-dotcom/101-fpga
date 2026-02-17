// Create a NOR gate.

// NOR gates need two operators when written in .v.

module create_nor_gate (
    input  a,
    input  b,
    output out
);
  assign out = ~(a | b);
endmodule
