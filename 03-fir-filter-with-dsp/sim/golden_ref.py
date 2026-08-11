import numpy as np
import scipy.signal as signal

# Generate 16-tap low-pass coefficients with scipy.signal.firwin
num_taps = 16 # The factory will contain exactly 16 assemblers
cutoff_hz = 4000 # Cutoff any signal that vibrates faster than 4,000 Hz
fs_hz = 48000 # Conveyor belt speed

# Create the 16 coeffs with the above parameters
h_float = signal.firwin(num_taps, cutoff_hz, fs=fs_hz)

# Quantise them to Q16 signed 16-bit integers
h_int16 = np.round(h_float * (2**16)).astype(np.int16)

impulse_signal = np.zeros(32, dtype=np.int64) # Create 32 belts, with 64-bit slots
impulse_signal[0] = 0x7FFF # Drop a raw material (32,767) on slot 0

h_int64 = h_int16.astype(np.int64) # transform (32,767*h_int16)*16 to 64-bit
y = np.zeros(32, dtype=np.int64) # Create empty boxes to store the individual products
l_regs_python = np.zeros(num_taps, dtype=np.int64)

for t in range(32):
    sample = impulse_signal[t]

    y[t] = l_regs_python[0] >> 16

    next_regs = sample * h_int64

    for i in range(15):
        next_regs[i] = (sample * h_int64[i]) + l_regs_python[i+1]

    l_regs_python = next_regs

print("Q16 Coefficients: \n", h_int16)
print("Answer key: \n", y)

h_ramp = np.arange(1, 17, dtype=np.int64)
l_regs_python = np.zeros(num_taps, dtype=np.int64)

for t in range(32):
    sample = impulse_signal[t]

    y[t] = l_regs_python[0] >> 16

    next_regs = sample * h_ramp

    for i in range(15):
        next_regs[i] = (sample * h_ramp[i]) + l_regs_python[i+1]

    l_regs_python = next_regs

print("Q16 Coefficients: \n", h_ramp)
print("Ramp answer key: \n", y)

np.random.seed(42)
stream = np.random.randint(-32768, 32767, size=40, dtype=np.int64)
l_regs_python = np.zeros(num_taps, dtype=np.int64)
stream = np.concatenate([stream, np.zeros(16, dtype=np.int64)])
y_stream =np.zeros(56, dtype=np.int64)

for t in range(56):
    sample = stream[t]

    y_stream[t] = l_regs_python[0] >> 16

    next_regs = sample * h_int64

    for i in range(15):
        next_regs[i] = (sample * h_int64[i]) + l_regs_python[i+1]

    l_regs_python = next_regs

print("Q16 Coefficients: \n", h_int16)
print("Stream answer key: \n", y_stream)
print("Stream input: \n", stream[:40])
