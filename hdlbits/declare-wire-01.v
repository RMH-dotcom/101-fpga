// When circuits become too complex, we need wires to connect internal components together.
// When we use a wire, we should declare it in the body of the module.

module declare_wire_01 (
    input  in,
    output out
);
  wire not_in;  // Declare a wire named "not_in").

  // The wire "not_in" acts as a bridge between the input and output wires.
  assign out = ~not_in;  // Connecting the wire "not_in" to the output "out".
  assign not_in = ~in;  // Connecting the wire "not_in" to the input "in".
endmodule

// What just happened?
// Start: in is 1.
// First Bridge: The signal hits the first "NOT" operation. The polarity flips.
// Now, the wire named not_in is carrying a 0.
// Second Bridge: The signal on not_in hits the second "NOT" operation.
// The polarity flips again.
// Finish: The out port receives a 1.
