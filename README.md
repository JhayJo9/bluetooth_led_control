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
   ```

3. Run `flutter pub get` to install dependencies

### 2. Fix flutter_bluetooth_serial Package for Android 12+

**Critical:** The flutter_bluetooth_serial package requires fixes to work with Android 12+:

1. Locate the package in your Pub cache:
   ```
   C:\Users\<username>\AppData\Local\Pub\Cache\hosted\pub.dev\flutter_bluetooth_serial-0.4.0\android\
   ```

2. Modify `AndroidManifest.xml`:
   - Remove `package="io.github.edufolly.flutterbluetoothserial"` from the manifest tag.
   - Change from:
     ```xml
     <manifest xmlns:android="http://schemas.android.com/apk/res/android"
       package="io.github.edufolly.flutterbluetoothserial">
     ```
   - To:
     ```xml
     <manifest xmlns:android="http://schemas.android.com/apk/res/android">
     ```

3. Modify `build.gradle`:
   - Add namespace to defaultConfig section.
   - Add this line inside the defaultConfig block:
     ```gradle
     namespace "io.github.edufolly.flutterbluetoothserial"
     ```

### 3. Add Required Permissions to AndroidManifest.xml

Add these permissions to your app's `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<!-- For Android 12+ -->
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
```

### 4. Arduino Setup

1. Upload this code to your Arduino:

```cpp
const int bedroomLED = 2;   // LED for bedroom
const int kitchenLED = 3;   // LED for kitchen
const int livingRoomLED = 4; // LED for living room
const int bathroomLED = 5;  // LED for bathroom
const int connectionLED = 13; // Built-in LED for connection status

String command = "";
unsigned long lastCommandTime = 0;
const unsigned long CONNECTION_TIMEOUT = 10000; // 10 seconds

void setup() {
  Serial.begin(9600);  
  pinMode(bedroomLED, OUTPUT);
  pinMode(kitchenLED, OUTPUT);
  pinMode(livingRoomLED, OUTPUT);
  pinMode(bathroomLED, OUTPUT);
  pinMode(connectionLED, OUTPUT);
  digitalWrite(bedroomLED, LOW);
  digitalWrite(kitchenLED, LOW);
  digitalWrite(livingRoomLED, LOW);
  digitalWrite(bathroomLED, LOW);
  digitalWrite(connectionLED, LOW);
}

void loop() {
  if (Serial.available() > 0) {
    char c = Serial.read();
    lastCommandTime = millis(); 
    digitalWrite(connectionLED, HIGH); 
    if (c != '\n') {
      command += c;
    } else {
      processCommand(command);
      command = ""; 
    }
  }
  if (millis() - lastCommandTime > CONNECTION_TIMEOUT) {
    if (digitalRead(connectionLED) == HIGH) {
      digitalWrite(connectionLED, LOW);
      turnOffAllLights();
      Serial.println("Connection timeout - all lights turned off");
    }
  }
}

void processCommand(String cmd) {
  cmd.trim();
  if (cmd == "BR_ON") digitalWrite(bedroomLED, HIGH);
  else if (cmd == "BR_OFF") digitalWrite(bedroomLED, LOW);
  else if (cmd == "KT_ON") digitalWrite(kitchenLED, HIGH);
  else if (cmd == "KT_OFF") digitalWrite(kitchenLED, LOW);
  else if (cmd == "LR_ON") digitalWrite(livingRoomLED, HIGH);
  else if (cmd == "LR_OFF") digitalWrite(livingRoomLED, LOW);
  else if (cmd == "BT_ON") digitalWrite(bathroomLED, HIGH);
  else if (cmd == "BT_OFF") digitalWrite(bathroomLED, LOW);
  else if (cmd == "ALL_ON") {
    digitalWrite(bedroomLED, HIGH);
    digitalWrite(kitchenLED, HIGH);
    digitalWrite(livingRoomLED, HIGH);
    digitalWrite(bathroomLED, HIGH);
  }
  else if (cmd == "ALL_OFF") turnOffAllLights();
}

void turnOffAllLights() {
  digitalWrite(bedroomLED, LOW);
  digitalWrite(kitchenLED, LOW);
  digitalWrite(livingRoomLED, LOW);
  digitalWrite(bathroomLED, LOW);
}
```

2. **Important:** Disconnect the RX/TX pins from Arduino before uploading, then reconnect after upload is complete.

3. Make sure to pair the HC-05 with your Android device in Bluetooth settings before running the app.

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

## 🔍 Troubleshooting

1. **App crashes on startup:**
   - Check that you've applied the `flutter_bluetooth_serial` fixes correctly.
   - Ensure all required permissions are in AndroidManifest.xml.

2. **Cannot find HC-05 module:**
   - Ensure HC-05 is powered (red LED should be on).
   - Pair HC-05 with your phone in Bluetooth settings first.
   - Default pairing code is usually 1234 or 0000.

3. **Cannot connect to HC-05:**
   - Restart the HC-05 module.
   - Ensure the Arduino is powered and properly connected.
   - Try re-pairing the device.

4. **LEDs not responding:**
   - Check Arduino wiring.
   - Verify serial communication at 9600 baud rate.
   - Test LEDs directly with a simple Arduino test sketch.

---

## ⚠️ Known Issues

- The flutter_bluetooth_serial package may have issues with some Android 12+ devices.
- Some Samsung/Xiaomi/OnePlus devices may require additional Bluetooth permission handling or battery settings.
- Some HC-05 modules have different pin configurations, or may need a voltage divider for the RX pin.
- When uploading code to Arduino, always disconnect HC-05 RX/TX pins.
