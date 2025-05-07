# Flutter Bluetooth LED Control

A Flutter application to control room LEDs connected to an Arduino using an HC-05 Bluetooth module.

---

## 🔧 HC-05 to Arduino Connection

| HC-05 Pin | Arduino Pin | Description |
|-----------|-------------|-------------|
| VCC       | 5V          | Power supply |
| GND       | GND         | Ground |
| TXD       | RX (Pin 0)  | HC-05 TX → Arduino RX |
| RXD       | TX (Pin 1)  | HC-05 RX ← Arduino TX |
| STATE     | Not connected | Optional status indicator |
| EN        | Not connected | Enable pin |

**Important Notes:**
- When uploading code to Arduino, temporarily disconnect the RX/TX pins.
- HC-05 default pairing code is usually 1234 or 0000.
- For optimal safety, use a voltage divider for the RXD pin to convert 5V → 3.3V.

---

## 💡 LED Connections

| LED | Arduino Pin | Purpose         |
|-----|-------------|----------------|
| LED 1 | Pin 2     | Bedroom        |
| LED 2 | Pin 3     | Kitchen        |
| LED 3 | Pin 4     | Living Room    |
| LED 4 | Pin 5     | Bathroom       |
| LED 5 | Pin 13    | Connection status (built-in) |

**Note:** Each LED should have a 220Ω or 330Ω resistor connected to ground.

---

## ⚙️ Setup Instructions

### 1. Flutter Project Setup

1. Create a new Flutter project:
   ```bash
   flutter create bluetooth_led_control
   cd bluetooth_led_control
   ```

2. Update `pubspec.yaml` with required dependencies:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     flutter_bluetooth_serial: ^0.4.0
     provider: ^6.0.5
     cupertino_icons: ^1.0.5
     permission_handler: ^11.0.1
   ```

3. Run `flutter pub get` to install dependencies.

---

### 2. Android 12+ Permission Fixes (Critical!)

**A. Add All Required Permissions to `AndroidManifest.xml`:**

Edit `android/app/src/main/AndroidManifest.xml` and ensure you have:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
```

**B. Request Permissions at Runtime in Flutter:**

Add this to your `bluetooth_service.dart` or main logic before any Bluetooth operation:

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> ensureBluetoothPermissions() async {
  await [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
  ].request();
}
```

Call `await ensureBluetoothPermissions();` before you scan or connect to Bluetooth!

---

### 3. flutter_bluetooth_serial Package Fix (for Android 12+)

If you have issues building or running, patch the package:

- In `android/build.gradle`, set the Android Gradle plugin to at least 7.0.0+
- In `android/gradle/wrapper/gradle-wrapper.properties`, use Gradle 7.0.2+
- In the plugin's `AndroidManifest.xml`, **remove any `package="..."` in the `<manifest>` tag**.
- In the plugin's `build.gradle`, add:
  ```gradle
  namespace "io.github.edufolly.flutterbluetoothserial"
  ```

---

### 4. Arduino Setup

See `arduino_led_control.ino` for pin mapping and serial command handling.

---

## 🏷️ Commands Used By The App

| Command | Function |
|---------|----------|
| BR_ON   | Turn on bedroom light |
| BR_OFF  | Turn off bedroom light |
| KT_ON   | Turn on kitchen light |
| KT_OFF  | Turn off kitchen light |
| LR_ON   | Turn on living room light |
| LR_OFF  | Turn off living room light |
| BT_ON   | Turn on bathroom light |
| BT_OFF  | Turn off bathroom light |
| ALL_ON  | Turn on all lights |
| ALL_OFF | Turn off all lights |

---

## ❗ Troubleshooting

- **App crashes or closes after permission prompt:**
   - Make sure you request Bluetooth permissions at runtime using `permission_handler`.
   - Make sure ALL required permissions are in your Manifest.
   - Reinstall the app after making Manifest changes.

- **Gradle build fails:**
   - Check your internet connection and proxy/firewall.
   - Update Gradle and the Android Gradle Plugin to recent versions.
   - Run `flutter clean` and `flutter pub get`.

- **Cannot find HC-05 module:**
   - Pair the module in device Bluetooth settings first.
   - Default code is 1234 or 0000.

- **Cannot connect to HC-05:**
   - Restart the module and your phone.
   - Check wiring.

- **LEDs not responding:**
   - Check Arduino wiring and test LEDs directly.

---

## ⚠️ Known Issues

- The flutter_bluetooth_serial package may have issues with some Android 12+ devices.
- Some phones may require additional Bluetooth permission handling.
- When uploading code to Arduino, always disconnect HC-05 RX/TX pins.

---
