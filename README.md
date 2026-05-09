# MATLAB & Simulink

> A growing collection of MATLAB scripts and Simulink models covering signal processing, control systems, power electronics, and many more.
---

## Repository Structure

```
MATLAB-AND-SIMULINK/
├── DC motor speed control/                          # PID closed-loop DC motor control (Simulink)
├── MATLAB programs/                                 # General MATLAB scripts and exercises
├── Power Electronics/                               # Rectifier circuit simulations (Simulink)
├── Predictive Maintenance Using Signal Processing/  # Fault detection via FFT & RMS
├── Smart_Guard/                                     # Motor protection system simulation

```

---

## Projects

### 1. DC Motor Speed Control
**Folder:** `DC motor speed control/` · **Tools:** MATLAB, Simulink

Closed-loop speed control of a DC motor using a PID controller. Models the motor's electrical and mechanical dynamics, tunes the controller for a desired step response, and compares open-loop vs. closed-loop performance.

**Key concepts:** Transfer functions · PID tuning · Step response · Simulink block diagrams

---

### 2. Power Electronics — Rectifier Circuits
**Folder:** `Power Electronics/` · **Tools:** Simulink (SimPowerSystems)

Simulink models of single-phase and three-phase rectifier circuits, covering both uncontrolled and controlled configurations.

**Models included:**
| File | Description |
|---|---|
| `Single_phase_Half_wave_rectifiers.slx` | Single-phase half-wave rectifier |
| `Single_phase_fullwave_rectifiers.slx` | Single-phase full-wave rectifier |
| `Three_phase_halfwave_rectifier.slx` | Three-phase half-wave rectifier |
| `Three_phase_fullwave_rectifier.slx` | Three-phase full-wave rectifier |

**Key concepts:** AC-DC conversion · Diode bridge circuits · Waveform analysis · Three-phase systems

---

### 3. Predictive Maintenance Using Signal Processing
**Folder:** `Predictive Maintenance Using Signal Processing/` · **Tools:** MATLAB

Simulates vibration signals for healthy and faulty rotating machinery, then applies frequency-domain analysis to automatically detect faults.

- Generates synthetic vibration signals with injected fault frequencies
- Applies FFT to identify spectral anomalies
- Uses RMS thresholding for automated fault/no-fault classification
- Visualizes time-domain and frequency-domain comparisons side by side

**Key concepts:** FFT · RMS · Spectral analysis · Fault detection · Signal classification

---

### 4. Smart Guard — Motor Protection System  (ONGOING)
**Folder:** `Smart_Guard/` · **Tools:** MATLAB / Simulink

Simulation of an intelligent motor protection system that monitors electrical and thermal parameters, detects fault conditions, and triggers protection responses.

**Key concepts:** Overcurrent protection · Thermal modeling · Fault simulation · Threshold logic

---

### 5. MATLAB Programs
**Folder:** `MATLAB programs/`

General-purpose MATLAB scripts covering foundational topics — matrix operations, signal generation, plotting, and introductory system modeling.

---

## Getting Started

**Requirements:**
- MATLAB R2021a or later
- Simulink (for `.slx` files)
- Signal Processing Toolbox (for predictive maintenance project)

**Steps:**
1. Clone the repository: `git clone https://github.com/GODARC0/MATLAB-AND-SIMULINK.git`
2. Open MATLAB and navigate (`cd`) to the desired project folder
3. Run the `.m` script or open the `.slx` model in Simulink

---

## License

Licensed under the [MIT License](LICENSE).

---

*Builduing while learning*
