import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> ensureBluetoothPermissions() async {
  await [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
  ].request();
}

Future<bool> hasBluetoothPermissions() async {
  final statusConnect = await Permission.bluetoothConnect.status;
  final statusScan = await Permission.bluetoothScan.status;
  return statusConnect.isGranted && statusScan.isGranted;
}

class BluetoothService with ChangeNotifier {
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  bool _isScanning = false;
  bool _isConnected = false;
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _connectedDevice;
  BluetoothConnection? _connection;

  // Add bluetooth state tracking
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  bool _isBluetoothAvailable = false;

  // Getters
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  List<BluetoothDevice> get devicesList => _devicesList;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  BluetoothState get bluetoothState => _bluetoothState;
  bool get isBluetoothAvailable => _isBluetoothAvailable;
  bool get isBluetoothOn => _bluetoothState == BluetoothState.STATE_ON;

  // Initialize Bluetooth
  Future<void> initBluetooth() async {
    try {
      // First check if Bluetooth is available on this device
      _isBluetoothAvailable = await _bluetooth.isAvailable ?? false;

      if (!_isBluetoothAvailable) {
        print('Bluetooth is not available on this device');
        notifyListeners();
        return;
      }

      // Get current bluetooth state
      _bluetoothState = await _bluetooth.state;

      // Listen for state changes
      _bluetooth.onStateChanged().listen((state) {
        _bluetoothState = state;
        print('Bluetooth state changed to: $state');

        if (state == BluetoothState.STATE_OFF) {
          // Clean up any active scanning/connection when BT is turned off
          _isScanning = false;
          if (_isConnected && _connection != null) {
            _connection!.close();
            _isConnected = false;
            _connectedDevice = null;
            _connection = null;
          }
        }

        notifyListeners();
      });

      // Check if Bluetooth is enabled
      bool? isEnabled = await _bluetooth.isEnabled;
      if (isEnabled == false) {
        // We'll let the UI handle prompting the user
        print('Bluetooth is off. User needs to enable it.');
      }

      notifyListeners();
    } catch (e) {
      print('Error initializing Bluetooth: $e');
    }
  }

  // Request to enable Bluetooth
  Future<bool> requestEnable() async {
    if (!_isBluetoothAvailable) return false;

    try {
      return await _bluetooth.requestEnable() ?? false;
    } catch (e) {
      print('Error requesting Bluetooth enable: $e');
      return false;
    }
  }

  // Start scanning for devices with safety checks
  Future<void> startScan() async {
    // Check if Bluetooth is available and enabled
    if (!_isBluetoothAvailable) {
      print('Bluetooth is not available');
      return;
    }

    bool? isEnabled = await _bluetooth.isEnabled;
    if (isEnabled != true) {
      print('Bluetooth is not enabled');
      bool? enabled = await _bluetooth.requestEnable();
      if (enabled != true) {
        print('User declined to enable Bluetooth');
        return;
      }
    }

    if (!await hasBluetoothPermissions()) {
      await ensureBluetoothPermissions();
    }
    if (_isScanning) return;

    _devicesList.clear();
    notifyListeners();

    try {
      _isScanning = true;
      notifyListeners();

      // Get paired devices
      List<BluetoothDevice> bondedDevices = await _bluetooth.getBondedDevices();
      for (BluetoothDevice device in bondedDevices) {
        if (!_devicesList.contains(device)) {
          _devicesList.add(device);
          print('Found paired device: ${device.name}');
        }
      }
      notifyListeners();

      // Discover unpaired devices
      _bluetooth.startDiscovery().listen((result) {
        final device = result.device;
        if (!_devicesList.contains(device) && device.name != null) {
          _devicesList.add(device);
          print('Discovered device: ${device.name}');
          notifyListeners();
        }
      }, onDone: () {
        _isScanning = false;
        notifyListeners();
      });

    } catch (e) {
      print('Error scanning for devices: $e');
      _isScanning = false;
      notifyListeners();
    }
  }

  // The rest of your methods remain unchanged
  // Stop scanning
  Future<void> stopScan() async {
    if (!_isScanning) return;

    try {
      await _bluetooth.cancelDiscovery();
      _isScanning = false;
      notifyListeners();
    } catch (e) {
      print('Error stopping scan: $e');
    }
  }

  // Connect to a device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (_isConnected) {
      await disconnect();
    }

    try {
      print('Attempting to connect to ${device.name} at ${device.address}');
      BluetoothConnection connection =
      await BluetoothConnection.toAddress(device.address);

      print('Connected to ${device.name}');
      _connection = connection;
      _connectedDevice = device;
      _isConnected = true;

      // Listen for incoming data
      connection.input!.listen((Uint8List data) {
        String message = utf8.decode(data);
        print('Data received: $message');

        // You could handle responses from the HC-05 here

      }).onDone(() {
        // Disconnect happened
        print('Disconnected from ${device.name}');
        _isConnected = false;
        _connectedDevice = null;
        _connection = null;
        notifyListeners();
      });

      notifyListeners();
      return true;
    } catch (e) {
      print('Error connecting to device: $e');
      _isConnected = false;
      _connectedDevice = null;
      _connection = null;
      notifyListeners();
      return false;
    }
  }

  // Disconnect from device
  Future<void> disconnect() async {
    if (!_isConnected || _connection == null) return;

    try {
      await _connection!.close();
      _isConnected = false;
      _connectedDevice = null;
      _connection = null;
      notifyListeners();
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  // Send command to turn LED on/off
  Future<void> sendCommand(String room, bool turnOn) async {
    if (!_isConnected || _connection == null) {
      print('Not connected to any device');
      return;
    }

    try {
      String command = '';

      switch (room) {
        case 'bedroom':
          command = turnOn ? 'BR_ON' : 'BR_OFF';
          break;
        case 'kitchen':
          command = turnOn ? 'KT_ON' : 'KT_OFF';
          break;
        case 'livingroom':
          command = turnOn ? 'LR_ON' : 'LR_OFF';
          break;
        case 'bathroom':
          command = turnOn ? 'BT_ON' : 'BT_OFF';
          break;
      }

      // Add newline to command
      command = '$command\n';
      print('Sending command: $command');

      // Convert command to bytes and send
      _connection!.output.add(Uint8List.fromList(utf8.encode(command)));
      await _connection!.output.allSent;
      print('Command sent successfully');
    } catch (e) {
      print('Error sending command: $e');
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}