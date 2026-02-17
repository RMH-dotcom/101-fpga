# Make also has placeholder mechanics
rtl = 01-wires.v
tb = 01-wires.cpp

# Run simulation
sim: $(rtl) $(tb)
	verilator --cc --exe --build $(rtl) $(tb)
	./obj_dir/01-wires_sim
