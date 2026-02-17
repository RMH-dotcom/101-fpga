/* verilator lint_off DECLFILENAME */
// Making an LED blink with configurable counter width

module blinky #(parameter WIDTH = 27) (
    input  logic i_clk,
    output logic o_led
);
    logic [WIDTH-1:0] counter;

    always_ff @(posedge i_clk) begin
        counter <= counter + 1;
    end

    assign o_led = counter[WIDTH-1];

endmodule
