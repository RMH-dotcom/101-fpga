RTL_DIR = rtl
FIR_RTL = ../03-fir-filter-with-dsp/rtl/fir_filter.sv

lint:
	verilator --lint-only -Wall $(FIR_RTL) $(RTL_DIR)/axi_fir_filter.sv
