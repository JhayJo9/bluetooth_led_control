import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bluetooth_led_control/bluetooth_led_service.dart';
import 'package:bluetooth_led_control/connection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BluetoothService(),
      child: MaterialApp(
        title: 'Bluetooth LED Control',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const ConnectionScreen(),
      ),
    );
  }
}