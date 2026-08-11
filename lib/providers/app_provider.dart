import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/obd_service.dart';

class AppProvider extends ChangeNotifier {
  final OBDService _obdService = OBDService();
  
  bool _connecting = false;
  bool _scanning = false;
  List<BluetoothDevice> _devices = [];
  List<DiagnosticTroubleCode> _dtcs = [];
  bool _scanningCodes = false;
  String _language = 'en';

  // Live telemetry getters
  int get rpm => _obdService.rpm;
  int get speed => _obdService.speed;
  int get coolantTemp => _obdService.coolantTemp;
  int get fuelLevel => _obdService.fuelLevel;
  int get throttlePos => _obdService.throttlePos;
  
  bool get isConnected => _obdService.isConnected;
  bool get isSimulator => _obdService.isSimulator;
  bool get connecting => _connecting;
  bool get scanning => _scanning;
  List<BluetoothDevice> get devices => _devices;
  List<DiagnosticTroubleCode> get dtcs => _dtcs;
  bool get scanningCodes => _scanningCodes;
  String get language => _language;

  Timer? _refreshTimer;

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  Future<void> scanForAdapters() async {
    _scanning = true;
    notifyListeners();
    
    _devices = await _obdService.scanDevices();
    
    _scanning = false;
    notifyListeners();
  }

  Future<void> connectToDevice(BluetoothDevice? device) async {
    _connecting = true;
    notifyListeners();

    bool success = await _obdService.connect(device);
    
    if (success) {
      _startLiveRefresh();
    }

    _connecting = false;
    notifyListeners();
  }

  void _startLiveRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_obdService.isConnected) {
        timer.cancel();
        return;
      }
      notifyListeners();
    });
  }

  Future<void> scanTroubleCodes() async {
    _scanningCodes = true;
    _dtcs = [];
    notifyListeners();

    _dtcs = await _obdService.fetchDTCs();

    _scanningCodes = false;
    notifyListeners();
  }

  Future<bool> clearCodes() async {
    bool success = await _obdService.clearDTCs();
    if (success) {
      _dtcs = [];
      notifyListeners();
    }
    return success;
  }

  void disconnect() {
    _refreshTimer?.cancel();
    _obdService.disconnect();
    notifyListeners();
  }
}
