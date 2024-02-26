import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> discoveredDevices = [];
  Map<String, bool> connectedDevices = {};

  bool isScanning = false;
  bool isDeviceConnected = false;
  String deviceData = '';

  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> scanForDevices() async {
    setState(() {
      isScanning = true;
      discoveredDevices.clear(); // Clear existing devices before scanning
    });

    try {
      flutterReactiveBle
          .scanForDevices(withServices: [])
          .listen((device) {
        setState(() {
          if (!discoveredDevices.any((element) => element.id == device.id)) {
            discoveredDevices.add(device);
            connectedDevices[device.id] = false; // Initialize as not connected
          }
        });
      }, onError: (dynamic error) {
        print('Error during scanning: $error');
        setState(() {
          isScanning = false;
        });
      }, onDone: () {
        setState(() {
          isScanning = false;
        });
      });
    } catch (e) {
      print('Error during scanning: $e');
      setState(() {
        isScanning = false;
      });
    }
  }

  Future<void> connectToDevice(DiscoveredDevice device) async {
    try {
      await flutterReactiveBle.connectToDevice(
        id: device.id,
        servicesWithCharacteristicsToDiscover: {},
        connectionTimeout: const Duration(seconds: 2),
      ).first;
      print('Connected to ${device.name}');
      setState(() {
        connectedDevices[device.id] = true; // Mark as connected
        isDeviceConnected = true;
      });
      // Subscribe to characteristic for receiving data
      flutterReactiveBle.subscribeToCharacteristic(
        QualifiedCharacteristic(
          serviceId: Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b"),
          characteristicId: Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8"),
          deviceId: device.id,
        ),
      ).listen((data) {
        setState(() {
          deviceData = utf8.decode(data); // Convert received data to string
        });
      });
    } catch (e) {
      print('Error connecting to ${device.name}: $e');
    }
  }

  Future<void> sendDataToDevice(String data) async {
    try {
      final encodedData = utf8.encode(data);
      await flutterReactiveBle.writeCharacteristicWithResponse(
        QualifiedCharacteristic(
          serviceId: Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b"),
          characteristicId: Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8"),
          deviceId: discoveredDevices.firstWhere((device) => connectedDevices[device.id] == true).id,
        ),
        value: encodedData,
      );
    } catch (e) {
      print('Error sending data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE Device Scanner'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: isScanning ? null : scanForDevices,
            child: Text(isScanning ? 'Scanning...' : 'Scan for Devices'),
          ),
          SizedBox(height: 10),
          if (isDeviceConnected)
            Column(
              children: [
                Text('Connected with ESP32'),
                SizedBox(height: 10),
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(labelText: 'Enter data to send'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => sendDataToDevice(_textController.text),
                  child: Text('Send Data'),
                ),
                SizedBox(height: 10),
                Text('Received Data: $deviceData'),
              ],
            ),
          Expanded(
            child: ListView.builder(
              itemCount: discoveredDevices.length,
              itemBuilder: (context, index) {
                final device = discoveredDevices[index];
                return ListTile(
                  title: Text(device.name ?? 'Unknown'),
                  subtitle: Text(device.id),
                  trailing: ElevatedButton(
                    onPressed: connectedDevices[device.id] == true
                        ? null
                        : () => connectToDevice(device),
                    child: Text(
                      connectedDevices[device.id] == true
                          ? 'Connected'
                          : 'Connect',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
