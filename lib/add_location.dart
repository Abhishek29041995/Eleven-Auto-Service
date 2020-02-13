import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'dart:ui' as ui;
import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddLocation extends StatefulWidget {
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var location = new Location();
  CameraPosition _currentPosition = CameraPosition(
    target: LatLng(0.0, 0.0),
    zoom: 14.4746,
  );
  Set<Marker> markers = Set();
  Completer<GoogleMapController> _controller = Completer();
  LocationData currentLocation;
  BitmapDescriptor myIcon;
  bool _isLoading = true;

  String cityName = "";
  String locationTitle = "";
  String lattitude = "";
  String longitude = "";
  String fulladdress = "";
  String erbil = 'Erbil';
  String acccessToken = "";

  TextEditingController _namecontroller = new TextEditingController();
  TextEditingController _address1controller = new TextEditingController();
  TextEditingController _address2controller = new TextEditingController();
  Map userData = null;

  @override
  void initState() {
    _getLocation();
    setIcons();
    checkIsLogin();
    super.initState();
  }

  Future<Null> checkIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    JsonCodec codec = new JsonCodec();
    userData = codec.decode(prefs.getString("userData"));
    acccessToken = prefs.getString("accessToken");
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
      if (markers.length > 0) {
        markers.remove(markers.firstWhere(
                (Marker marker) => marker.markerId == MarkerId("currentLocation")));
      }
      setState(() {
        markers.add(Marker(
            markerId: MarkerId("currentLocation"),
            icon: myIcon,
            draggable: true,
            position:
            LatLng(currentlocation.latitude, currentlocation.longitude),
            onDragEnd: ((value) {
              getLocationAddress(value.latitude, value.longitude);
            })));
      });
      new Timer(new Duration(milliseconds: 2000), () {
        _UpdateCurrentLocation(CameraPosition(
          target: LatLng(currentlocation.latitude, currentlocation.longitude),
          zoom: 14.4746,
        ));

        getLocationAddress(currentlocation.latitude, currentlocation.longitude);
      });
    });
  }

  Future<void> _UpdateCurrentLocation(CameraPosition cameraPosition) async {
    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
        child: Scaffold(
            key: _scaffoldKey,
            body: Stack(
              children: _buildMap(context),
            )));
  }

  List<Widget> _buildMap(BuildContext context) {
    var list = new List<Widget>();
    var mapView = new Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.4,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _currentPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markers,
      ),
    );
    list.add(mapView);
    var address = Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.4),
      child: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RaisedButton.icon(
                icon: Icon(Icons.location_on),
                color: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                elevation: 0,
                label: Text(locationTitle,
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold)),
                onPressed: () {},
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: RawMaterialButton(
                  fillColor: Colors.black12,
                  constraints: BoxConstraints(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.all(5),
                  elevation: 0,
                  child: Text(Translations.of(context).text('change'),
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.deepOrange,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold)),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Text(fulladdress,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Montserrat',
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20),
            child: TextField(
              controller: _namecontroller,
              style: TextStyle(fontSize: 13.0),
              decoration: new InputDecoration(
                counterStyle: TextStyle(
                  height: double.minPositive,
                ),
                counterText: "",
                labelText: Translations.of(context).text('location_name'),
                hintStyle: TextStyle(fontSize: 13),
                fillColor: Colors.white,
                //fillColor: Colors.green
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20),
            child: TextField(
              controller: _address1controller,
              style: TextStyle(fontSize: 13.0),
              decoration: new InputDecoration(
                counterStyle: TextStyle(
                  height: double.minPositive,
                ),
                counterText: "",
                labelText: Translations.of(context).text('house_flat'),
                hintStyle: TextStyle(fontSize: 13),
                fillColor: Colors.white,
                //fillColor: Colors.green
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8),
            child: TextField(
              controller: _address2controller,
              style: TextStyle(fontSize: 13.0),
              decoration: new InputDecoration(
                counterStyle: TextStyle(
                  height: double.minPositive,
                ),
                counterText: "",
                labelText: Translations.of(context).text('landmark'),
                hintStyle: TextStyle(fontSize: 13),
                fillColor: Colors.white,
                //fillColor: Colors.green
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
                constraints: const BoxConstraints(
                    minWidth: double.infinity, minHeight: 35.0),
                child: RaisedButton(
                    child: new Text(Translations.of(context).text('confirm')),
                    onPressed: () {
                      if (fulladdress.toLowerCase().contains(erbil.toLowerCase())) {
                        if (_address1controller.text != '') {
                          addMyLocation();
                        } else {
                          _displaySnackBar(Translations.of(context)
                              .text('enter_house_flat'));
                        }
                      } else {
                        _displaySnackBar(Translations.of(context)
                            .text('the_service_not_available'));
                      }
                    },
                    textColor: Colors.white,
                    color: Color(0xff170e50),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)))),
          ),
        ],
      ),
    );
    list.add(address);
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
          color: Color(0xffffffff),
          borderRadius: new BorderRadius.circular(5.0)),
    );
  }

  _displaySnackBar(msg) {
    final snackBar = new SnackBar(
      content: Text(msg),
      backgroundColor: Colors.black,
      action: SnackBarAction(
        label: Translations.of(context).text('ok'),
        onPressed: () {
          // Some code to undo the change!
        },
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  Future setIcons() async {
    myIcon = BitmapDescriptor.fromBytes(
        await getBytesFromAsset('assets/imgs/gps.png', 100));
  }

  addMyLocation() {
    setState(() {
      _isLoading = true;
    });
    var request =
        new MultipartRequest("POST", Uri.parse(api_url + "user/address/add"));
    request.fields['lat'] = lattitude != null ? lattitude : '0.0';
    request.fields['lon'] = longitude != null ? longitude : '0.0';
    request.fields['address'] = fulladdress != null ? fulladdress : '';
    request.fields['landmark'] = _address2controller.text;
    request.fields['house'] = _address1controller.text;
    request.fields['name'] = _namecontroller.text;
    request.headers['Authorization'] = "Bearer $acccessToken";
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) {
        setState(() {
          _isLoading = false;
        });
        Map data = json.decode(value);
        presentToast(data['message'], context, 0);
        if (data['code'] == 200) {
          Navigator.of(context).pop();
        }
      });
    });
  }

  Future getLocationAddress(latitude, long) async {
    final coordinates = new Coordinates(latitude, long);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      lattitude = latitude.toString();
      longitude = long.toString();
      cityName = first.subLocality;
      locationTitle = first.subLocality;
      _namecontroller.text = locationTitle != null ? locationTitle : '';
      fulladdress = first.addressLine;
      _isLoading = false;
    });
    print(
        ' ${first.locality}, ${first.adminArea},${first.subLocality}, ${first.subAdminArea},${first.addressLine}, ${first.featureName},${first.thoroughfare}, ${first.subThoroughfare}');
  }
}
