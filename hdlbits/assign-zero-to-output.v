// We want to assign zero to the output
// Fun tip: for Quartus (FPGA vendor tool for Intel FPGA boards) synthesis,
// not assigning a value to a signal will automatically assign zero to it

module top_module ( output zero );
        assign zero = 0;
endmodule
