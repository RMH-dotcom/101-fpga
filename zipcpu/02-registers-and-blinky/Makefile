# Variables
RTL_DIR = rtl
SIM_DIR = sim
BUILD_DIR = obj_dir

RTL = $(RTL_DIR)/blinky.sv
TB = $(SIM_DIR)/blinky_tb.cpp
SIM_EXEC = $(BUILD_DIR)/Vblinky

# Phony targets (always run, not files)
.PHONY: sim clean help

# Fast simulation (WIDTH=10 for quick testing)
# --trace introduces "tracing" support in the generated C++
# tracing automatically links *_vcd_c.cpp when using --build
sim:
	verilator --cc $(RTL) -GWIDTH=10 --trace --exe $(TB) --build
	./$(SIM_EXEC)

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)

# Help message
help:
	@echo "Targets:"
	@echo "  make sim   - Run simulation (WIDTH=10)"
	@echo "  make clean - Remove build files"
	@echo "  make help  - Show this message"
