# Variables
RTL_DIR = rtl
SIM_DIR = sim
BUILD_DIR = obj_dir

# Blinky
RTL = $(RTL_DIR)/blinky.sv
TB = $(SIM_DIR)/blinky_tb.cpp
SIM_EXEC = $(BUILD_DIR)/Vblinky

# PPS
PPS_RTL = $(RTL_DIR)/pps.sv
PPS_TB = $(SIM_DIR)/pps_tb.cpp
PPS_EXEC = $(BUILD_DIR)/Vpps

# Phony targets (always run, not files)
.PHONY: sim sim-pps clean help

# Fast simulation (WIDTH=10 for quick testing)
# --trace introduces "tracing" support in the generated C++
# tracing automatically links *_vcd_c.cpp when using --build

# Blinky simulation
sim:
	verilator --cc $(RTL) -GWIDTH=10 --trace --exe $(TB) --build
	./$(SIM_EXEC)

# PPS simulation
sim-pps:
	verilator --cc $(PPS_RTL) -GCLOCK_RATE_HZ=1000 --trace --exe $(PPS_TB) --build
	./$(PPS_EXEC)

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)

# Help message
help:
	@echo "Targets:"
	@echo "  make sim   - Run simulation (WIDTH=10)"
	@echo "  make sim-pps - Run PPS simulation (CLOCK_RATE_HZ=1000)"
	@echo "  make clean - Remove build files"
	@echo "  make help  - Show this message"
