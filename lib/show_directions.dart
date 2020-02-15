import 'dart:async';
import 'dart:convert';

import 'package:eleve11/landing_page.dart';
import 'package:eleve11/services/api_services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

const double CAMERA_ZOOM = 13;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;

class ShowDirections extends StatefulWidget {
  Map worker;
  Map address;
  double userLat;
  double userLon;

  ShowDirections(worker, address, userLat, userLon) {
    this.worker = worker;
    this.address = address;
    this.userLat = double.parse(userLat);
    this.userLon = double.parse(userLon);
  }

  _ShowDirectionsState createState() =>
      _ShowDirectionsState(this.worker, this.address, this.userLat, this.userLon);
}

class _ShowDirectionsState extends State<ShowDirections> {
  Completer<GoogleMapController> _controller = Completer();

  // this set will hold my markers
  Set<Marker> _markers = {};

  // this will hold the generated polylines
  Set<Polyline> _polylines = {};

  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];

  // this is the key object - the PolylinePoints
  // which generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = "AIzaSyBXKbm--KUa9xthK9KpfWkH2xHJ1GTymF8";
  var location = new Location();

  // for my custom icons
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  LatLng SOURCE_LOCATION = LatLng(0, 0);
  LatLng DEST_LOCATION = LatLng(0, 0);
  bool _isLoading = true;
  LocationData currentLocation;
  static final databaseReference = FirebaseDatabase.instance.reference();
  StreamSubscription subscription;
  Map worker;
  Map address;
  double user_lat, user_lon;

  _ShowDirectionsState(worker, address, user_lat, user_lon) {
    this.worker = worker;
    this.address = address;
    if(address != null){
      DEST_LOCATION =
          LatLng(double.parse(address['lat']), double.parse(address['lon']));
    }else{
      DEST_LOCATION =
          LatLng(user_lat, user_lon);

    }

  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    subscription = FirebaseDatabase.instance
        .reference()
        .child("workers")
        .child(worker['id'].toString())
        .onValue
        .listen((event) async {
      SOURCE_LOCATION = LatLng(
          event.snapshot.value['latitude'], event.snapshot.value['longitude']);
    });
    super.initState();
//    _getLocation();
    setSourceAndDestinationIcons();
  }

  Future _getLocation() async {
    try {
      if (location.serviceEnabled() == true) {
        getUpdatedLocation();
      } else {
        location.requestPermission().then((onValue) {
          if (onValue == true) {
            getUpdatedLocation();
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        });
      }
    } catch (e) {
      print('ERROR:$e');
      currentLocation = null;
    }
  }

  void getUpdatedLocation() {
    location.getLocation().then((LocationData currentlocation) {
      SOURCE_LOCATION =
          LatLng(currentlocation.latitude, currentlocation.longitude);
      setState(() {
        _isLoading = false;
      });
    });
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/technician.png');
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialLocation = CameraPosition(
        zoom: CAMERA_ZOOM,
        bearing: CAMERA_BEARING,
        tilt: CAMERA_TILT,
        target: SOURCE_LOCATION);
    return Stack(
      children: <Widget>[
        GoogleMap(
            myLocationEnabled: true,
            compassEnabled: true,
            tiltGesturesEnabled: false,
            markers: _markers,
            polylines: _polylines,
            mapType: MapType.normal,
            initialCameraPosition: initialLocation,
            onMapCreated: onMapCreated),
        _isLoading
            ? new Stack(
                children: [
                  new Opacity(
                    opacity: 0.3,
                    child: const ModalBarrier(
                        dismissible: false, color: Colors.grey),
                  ),
                  new Center(
                    child: SpinKitRotatingPlain(
                      itemBuilder: _customicon,
                    ),
                  ),
                ],
              )
            : SizedBox(
                height: 0,
              ),
        Padding(
          padding: EdgeInsets.fromLTRB(5, 0, 5, 20),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
                constraints: const BoxConstraints(
                    minWidth: double.infinity, minHeight: 45.0),
                child: RaisedButton(
                    child: new Text("Go back"),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new LandingPage()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    textColor: Colors.white,
                    color: Color(0xff170e50),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)))),
          ),
        )
      ],
    );
  }

  Widget _customicon(BuildContext context, int index) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset("assets/imgs/logo.png"),
      ),
      decoration: new BoxDecoration(
          color: Color(0xffffffff),
          borderRadius: new BorderRadius.circular(5.0)),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(Utils.mapStyles);
    _controller.complete(controller);
    print(SOURCE_LOCATION);
    print(DEST_LOCATION);
    List<LatLng> lantlongs = new List();
    lantlongs.add(SOURCE_LOCATION);
    lantlongs.add(DEST_LOCATION);
    Future.delayed(
        Duration(milliseconds: 200),
        () => controller.animateCamera(
            CameraUpdate.newLatLngBounds(boundsFromLatLngList(lantlongs), 100)));
    setMapPins();
    setPolylines();
  }

  void setMapPins() {
    setState(() {
      // source pin
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: SOURCE_LOCATION,
          icon: sourceIcon));
      // destination pin
      _markers.add(Marker(
          markerId: MarkerId('destPin'),
          position: DEST_LOCATION,
          icon: destinationIcon));
    });
  }

  setPolylines() async {
    print("----------------");
    List<PointLatLng> result = await polylinePoints
        ?.getRouteBetweenCoordinates(
            googleAPIKey,
            SOURCE_LOCATION.latitude,
            SOURCE_LOCATION.longitude,
            DEST_LOCATION.latitude,
            DEST_LOCATION.longitude)
        .catchError((onError) {
      presentToast('No available routes found', context, 0);
      setState(() {
        _isLoading = false;
      });
      subscription.cancel();
    });
    print("====================");
    print(result);
    if (result != null && result.isNotEmpty) {
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }

    print(polylineCoordinates);

    setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs
      Polyline polyline = Polyline(
          width: 5,
          polylineId: PolylineId("poly"),
          color: Color.fromARGB(255, 40, 122, 198),
          points: polylineCoordinates);

      // add the constructed polyline as a set of points
      // to the polyline set, which will eventually
      // end up showing up on the map
      _polylines.add(polyline);
      _isLoading = false;
    });
  }
}

class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}
