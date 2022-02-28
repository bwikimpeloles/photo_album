import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GMap extends StatefulWidget {
  const GMap({Key? key}) : super(key: key);

  @override
  _GMapState createState() => _GMapState();
}

class _GMapState extends State<GMap> {
  Set<Marker> _markers = HashSet<Marker>();
  late Position currentLocation;
  bool _onOffMapStyle = false;

  late GoogleMapController _mapController;
  late BitmapDescriptor _markerIcon;

  @override
  void initState() {
    super.initState();
    _setMarkerIcon();
  }

  void _setMarkerIcon() async {
    _markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/camera1.png');
  }

  void _toggleMapStyle() async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');

    if (_onOffMapStyle) {
      _mapController.setMapStyle(style);
    } else {
      _mapController.setMapStyle(null);
    }
  }

  Future<Position> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    currentLocation = await _getCurrentLocation();
    setState(() {
      _markers.add(
        Marker(
            markerId: MarkerId("0"),
            position:
                LatLng(currentLocation.latitude, currentLocation.longitude),
            infoWindow: InfoWindow(
              title: "Your Here",
              snippet: "This is Your Photo Location",
            ),
            icon: _markerIcon),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(37.4219983, -122.084),
              zoom: 12,
            ),
            markers: _markers,
          ),
          Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 32),
            child: Text('Coding with Curry'),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        child: Icon(Icons.map),
        onPressed: () {
          setState(() {
            _onOffMapStyle = !_onOffMapStyle;
          });

          _toggleMapStyle();
        },
      ),
    );
  }
}
