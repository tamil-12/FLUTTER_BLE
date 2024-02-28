import 'package:flutter/material.dart';
import 'bluetooth_scan_page.dart'; // Import the Bluetooth scan page
import 'wifi_list_page.dart'; // Import the WiFi list page

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

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Handle Bluetooth button press here
                // Navigate to Bluetooth scanning page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BluetoothScanPage()),
                );
              },
              icon: Icon(Icons.bluetooth), // Bluetooth icon
              label: Text('Bluetooth'),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Handle WiFi button press here
                // Navigate to WiFi list page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WifiListPage()),
                );
              },
              icon: Icon(Icons.wifi), // WiFi icon
              label: Text('WiFi'),
            ),
          ],
        ),
      ),
    );
  }
}
