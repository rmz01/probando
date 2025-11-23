# 🛰️ TEIDESAT OPERATIVE SYSTEM FREERTOS - ESP32 

## 🎯 Requirements

### Hardware
- ESP32 development board (ESP32-DOIT-DEVKIT-V1 recommended)
- USB cable (data capable)
- Computer with Linux (Gentoo tested)

### Software
- Visual Studio Code
- PlatformIO IDE extension
- Git

## 🔧 ESP32 Setup

### 1. Install PlatformIO in VS Code
1. Open VS Code
2. Go to Extensions
3. Search for "PlatformIO IDE"
4. Install the extension

### 2. Configure USB Permissions (Linux/Gentoo)

#### Add user to required groups:
```bash
sudo usermod -a -G dialout,uucp,tty,plugdev $USER
```

#### Create udev rules for ESP32:
```bash
sudo nano /etc/udev/rules.d/49-esp32.rules
```

#### Add the following content:
https://raw.githubusercontent.com/platformio/platformio-core/develop/platformio/assets/system/99-platformio-udev.rules

#### Reload udev rules:
```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

#### Verify Setup
```bash
# Connect ESP32 and check device permissions
ls -la /dev/ttyUSB0
# Expected example: crw-rw-rw- 1 root dialout
```

## 📐 Telemetry Architecture

The telemetry system is divided into modules with clear responsibilities to facilitate unit testing, maintenance, and extensibility:

| Module       | File (include/src)                       | Primary Responsibility                                                                 |
|--------------|-------------------------------------------|----------------------------------------------------------------------------------------|
| Acquisition  | `telemetry_acquisition.h/.cpp`            | Orchestrate packet generation from generators and store them in the buffer.          |
| Processing   | `telemetry_processing.h/.cpp`             | Retrieve packets and format them for logging/analytics.                              |
| Transmission | `telemetry_transmission.h/.cpp`           | Manage contact windows and (simulated) transmit all available packets.               |
| Logging      | `telemetry_logger.h/.cpp`                 | Persist data to LittleFS and output via Serial.                                      |
| Diagnostics  | `telemetry_diagnostics.h/.cpp`            | System health: periodic dumps, statistics, and status.                               |
| Storage      | `telemetry_storage.h/.cpp`                | Thread-safe circular buffer with mutexes and usage metrics.                          |
| Types        | `telemetry_types.h`                       | Definitions of structures and packet unions.                                         |

### Data Flow (Pipeline)
1. `telemetry_acquisition_cycle()` generates all types and stores them.
2. `telemetry_processing_handle_one()` consumes and formats packets for inspection.
3. `telemetry_transmission_cycle()` opens contact windows and transmits (simulated) remaining packets.
4. `telemetry_diagnostics_tick()` provides visibility (dump logs + buffer metrics + heap).