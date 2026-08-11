import 'dart:async';
import 'dart:math';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DiagnosticTroubleCode {
  final String code;
  final String description;
  final String severity;

  DiagnosticTroubleCode({required this.code, required this.description, required this.severity});
}

class OBDService {
  bool _isConnected = false;
  bool _isSimulator = true;
  BluetoothDevice? _targetDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;

  // Live telemetry
  int rpm = 0;
  int speed = 0;
  int coolantTemp = 0;
  int fuelLevel = 0;
  int throttlePos = 0;

  bool get isConnected => _isConnected;
  bool get isSimulator => _isSimulator;

  // Simulated data timer
  Timer? _simulatorTimer;

  Future<List<BluetoothDevice>> scanDevices() async {
    List<BluetoothDevice> devices = [];
    try {
      if (await FlutterBluePlus.isSupported == false) {
        return devices;
      }
      
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      
      var subscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (!devices.contains(r.device) && r.device.platformName.isNotEmpty) {
            devices.add(r.device);
          }
        }
      });

      await Future.delayed(const Duration(seconds: 4));
      await FlutterBluePlus.stopScan();
      subscription.cancel();
    } catch (e) {
      // Fallback or handle bluetooth error
    }
    return devices;
  }

  Future<bool> connect(BluetoothDevice? device) async {
    if (device == null) {
      // Enable Simulator Mode
      _isSimulator = true;
      _isConnected = true;
      _startSimulator();
      return true;
    }

    try {
      await device.connect(timeout: const Duration(seconds: 10));
      _targetDevice = device;
      List<BluetoothService> services = await device.discoverServices();
      
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
            _writeCharacteristic = characteristic;
          }
          if (characteristic.properties.read || characteristic.properties.notify) {
            _readCharacteristic = characteristic;
          }
        }
      }

      if (_writeCharacteristic != null) {
        _isSimulator = false;
        _isConnected = true;
        await _initializeELM327();
        return true;
      }
    } catch (e) {
      // Connection failed, fallback to simulator or report error
    }
    return false;
  }

  Future<void> _initializeELM327() async {
    await sendCommand('AT Z'); // Reset
    await sendCommand('AT E0'); // Echo off
    await sendCommand('AT SP 0'); // Auto protocol
  }

  Future<String> sendCommand(String command) async {
    if (_isSimulator || _writeCharacteristic == null) {
      await Future.delayed(const Duration(milliseconds: 100));
      return 'OK';
    }
    
    try {
      await _writeCharacteristic!.write(command.codeUnits);
      // Read response
      if (_readCharacteristic != null) {
        var value = await _readCharacteristic!.read();
        return String.fromCharCodes(value);
      }
    } catch (e) {
      return 'ERROR';
    }
    return 'NO DATA';
  }

  void _startSimulator() {
    _simulatorTimer?.cancel();
    final random = Random();
    _simulatorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isConnected) {
        timer.cancel();
        return;
      }
      rpm = 800 + random.nextInt(2500);
      speed = (rpm / 100).toInt() + random.nextInt(5);
      coolantTemp = 85 + random.nextInt(5);
      fuelLevel = 72;
      throttlePos = 15 + random.nextInt(20);
    });
  }

  Future<List<DiagnosticTroubleCode>> fetchDTCs() async {
    if (_isSimulator) {
      await Future.delayed(const Duration(seconds: 15));
      // Return realistic sample DTCs for demonstration
      return [
        DiagnosticTroubleCode(
          code: 'P0300',
          description: 'Random/Multiple Cylinder Misfire Detected',
          severity: 'Warning',
        ),
        DiagnosticTroubleCode(
          code: 'P0420',
          description: 'Catalyst System Efficiency Below Threshold (Bank 1)',
          severity: 'Attention',
        ),
      ];
    }

    // Real OBD-II DTC query (Mode 3)
    String response = await sendCommand('03');
    // Parse DTC response...
    return [];
  }

  Future<bool> clearDTCs() async {
    if (_isSimulator) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }
    String response = await sendCommand('04');
    return response.contains('OK');
  }

  void disconnect() {
    _simulatorTimer?.cancel();
    _targetDevice?.disconnect();
    _isConnected = false;
  }
}
