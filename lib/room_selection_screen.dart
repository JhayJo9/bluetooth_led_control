import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bluetooth_led_control/bluetooth_led_service.dart';
import 'package:bluetooth_led_control/room_control_screen.dart';

class RoomSelectionScreen extends StatelessWidget {
  const RoomSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Room'),
        actions: [
          // Disconnect button
          IconButton(
            icon: const Icon(Icons.bluetooth_disabled),
            onPressed: () {
              bluetoothService.disconnect();
              Navigator.pop(context);
            },
            tooltip: 'Disconnect',
          ),
        ],
      ),
      body: bluetoothService.isConnected
          ? GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: [
          _buildRoomCard(
              context,
              'Bedroom',
              Icons.bedroom_parent,
              Colors.blue,
              'bedroom'
          ),
          _buildRoomCard(
              context,
              'Kitchen',
              Icons.kitchen,
              Colors.amber,
              'kitchen'
          ),
          _buildRoomCard(
              context,
              'Living Room',
              Icons.living,
              Colors.green,
              'livingroom'
          ),
          _buildRoomCard(
              context,
              'Bathroom',
              Icons.bathroom,
              Colors.purple,
              'bathroom'
          ),
        ],
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
              child: const Text('Go back to connection screen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, String roomName,
      IconData icon, Color color, String roomId) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomControlScreen(
                roomName: roomName,
                roomId: roomId,
              ),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64.0,
              color: color,
            ),
            const SizedBox(height: 16.0),
            Text(
              roomName,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}