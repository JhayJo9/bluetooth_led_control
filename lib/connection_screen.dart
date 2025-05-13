import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:bluetooth_led_control/room_selection_screen.dart';

import 'bluetooth_led_service.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({Key? key}) : super(key: key);

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize Bluetooth when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BluetoothService>(context, listen: false).initBluetooth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to HC-05'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Container(
        color: const Color.fromARGB(255, 92, 85, 85),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white, fontSize: 18),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bluetooth Devices',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    bluetoothService.isConnected
                        ? const Text(
                      'Connected',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : ElevatedButton(
                      onPressed: () {
                        bluetoothService.isScanning
                            ? bluetoothService.stopScan()
                            : bluetoothService.startScan();
                      },
                      child: Text(
                        bluetoothService.isScanning ? 'Stop Scan' : 'Scan',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: bluetoothService.devicesList.isEmpty
                    ? const Center(
                  child: Text('No devices found. Tap Scan to search.'),
                )
                    : ListView.builder(
                  itemCount: bluetoothService.devicesList.length,
                  itemBuilder: (context, index) {
                    BluetoothDevice device =
                    bluetoothService.devicesList[index];
                    return ListTile(
                      title: Text(
                        device.name ?? 'Unknown Device',
                        style: const TextStyle(color: Colors.blue), // Custom font color
                      ),
                      subtitle: Text(
                        device.address,
                        style: const TextStyle(color: Colors.white), // Custom font color
                      ),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          bool connected = await bluetoothService.connectToDevice(device);
                          if (connected) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RoomSelectionScreen(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to connect. Try again.'),
                              ),
                            );
                          }
                        },
                        child: const Text('Connect'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
