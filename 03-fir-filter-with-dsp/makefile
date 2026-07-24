# Variables
RTL_DIR = rtl
FORMAL_DIR = formal
SIM_DIR = sim
BUILD_DIR = obj_dir

# fir_filter
RTL = $(RTL_DIR)/fir_filter.sv
FORMAL = $(FORMAL_DIR)/fir.sby
TB = $(SIM_DIR)/tb_fir_filter.cpp
SIM_EXEC = $(BUILD_DIR)/Vfir_filter

# Phony targets
.PHONY: lint sim formal clean

# make fir_filter
lint:
	verilator --lint-only -Wall  $(RTL)

sim:
	verilator --cc $(RTL) --trace --exe $(TB) --build
	./$(SIM_EXEC)

formal:
	sby -f $(FORMAL)

clean:
	rm -rf $(BUILD_DIR)
