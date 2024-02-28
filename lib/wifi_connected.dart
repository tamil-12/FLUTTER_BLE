import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wifi_iot/wifi_iot.dart';

class WifiConnectedScreen extends StatefulWidget {
  final WifiNetwork connectedNetwork;

  const WifiConnectedScreen({Key? key, required this.connectedNetwork}) : super(key: key);

  @override
  _WifiConnectedScreenState createState() => _WifiConnectedScreenState();
}

class _WifiConnectedScreenState extends State<WifiConnectedScreen> {
  String? ipAddress;

  @override
  void initState() {
    super.initState();
    _getIpAddress();
  }

  Future<void> _getIpAddress() async {
    String? ip = await WiFiForIoTPlugin.getIP();
    setState(() {
      ipAddress = ip;
    });
  }

  Future<void> _sendDataToESP32(String action) async {
    try {
      String url = 'http://192.168.4.1/send-data'; // Assuming ipAddress is the ESP32's IP
      Map<String, String> data = {'action': action};
      await http.post(Uri.parse(url), body: data);
    } catch (e) {
      print('Error sending data to ESP32: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WiFi Connected'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Connected to: ${widget.connectedNetwork.ssid}'),
            SizedBox(height: 20),
            Text('IP Address: ${ipAddress ?? "Loading..."}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _sendDataToESP32('on');
              },
              child: Text('Turn On LED'),
            ),
            ElevatedButton(
              onPressed: () {
                _sendDataToESP32('off');
              },
              child: Text('Turn Off LED'),
            ),
          ],
        ),
      ),
    );
  }
}
