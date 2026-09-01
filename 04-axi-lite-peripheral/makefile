RTL_DIR = rtl
FIR_RTL = ../03-fir-filter-with-dsp/rtl/fir_filter.sv
SIM_DIR = sim
BUILD_DIR = obj_dir

TB = $(SIM_DIR)/tb_axi_fir_filter.cpp
SIM_EXEC = $(BUILD_DIR)/Vaxi_fir_filter

lint:
	verilator --lint-only -Wall $(FIR_RTL) $(RTL_DIR)/axi_fir_filter.sv

.PHONY: lint sim clean

sim:
	verilator --cc $(RTL_DIR)/axi_fir_filter.sv $(FIR_RTL) --trace --exe $(TB) --build
	./$(SIM_EXEC)

clean:
	rm -rf $(BUILD_DIR)
