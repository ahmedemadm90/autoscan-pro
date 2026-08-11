# AutoScan Pro - Professional OBD-II Car Diagnostic & Real-Time Monitoring App

AutoScan Pro is a high-end Flutter application designed to communicate with ELM327 OBD-II Bluetooth adapters, monitor car telemetry in real-time, and diagnose engine fault codes (DTCs).

## 🚀 Key Features

- **ELM327 Bluetooth Integration**: Connects seamlessly with OBD-II Bluetooth adapters to read live sensor data.
- **Simulator Mode**: Fully interactive simulation mode allowing you to test the app without physical hardware connected.
- **Real-Time Dashboard**: Live gauges and metrics for Engine RPM, Speed, Coolant Temperature, Fuel Level, and Throttle Position.
- **ECU Diagnostics (DTCs)**: Scan, identify, and clear Diagnostic Trouble Codes (e.g., P0300, P0420) with severity classifications.
- **Bilingual Support**: Dynamic switching between English and Arabic.
- **Modern Material 3 UI**: Dark-mode optimized, professional dashboard tailored for automotive diagnostics.

## 🛠 Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Hardware Communication**: `flutter_blue_plus` (BLE / Bluetooth Classic)
- **UI Design**: Material 3 with Custom Gauges

## 📦 Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Android / iOS device with Bluetooth support

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/ahmedemadm90/autoscan-pro.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app (use Simulator Mode if no ELM327 adapter is present):
   ```bash
   flutter run
   ```

## 📝 License
Private Project - All Rights Reserved.
