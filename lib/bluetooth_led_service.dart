import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService with ChangeNotifier {
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  bool _isScanning = false;
  bool _isConnected = false;
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _connectedDevice;
  BluetoothConnection? _connection;

  // Getters
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  List<BluetoothDevice> get devicesList => _devicesList;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // Initialize Bluetooth
  Future<void> initBluetooth() async {
    try {
      // Request Bluetooth permissions if needed
      bool? isEnabled = await _bluetooth.isEnabled;
      if (isEnabled == false) {
        await _bluetooth.requestEnable();
      }
    } catch (e) {
      print('Error initializing Bluetooth: $e');
    }
  }

  // Start scanning for devices
  Future<void> startScan() async {
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