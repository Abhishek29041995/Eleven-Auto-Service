import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart' as prefix0;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class NearMe extends StatefulWidget {
  _NearMe createState() => _NearMe();
}

class _NearMe extends State<NearMe> {
  Completer<GoogleMapController> _controller = Completer();
  LocationData currentLocation;
  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  static LatLng _initialPosition;
  bool _isLoading = true;
  final Set<Marker> _markers = {};
  static LatLng _lastMapPosition = _initialPosition;
  Geolocator geolocator = Geolocator();

  Position userLocation;
  var location = new Location();
  CameraPosition _currentPosition = CameraPosition(
    target: LatLng(0.0, 0.0),
    zoom: 14.4746,
  );

  Future _getLocation() async {
    try {
      location.onLocationChanged().listen((LocationData currentLocation) {
        print('Latitude:${currentLocation.latitude}');
        print('Longitude:${currentLocation.longitude}');
        return LatLng(currentLocation.latitude, currentLocation.longitude);
      });
    } catch (e) {
      print('ERROR:$e');
      currentLocation = null;
    }
  }

  Future<Position> _getCurrentLocation() async {
    var currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition(
          desiredAccuracy: prefix0.LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  @override
  void initState() {
    _getLocation();
    _getCurrentLocation().then((position) {
      userLocation = position;
      new Timer(new Duration(milliseconds: 2000), () {
        _UpdateCurrentLocation(CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.4746,
        ));
        setState(() {
          _isLoading = false;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      body: Stack(
        children: _buildMap(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('To the lake!'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  Future<void> _UpdateCurrentLocation(CameraPosition cameraPosition) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  List<Widget> _buildMap(BuildContext context) {
    var mapView = new GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _currentPosition,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
    var list = new List<Widget>();
    list.add(mapView);
    if (_isLoading) {
      var modal = new Stack(
        children: [
          new Opacity(
            opacity: 0.3,
            child: const ModalBarrier(dismissible: false, color: Colors.grey),
          ),
          new Center(
            child: SpinKitRotatingPlain(
              itemBuilder: _customicon,
            ),
          ),
        ],
      );
      list.add(modal);
    }
    return list;
  }

  Widget _customicon(BuildContext context, int index) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset("assets/imgs/logo.png"),
      ),
      decoration: new BoxDecoration(
          color: Color(0xff170e50),
          borderRadius: new BorderRadius.circular(5.0)),
    );
  }
}
