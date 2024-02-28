import 'package:flutter/material.dart';

class ConnectedPage extends StatefulWidget {
  final String deviceId;
  final Function(String) sendDataToDevice;

  ConnectedPage({required this.deviceId, required this.sendDataToDevice});

  @override
  _ConnectedPageState createState() => _ConnectedPageState();
}

class _ConnectedPageState extends State<ConnectedPage> {
  String deviceData = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connected Device'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Text(
              '$deviceData',
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.sendDataToDevice('on');
              },
              child: Text('Turn On'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                widget.sendDataToDevice('off');
              },
              child: Text('Turn Off'),
            ),
          ],
        ),
      ),
    );
  }
}
