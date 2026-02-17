// Create a XNOR gate

// If the inputs are the same, the output is 1

module create_xnor_gate (input a, input b, output out);
        assign out = ~(a ^ b);
endmodule
