# ============================================================
#  SmartGuard — Serial Data Logger
#  Captures ESP32 sensor output and saves to CSV for MATLAB
#
#  BEFORE RUNNING:
#  1. Install pyserial:  pip install pyserial
#  2. Upload Phase 1 firmware to ESP32
#  3. Close Arduino Serial Monitor (can't use port simultaneously)
#  4. Check your COM port in Device Manager and update COM_PORT below
#  5. Run this script: python smartguard_serial_logger.py
#  6. Press Ctrl+C to stop — CSV is saved automatically
# ============================================================

import serial
import csv
import time
import os
from datetime import datetime

# ============================================================
#  CONFIGURATION — Edit these before running
# ============================================================

COM_PORT    = 'COM4'       # Windows: 'COM3', 'COM6' etc.
                           # Linux/Mac: '/dev/ttyUSB0'
BAUD_RATE   = 115200       # Must match Serial.begin(115200) in firmware
LOG_FOLDER  = 'smartguard_logs'   # Folder where CSV files are saved
TIMEOUT_SEC = 2            # Seconds to wait for data before warning

# ============================================================
#  SETUP — Create log folder and filename
# ============================================================

# Create logs folder if it doesn't exist
if not os.path.exists(LOG_FOLDER):
    os.makedirs(LOG_FOLDER)
    print(f"Created folder: {LOG_FOLDER}")

# Auto-generate filename with timestamp so you never overwrite old data
# Example: smartguard_logs/session_2026-04-09_14-32-00.csv
timestamp   = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
filename    = os.path.join(LOG_FOLDER, f'session_{timestamp}.csv')

# CSV header — must match ESP32 Serial.print order in Phase 1 firmware
CSV_HEADER  = ['time_ms', 'ac_voltage_V', 'dc_voltage_V', 'current_A', 'temperature_C']

# ============================================================
#  HELPER FUNCTIONS
# ============================================================

def parse_line(raw_line):
    """
    Parse one line from ESP32 Serial output.
    Expected format: "1500, 229.45, 11.82, 0.643, 32.10"
    Returns list of floats, or None if line is invalid.
    """
    try:
        line = raw_line.strip()

        # Skip empty lines and ESP32 boot/debug messages
        # (those usually start with letters, not numbers)
        if not line:
            return None
        if not (line[0].isdigit() or line[0] == '-'):
            print(f"  [info] ESP32 message: {line}")
            return None

        # Split by comma and convert each value to float
        values = [float(v.strip()) for v in line.split(',')]

        # Validate — we expect exactly 5 values
        if len(values) != 5:
            print(f"  [skip] Unexpected column count ({len(values)}): {line}")
            return None

        return values

    except ValueError:
        # Line had something that couldn't be converted to float
        print(f"  [skip] Could not parse: {raw_line.strip()}")
        return None


def format_row_display(values):
    """Format a row nicely for terminal display."""
    return (f"  t={values[0]/1000:.1f}s | "
            f"AC={values[1]:.1f}V | "
            f"DC={values[2]:.2f}V | "
            f"I={values[3]:.3f}A | "
            f"T={values[4]:.1f}°C")

# ============================================================
#  MAIN LOGGER
# ============================================================

def run_logger():
    print("=" * 55)
    print("  SmartGuard Serial Logger")
    print("=" * 55)
    print(f"  Port     : {COM_PORT}")
    print(f"  Baud     : {BAUD_RATE}")
    print(f"  Saving to: {filename}")
    print("=" * 55)
    print("  Press Ctrl+C to stop logging and save file.")
    print()

    sample_count = 0
    start_time   = time.time()

    try:
        # Open serial port
        ser = serial.Serial(COM_PORT, BAUD_RATE, timeout=TIMEOUT_SEC)
        print(f"  Connected to {COM_PORT} successfully.")
        time.sleep(2)   # Wait for ESP32 to finish booting

        # Flush any junk data that accumulated during boot
        ser.flushInput()
        print("  Waiting for data...\n")

        # Open CSV file for writing
        with open(filename, 'w', newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(CSV_HEADER)   # Write header row first

            # Keep reading until user presses Ctrl+C
            while True:
                # Read one line from ESP32
                raw = ser.readline().decode('utf-8', errors='ignore')

                if not raw:
                    print("  [warning] No data received — check ESP32 is running.")
                    continue

                # Parse the line
                values = parse_line(raw)
                if values is None:
                    continue

                # Write to CSV
                writer.writerow(values)
                csvfile.flush()   # Flush after every row — no data lost if crash

                # Show live reading in terminal
                sample_count += 1
                print(format_row_display(values))

                # Print a summary every 60 samples (~30 seconds at 2Hz)
                if sample_count % 60 == 0:
                    elapsed = time.time() - start_time
                    print(f"\n  --- {sample_count} samples logged | "
                          f"{elapsed:.0f}s elapsed ---\n")

    except serial.SerialException as e:
        print(f"\n  [ERROR] Could not open {COM_PORT}: {e}")
        print("  Check:")
        print("  - ESP32 is plugged in")
        print("  - COM port number is correct")
        print("  - Arduino Serial Monitor is closed")
        return

    except KeyboardInterrupt:
        # Ctrl+C pressed — clean exit
        elapsed = time.time() - start_time
        print(f"\n\n  Logging stopped by user.")
        print(f"  Total samples : {sample_count}")
        print(f"  Duration      : {elapsed:.1f} seconds")
        print(f"  File saved to : {filename}")
        print()

        if sample_count == 0:
            print("  [warning] No data was saved — file will be empty.")
        else:
            print("  To use in MATLAB:")
            print(f"    1. Set USE_DUMMY = false in SmartGuard_MATLAB_Analysis.m")
            print(f"    2. Set CSV_FILE = '{filename}'")
            print( "    3. Run the script")

    finally:
        try:
            ser.close()
            print(f"  Serial port {COM_PORT} closed.")
        except:
            pass

# ============================================================
#  ENTRY POINT
# ============================================================

if __name__ == '__main__':
    run_logger()
