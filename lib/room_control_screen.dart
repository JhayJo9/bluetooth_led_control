import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bluetooth_led_control/bluetooth_led_service.dart';

class RoomControlScreen extends StatefulWidget {
  final String roomName;
  final String roomId;

  const RoomControlScreen({
    Key? key,
    required this.roomName,
    required this.roomId,
  }) : super(key: key);

  @override
  _RoomControlScreenState createState() => _RoomControlScreenState();
}

class _RoomControlScreenState extends State<RoomControlScreen> {
  bool _lightOn = false;

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.roomName} Lights'),
      ),
      body: bluetoothService.isConnected
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _lightOn ? Icons.lightbulb : Icons.lightbulb_outline,
              size: 100,
              color: _lightOn ? Colors.yellow : Colors.grey,
            ),
            const SizedBox(height: 30),
            Text(
              '${widget.roomName} Light',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Switch(
              value: _lightOn,
              onChanged: (value) {
                setState(() {
                  _lightOn = value;
                });
                // Send command to HC-05
                bluetoothService.sendCommand(widget.roomId, value);
              },
            ),
            Text(
              _lightOn ? 'ON' : 'OFF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _lightOn ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Disconnected from device',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}