/* verilator lint_off DECLFILENAME */
// Create two intermediate wires to connect the AND and OR gates together.
// Note: the wire that feeds the NOT gate is wire out, so no need to declare
// a third wire here.
// The wires are driven by one source but can feed multiple inputs.

`default_nettype none
module declare_wire_02 (
    input  a,
    b,
    c,
    d,  // Four inputs.
    output out,
    out_n  // Two outputs.
);

  wire w1, w2;  // Two wires connecting the first AND gates to the OR gate.

  // Define the wires. w1 = AND gate, w2 = AND gate.
  assign w1 = a & b;  // Gate 1: AND gate (a, b) -> w1
  assign w2 = c & d;  // Gate 2: AND gate (c, d) -> w2

  // Connect w1 and w2 to the third (OR) gate.
  assign out = w1 | w2;  // Gate 3: OR gate (w1, w2) -> out

  // From the third gate, connect the NOT gate (out_n).
  assign out_n = ~out;  // Gate 4: NOT gate (out) -> out_n

endmodule
