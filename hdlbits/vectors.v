/* verilator lint_off DECLFILENAME */

// wire [99:0] my_vector;      // Declare a 100-element vector
// assign out = my_vector[10]; // Part-select one bit out of the vector

// Build a circuit that has one 3-bit input, then outputs the same vector
// , and also splits it into three separate 1-bit outputs.
// Connect output o0 to the input vector's position 0, o1 to position 1, etc.

// In a diagram
// , a tick mark with a number next to it indicates the width of the vector (or "bus")
// , rather than drawing a separate line for each bit in the vector.
module vectors (
                input wire [2:0]  vec,
                output wire [2:0] outv,
                output wire       o0,
                output wire       o1,
                output wire       o2
);

  assign outv = vec;
  assign o0 = vec[0];
  assign o1 = vec[1];
  assign o2 = vec[2];
endmodule
