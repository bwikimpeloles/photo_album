import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class DetailsPage extends StatefulWidget {
  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  String _locationMessage = "";

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position);

    setState(() {
      _locationMessage = "${position.latitude}, ${position.longitude}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Text Widget Example")),
        body: Align(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(_locationMessage),
                FlatButton(
                    onPressed: () {
                      _getCurrentLocation();
                    },
                    color: Colors.blueAccent,
                    child: Text(
                      "Find Location",
                      style: TextStyle(color: Colors.white),
                    )),
              ]),
        ));
  }
}
