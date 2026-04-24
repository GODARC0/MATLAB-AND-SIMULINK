# MATLAB & Simulink Projects

A growing collection of MATLAB scripts and Simulink models built over time — covering control systems, signal processing, fault detection, and predictive maintenance. Started as coursework experiments, gradually turning into actual engineering projects.

---

##  Repository Structure

```
MATLAB-AND-SIMULINK/
│
├── DC motor speed control/          # Open & closed-loop DC motor speed control (Simulink)
├── MATLAB programs/                 # General MATLAB scripts and experiments
├── Predictive Maintenance Using     # Signal processing-based fault detection (MATLAB)
│   Signal Processing/
├── Smart_Guard/                     # MATLAB analysis companion to the ESP32 SmartGuard project
│
├── open_loop_DC.slx                 # Standalone open-loop DC motor Simulink model
├── normal_signal.mat                # Reference signal data (healthy system)
└── faulty_signal.mat                # Faulty signal data for anomaly detection
```

---

##  Projects

###  DC Motor Speed Control
**Tools:** Simulink, Transfer Function blocks

Open-loop and closed-loop PID speed control of a DC motor built in Simulink. Uses Transfer Function blocks to model the motor plant and a PID controller for the closed-loop response. This was also used as the demo model for an **IEEE RAS workshop** on DC motor control — so it's clean and well-structured for teaching purposes too.

- Open-loop model: `open_loop_DC.slx`
- Closed-loop PID model: inside `DC motor speed control/`

---

###  Predictive Maintenance Using Signal Processing
**Tools:** MATLAB, Signal Processing Toolbox

MATLAB-based analysis pipeline for detecting anomalies in machinery signals. Works with `.mat` data files representing normal and faulty operating conditions. The workflow covers:
- Loading and visualizing time-domain signals
- Feature extraction from sensor data
- Comparing healthy vs. faulty signal characteristics to flag potential failures

Signal data files (`normal_signal.mat`, `faulty_signal.mat`) are included at the root level for quick access.

---

###  SmartGuard — MATLAB Analysis Module
**Tools:** MATLAB, Signal Processing

The MATLAB-side complement to the **SmartGuard** ESP32-based fault detection system. While the ESP32 handles real-time hardware monitoring, this module handles the offline/analytical side — processing acquired signals, validating fault thresholds, and serving as a reference for what the embedded system should be detecting. Part of a larger competition entry combining embedded systems + MATLAB analysis.

---

###  MATLAB Programs
A general folder for standalone MATLAB scripts — basic programs, numerical methods, experiments, and anything that doesn't fit neatly into a named project. Grows over time.

---



##  Notes

- This repo is actively growing — new projects get added as they're built during coursework, workshops, and personal work
- `.mat` files are included where needed so scripts can be run without generating your own data first
- Simulink models were built using Transfer Function blocks (not Simscape) — keeping things closer to the control theory side

---

##  Upcoming Additions

- Self-Balancing Robot — PID + LQR implementation (NIT Calicut internship project)
- State-space modeling and pole placement experiments
- More signal processing / condition monitoring work

---

*Part of an ongoing journey through control systems and robotics. — GODARC0*
