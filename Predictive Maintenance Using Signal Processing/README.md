# Predictive Maintenance Using Signal Processing

A MATLAB project that simulates industrial machine vibration signals and automatically detects faults using FFT frequency analysis and RMS energy monitoring.

---

## What This Project Does

Machines like motors and pumps vibrate at specific frequencies when healthy. When a fault develops (like a worn bearing), it introduces a new frequency into the vibration signal. This project generates both a healthy and a faulty vibration signal, analyses them using signal processing techniques, and automatically determines whether a fault is present.

---

## Project Parts

**normal_signal.m**
Generates a clean 50 Hz sine wave representing a healthy machine vibration.

**faulty_signal.m**
Simulates a faulty machine by adding a 120 Hz fault component and random noise on top of the normal signal.

**fft_analysis.m**
Applies Fast Fourier Transform (FFT) to convert the signals from time domain to frequency domain, revealing which frequencies are present and how strong they are.

**fault_detection.m**
Computes RMS values for both signals, compares them against a threshold, and prints an automated diagnostic verdict — Normal or Fault Detected.

---

## Graphs

- **Normal vs Faulty Signal** — time domain comparison showing how the faulty signal is irregular and has higher amplitude spikes
- **Zoomed Overlay (200 ms)** — close-up view of both signals overlaid to highlight the difference
- **FFT Side by Side** — frequency spectrum of both signals; normal shows one spike at 50 Hz, faulty shows two spikes at 50 Hz and 120 Hz
- **FFT Overlay** — both spectra on one plot to directly compare the extra fault spike
- **FFT Stem Plot** — discrete view of frequency peaks for both signals
- **RMS Bar Chart** — bar chart comparing RMS values with the fault detection threshold line marked
- **Diagnostic Dashboard** — single 4-panel figure combining time signals, FFT spectra, and RMS comparison

---

## Tools Used

- MATLAB
- Signal Processing Toolbox
