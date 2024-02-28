import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'wifi_connected.dart'; // Import the WifiConnectedScreen

class WifiListPage extends StatefulWidget {
  @override
  _WifiListPageState createState() => _WifiListPageState();
}

class _WifiListPageState extends State<WifiListPage> {
  List<WifiNetwork> _networks = [];
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scanWifiNetworks();
  }

  Future<void> _scanWifiNetworks() async {
    List<WifiNetwork> list = await WiFiForIoTPlugin.loadWifiList();
    setState(() {
      _networks = list;
    });
  }

  Future<void> _connectToWifi(WifiNetwork network) async {
    String? password = await _showPasswordDialog();
    if (password != null) {
      bool isConnected = await _connectWithPassword(network, password);
      if (isConnected) {
        // Navigate to the WifiConnectedScreen only if connection is successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WifiConnectedScreen(
              connectedNetwork: network,
            ),
          ),
        );
      } else {
        // Display error message for wrong password and prompt to re-enter
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Wrong Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Please enter the correct password.'),
                SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, _passwordController.text),
                child: Text('Connect'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<bool> _connectWithPassword(WifiNetwork network, String password) async {
    try {
      await WiFiForIoTPlugin.connect(network.ssid!, password: password, security: NetworkSecurity.WPA);
      return true; // Return true if connection is successful
    } catch (e) {
      print('Connection failed: $e');
      return false; // Return false if connection fails
    }
  }

  Future<String?> _showPasswordDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Password'),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Password',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _passwordController.text),
            child: Text('Connect'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WiFi Networks'),
      ),
      body: ListView.builder(
        itemCount: _networks.length,
        itemBuilder: (context, index) {
          final network = _networks[index];
          return ListTile(
            title: Text(network.ssid ?? ''),
            subtitle: Text('Signal Strength: ${network.level}'),
            trailing: ElevatedButton(
              onPressed: () => _connectToWifi(network),
              child: Text('Connect'),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
