# Variables
RTL_DIR = rtl
SIM_DIR = sim
BUILD_DIR = obj_dir

# tx-uart
RTL = $(RTL_DIR)/tx_uart.sv
TB = $(SIM_DIR)/tb_tx_uart.cpp
SIM_EXEC = $(BUILD_DIR)/Vtx_uart

# PPS
PPS_RTL = $(RTL_DIR)/pps.sv
PPS_TB = $(SIM_DIR)/pps_tb.cpp
PPS_EXEC = $(BUILD_DIR)/Vpps

# Phony targets
.PHONY: sim sim-pps clean help

# tx-uart
sim:
	verilator --cc $(RTL) --trace --exe $(TB) --build
	./$(SIM_EXEC)

# PPS simulation
sim-pps:
	verilator --cc $(PPS_RTL) --trace --exe $(PPS_TB) --build
	./$(PPS_EXEC)

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)
