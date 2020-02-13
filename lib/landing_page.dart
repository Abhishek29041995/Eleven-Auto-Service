import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'dart:ui' as ui;
import 'package:eleve11/about.dart';
import 'package:eleve11/add_location.dart';
import 'package:eleve11/add_rides.dart';
import 'package:eleve11/application.dart';
import 'package:eleve11/checkOrderHistory.dart';
import 'package:eleve11/contact_us.dart';
import 'package:eleve11/faqs.dart';
import 'package:eleve11/feedback.dart';
import 'package:eleve11/feedback_dynamic.dart';
import 'package:eleve11/login.dart';
import 'package:eleve11/modal/Rides.dart';
import 'package:eleve11/modal/locale.dart';
import 'package:eleve11/modal/locations.dart';
import 'package:eleve11/modal/service_new.dart';
import 'package:eleve11/my_locations.dart';
import 'package:eleve11/my_rides.dart';
import 'package:eleve11/notifications.dart';
import 'package:eleve11/offers.dart';
import 'package:eleve11/profile_design.dart';
import 'package:eleve11/select_service.dart';
import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/subscription.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:eleve11/widgets/carousel_slider.dart';
import 'package:eleve11/widgets/custom_radio.dart';
import 'package:eleve11/promo_codes.dart';
import 'package:eleve11/widgets/searchMapPlaceWidget.dart';
import 'package:eleve11/widgets/user_accounts_drawer_header.dart' as prefix1;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingPage extends StatefulWidget {
  String radioValue = "";

  LandingPage();

  _LandingPage createState() => _LandingPage();
}

class _LandingPage extends State<LandingPage> {
  int currentIndex = 0;
  int _current = 0;
  String address_id = "";
  String acccessToken = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();
  LocationData currentLocations;
  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(36.3660529,43.0820147),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  static LatLng _initialPosition;
  bool _isLoading = true;
  bool isConfirmed = false;
  final Set<Marker> _markers = {};
  static LatLng _lastMapPosition = _initialPosition;
  Geolocator geolocator = Geolocator();
  Set<Marker> markers = Set();
  Position userLocation;
  var location = new Location();
  CameraPosition _currentPosition = CameraPosition(
    target: LatLng(0.0, 0.0),
    zoom: 14.4746,
  );
  BitmapDescriptor myIcon;
  BitmapDescriptor workerIcon;
  LatLng _originLocation = LatLng(0, 0);
  LatLng _destinationLocation = LatLng(0, 0);
  RadioBuilder<String, dynamic> dynamicBuilder;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 15.0;
  double currentlat =0.0;
  double currentlon =0.0;
  final double _initFabHeight = 120.0;
  double _fabHeight;
  bool showfooter = true;
  List<Services> services = new List();
  List<Locations> locations = new List();
  List<Rides> myRides = new List();
  ui.Image labelIcon;
  ui.Image markerImage;
  String locationTitle = "";
  bool isdragged = false;
  Map userData = null;
  static final databaseReference = FirebaseDatabase.instance.reference();
  StreamSubscription subscription;
  String selectedServiceCat = "";

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
      currentLocations = null;
    }
  }

  @override
  Future initState() {
    checkIsLogin();
    _fabHeight = _initFabHeight;
    _getLocation();
    setIcons();
    setRadioItems();

    loadlabel("assets/imgs/map_user.png");
    load("assets/imgs/gps.png");
    subscription = FirebaseDatabase.instance
        .reference()
        .child("workers")
        .onValue
        .listen((event) async {
      for (var i = 1; i < event.snapshot.value.length; i++) {
        markers.add(Marker(
          markerId: MarkerId("worker_location"),
          icon: BitmapDescriptor.fromBytes(
              await getBytesFromAsset('assets/technician.png', 100)),
          position: LatLng(event.snapshot.value[i]['latitude'],
              event.snapshot.value[i]['longitude']),
        ));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<Null> checkIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    JsonCodec codec = new JsonCodec();
    userData = codec.decode(prefs.getString("userData"));
    acccessToken = prefs.getString("accessToken");
    print(acccessToken);
    getServices();
    getLocation();
    getMyRides();
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

  load(String asset) {
    ui.Image image;
    rootBundle.load(asset).then((bd) {
      Uint8List lst = new Uint8List.view(bd.buffer);
      ui.instantiateImageCodec(lst).then((codec) {
        codec.getNextFrame().then((frameInfo) {
          image = frameInfo.image;
          setState(() {
            markerImage = image;
          });
        });
      });
    });
  }

  loadlabel(String asset) {
    ui.Image image;
    rootBundle.load(asset).then((bd) {
      Uint8List lst = new Uint8List.view(bd.buffer);
      ui.instantiateImageCodec(lst).then((codec) {
        codec.getNextFrame().then((frameInfo) {
          image = frameInfo.image;
          setState(() {
            labelIcon = image;
          });
        });
      });
    });
  }

  _onTap(LatLng point) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder,
        Rect.fromPoints(const Offset(0.0, 0.0), const Offset(200.0, 200.0)));
    final Paint paint = Paint()
      ..color = Colors.black.withOpacity(1)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(0.0, 0.0, 152.0, 48.0),
            const Radius.circular(4.0)),
        paint);
    paintText(canvas);
    paintImage(labelIcon, const Rect.fromLTWH(8, 8, 32.0, 32.0), canvas, paint,
        BoxFit.contain);
    paintImage(markerImage, const Rect.fromLTWH(24.0, 48.0, 110.0, 110.0),
        canvas, paint, BoxFit.contain);
    final ui.Picture picture = recorder.endRecording();
    final img = await picture.toImage(200, 200);
    final pngByteData = await img.toByteData(format: ui.ImageByteFormat.png);
    setState(() {
      myIcon = BitmapDescriptor.fromBytes(Uint8List.view(pngByteData.buffer));
    });
  }

  void paintText(Canvas canvas) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 24,
    );
    final textSpan = TextSpan(
      text: '18 mins',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: 88,
    );
    final offset = Offset(48, 8);
    textPainter.paint(canvas, offset);
  }

  void paintImage(
      ui.Image image, Rect outputRect, Canvas canvas, Paint paint, BoxFit fit) {
    final Size imageSize =
    Size(image.width.toDouble(), image.height.toDouble());
    final FittedSizes sizes = applyBoxFit(fit, imageSize, outputRect.size);
    final Rect inputSubrect =
    Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
    final Rect outputSubrect =
    Alignment.center.inscribe(sizes.destination, outputRect);
    canvas.drawImageRect(image, inputSubrect, outputSubrect, paint);
  }

  Future<void> _UpdateCurrentLocation(CameraPosition cameraPosition) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: userData != null
              ? ListView(
            children: <Widget>[
              prefix1.UserAccountsDrawerHeader(
                accountName: Text(
                  userData['name'],
                  style:
                  TextStyle(fontSize: 11, color: Color(0xff170e50)),
                ),
                accountEmail: Text(
                  userData['email'],
                  style:
                  TextStyle(fontSize: 11, color: Color(0xff170e50)),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor:
                  Theme.of(context).platform == TargetPlatform.iOS
                      ? Colors.blue
                      : Colors.white,
                  child: new ClipRRect(
                    borderRadius: new BorderRadius.circular(100),
                    child: Stack(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
//                                Navigator.push(
//                                    context,
//                                    new MaterialPageRoute(
//                                        builder: (context) => new SelectService()));
                          },
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/imgs/user.png',
                            image: userData['avatar'],
                            fit: BoxFit.cover,
                            height: 70,
                            width: 70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              new ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                leading: new Icon(Icons.account_circle,
                    color: Color(0xff170e50)),
                title: new Text(Translations.of(context).text('profile')),
                onTap: () => _onListTileTap(context, "profile"),
              ),
              new ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                leading:
                new Icon(Icons.drive_eta, color: Color(0xff170e50)),
                title:
                new Text(Translations.of(context).text('my_rides')),
                onTap: () => _onListTileTap(context, "my_rides"),
              ),
              new ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                leading:
                new Icon(Icons.my_location, color: Color(0xff170e50)),
                title: new Text(
                    Translations.of(context).text('my_locations')),
                onTap: () => _onListTileTap(context, "mylocation"),
              ),
              new ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                leading: new Icon(Icons.favorite_border,
                    color: Color(0xff170e50)),
                title:
                new Text(Translations.of(context).text('my_orders')),
                onTap: () => _onListTileTap(context, "my_order"),
              ),
              new ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                leading:
                new Icon(Icons.feedback, color: Color(0xff170e50)),
                title:
                new Text(Translations.of(context).text('feedback')),
                onTap: () => _onListTileTap(context, "feedback"),
              ),
              new ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                leading: new Icon(Icons.confirmation_number,
                    color: Color(0xff170e50)),
                title: new Text(
                    Translations.of(context).text('promo_codes')),
                onTap: () => _onListTileTap(context, "promo"),
              ),
              new ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                leading: new Icon(Icons.subscriptions,
                    color: Color(0xff170e50)),
                title: new Text(
                    Translations.of(context).text('subscription')),
                onTap: () => _onListTileTap(context, "subscription"),
              ),
              new ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                leading:
                new Icon(Icons.local_offer, color: Color(0xff170e50)),
                title: new Text(Translations.of(context).text('offers')),
                onTap: () => _onListTileTap(context, "offers"),
              ),
              new ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                leading: new Icon(Icons.notifications,
                    color: Color(0xff170e50)),
                title: new Text(
                    Translations.of(context).text('notifications')),
                onTap: () => _onListTileTap(context, "notify"),
              ),
              new Divider(),
//                    new ListTile(
//                      dense: true,
//                      contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
//                      leading:
//                          new Icon(Icons.settings, color: Color(0xff170e50)),
//                      title:
//                          new Text(Translations.of(context).text('settings')),
//                      onTap: () => _onListTileTap(context, ""),
//                    ),
              new ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                leading: new Icon(Icons.question_answer,
                    color: Color(0xff170e50)),
                title: new Text(Translations.of(context).text('faq')),
                onTap: () => _onListTileTap(context, "faq"),
              ),
              new ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                leading: new Icon(Icons.call, color: Color(0xff170e50)),
                title:
                new Text(Translations.of(context).text('contacts')),
                onTap: () => _onListTileTap(context, "contactus"),
              ),
              new ExpansionTile(
                leading:
                new Icon(Icons.g_translate, color: Color(0xff170e50)),
                title: Text(
                    Translations.of(context).text('change_language')),
                children: <Widget>[
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 4,
                        right: 0.0),
                    title: Text(
                      Translations.of(context).text('english'),
                      textAlign: TextAlign.left,
                    ),
                    onTap: () => {
                      Navigator.of(context).pop(),
                      Provider.of<LocaleModel>(context)
                          .changelocale(Locale("en"))
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 4,
                        right: 0.0),
                    title: Text(
                      Translations.of(context).text('arabic'),
                      textAlign: TextAlign.left,
                    ),
                    onTap: () => {
                      Navigator.of(context).pop(),
                      Provider.of<LocaleModel>(context)
                          .changelocale(Locale("ar"))
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 4,
                        right: 0.0),
                    title: Text(
                      Translations.of(context).text('kurdish'),
                      textAlign: TextAlign.left,
                    ),
                    onTap: () => {
                      Navigator.of(context).pop(),
                      Provider.of<LocaleModel>(context)
                          .changelocale(Locale("ku"))
                    },
                  ),
                ],
              ),
              new ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                leading: new Icon(
                  Icons.info,
                  color: Color(0xff170e50),
                ),
                title: new Text(
                    Translations.of(context).text('about') + ' Eleven'),
                onTap: () => _onListTileTap(context, "about"),
              ),
              new ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                leading: new Icon(Icons.new_releases,
                    color: Color(0xff170e50)),
                title: new Text(
                    Translations.of(context).text('app_version')),
                trailing: new Text(
                  "v1.0.2",
                  style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold),
                ),
              ),
              new ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                leading: new Icon(Icons.power_settings_new,
                    color: Color(0xff170e50)),
                title: new Text(Translations.of(context).text('logout')),
                onTap: () => _onListTileTap(context, "logout"),
              ),
            ],
          )
              : Container(),
        ),
        body: Stack(
          children: _buildMap(context),
        ),
        //this will just add the Navigation Drawer Icon
      ),
    );
  }

  _onListTileTap(BuildContext context, String from) {
    Navigator.of(context).pop();
    if (from == "logout") {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(Translations.of(context).text('logout')),
            content:
            Text(Translations.of(context).text('are_u_sure_logout')),
            actions: <Widget>[
              FlatButton(
                child: Text(Translations.of(context).text('no')),
                onPressed: () => Navigator.pop(context, false),
              ),
              FlatButton(
                  child: Text(Translations.of(context).text('yes')),
                  onPressed: () => {
                    clearPreference(context),
                  }),
            ],
          ));
    } else if (from == "feedback") {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new CheckOrderHistory("Feedback")));
    } else if (from == "profile") {
      Navigator.push(context,
          new MaterialPageRoute(builder: (context) => new ProfilePageDesign()));
    } else if (from == "my_order") {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) =>
              new CheckOrderHistory("Check Order History")));
    } else if (from == "offers") {
      Navigator.push(context,
          new MaterialPageRoute(builder: (context) => new OffersPage()));
    } else if (from == "promo") {
      Navigator.push(context,
          new MaterialPageRoute(builder: (context) => new PromocodesPage()));
    } else if (from == "faq") {
      Navigator.push(
          context, new MaterialPageRoute(builder: (context) => new FAQs()));
    } else if (from == "contactus") {
      Navigator.push(context,
          new MaterialPageRoute(builder: (context) => new ContactUs()));
    } else if (from == "notify") {
      Navigator.push(context,
          new MaterialPageRoute(builder: (context) => new Notifications()));
    } else if (from == "mylocation") {
      Navigator.push(context,
          new MaterialPageRoute(builder: (context) => new MyLocations()));
    } else if (from == "my_rides") {
      Navigator.push(
          context, new MaterialPageRoute(builder: (context) => new MyRides()));
    } else if (from == "about") {
      Navigator.push(
          context, new MaterialPageRoute(builder: (context) => new About()));
    } else if (from == "subscription") {
      Navigator.push(context,
          new MaterialPageRoute(builder: (context) => new SubscriptionPlans()));
    } else {
      showDialog<Null>(
        context: context,
        builder: (_) => new AlertDialog(
          title: const Text('Not Implemented'),
          actions: <Widget>[
            new FlatButton(
              child: Text(Translations.of(context).text('ok')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  Future<Null> clearPreference(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', '');
    if (prefs.getString('bio') != 'enable') {
      prefs.setString('accessToken', '');
      prefs.setString('userData', '');
      prefs.setString('bio', '');
    }
    Navigator.pushAndRemoveUntil(
      context,
      new MaterialPageRoute(builder: (context) => new LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  List<Widget> _buildMap(BuildContext context) {
    var list = new List<Widget>();
    var mapView = new GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _currentPosition,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: markers,
    );
    var footerView = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          !isConfirmed
              ? Container(
            width: MediaQuery.of(context).size.width,
            decoration: new BoxDecoration(
                color: const Color(0xFFFFFFFF),
                boxShadow: [
                  new BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5.0,
                  ),
                ]),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      locations.length > 0
                          ? Expanded(
                        child: CarouselSlider(
                          height: 40,
                          aspectRatio: 2.0,
                          onPageChanged: (index) {
                            setState(() {
                              _current = index;
                              address_id = locations[index].id;
                            });
                          },
                          items: locations.map((i) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    locations.indexOf(i) != _current
                                        ? IconButton(
                                      icon: Icon(
                                        Icons
                                            .arrow_forward_ios,
                                        color: Colors.grey,
                                        size: 14,
                                      ),
                                      onPressed: () {},
                                    )
                                        : SizedBox(
                                      height: 10,
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (markers.length >
                                                0) {
                                              markers.remove(markers
                                                  .firstWhere((Marker
                                              marker) =>
                                              marker
                                                  .markerId ==
                                                  MarkerId(
                                                      "currentLocation")));
                                            }
                                            setState(() {
                                              address_id = i.id;
                                            });
                                            markers.add(Marker(
                                              markerId: MarkerId(
                                                  "currentLocation"),
                                              icon: myIcon,
                                              position: new LatLng(
                                                  double.parse(
                                                      i.lat),
                                                  double.parse(
                                                      i.lon)),
                                              draggable: true,
                                              onDragEnd: ((value) {
                                                setState(() {
                                                  isdragged = true;
                                                  currentlat=value.latitude;
                                                  currentlon=value.longitude;
                                                });
                                                getLocationAddress(
                                                    value.latitude,
                                                    value
                                                        .longitude);
                                                _UpdateCurrentLocation(
                                                    CameraPosition(
                                                      target: LatLng(
                                                          value
                                                              .latitude,
                                                          value
                                                              .longitude),
                                                      zoom: 14.4746,
                                                    ));
                                              }),
                                              onTap: () => _onTap(
                                                  new LatLng(
                                                      double.parse(
                                                          i.lat),
                                                      double.parse(
                                                          i.lon))),
                                            ));
                                            setState(() {
                                              markers = markers;
                                            });
                                            _UpdateCurrentLocation(
                                                CameraPosition(
                                                  target: LatLng(
                                                      double.parse(
                                                          i.lat),
                                                      double.parse(
                                                          i.lon)),
                                                  zoom: 14.4746,
                                                ));
                                          },
                                          child: Padding(
                                            padding:
                                            const EdgeInsets
                                                .all(8.0),
                                            child: Text(
                                              i.name,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontFamily:
                                                  'Montserrat',
                                                  fontWeight:
                                                  FontWeight
                                                      .bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    locations.indexOf(i) != _current
                                        ? IconButton(
                                      icon: Icon(
                                        Icons.arrow_back_ios,
                                        color: Colors.grey,
                                        size: 14,
                                      ),
                                      onPressed: () {},
                                    )
                                        : SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                );
                              },
                            );
                          }).toList(),
                        ),
                      )
                          : Expanded(
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.grey,
                                size: 14,
                              ),
                              onPressed: () {},
                            ),
                            Text(
                              "Loading ...",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                                size: 14,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                      Wrap(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.add_circle,
                              color: Color(0xff170e50),
                              size: 24,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) =>
                                      new AddLocation()))
                                  .then((onVal) {
                                getLocation();
                              });
                            },
                          )
                        ],
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, bottom: 8),
                    child: Divider(),
                  ),
                  Container(
                    width: double.maxFinite,
                    height: 100,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: services.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  height: 80,
                                  child: CustomRadio<String, dynamic>(
                                    services: services[index],
                                    value: services[index].radioButton,
                                    groupValue: widget.radioValue,
                                    animsBuilder: (AnimationController
                                    controller) =>
                                    [
                                      CurvedAnimation(
                                          parent: controller,
                                          curve: Curves.easeInOut),
                                      ColorTween(
                                          begin: Colors.white,
                                          end: Colors.deepPurple)
                                          .animate(controller),
                                      ColorTween(
                                          begin: Colors.deepPurple,
                                          end: Colors.white)
                                          .animate(controller),
                                    ],
                                    builder: dynamicBuilder,
                                  ),
                                ),
                                Text(
                                  services[index].name,
                                  style: TextStyle(fontSize: 13),
                                )
                              ],
                            ),
                          );
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 10, top: 20),
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            minWidth: double.infinity, minHeight: 35.0),
                        child: RaisedButton(
                            child: new Text(Translations.of(context)
                                .text('order_now')),
                            onPressed: () {
                              if (selectedServiceCat != '') {
                                setState(() {
                                  isConfirmed = true;
                                });
                              } else {
                                _displaySnackBar(
                                    "Please select one service");
                              }
                            },
                            textColor: Colors.white,
                            color: Color(0xff170e50),
                            shape: new RoundedRectangleBorder(
                                borderRadius:
                                new BorderRadius.circular(30.0)))),
                  )
                ],
              ),
            ),
          )
              : Container(
            width: MediaQuery.of(context).size.width,
            decoration: new BoxDecoration(
                color: const Color(0xFFFFFFFF),
                boxShadow: [
                  new BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5.0,
                  ),
                ]),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() {
                            isConfirmed = false;
                          });
                        },
                      ),
                      Text(
                        Translations.of(context).text('my_rides'),
                        style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 24,
                      ),
//                          IconButton(
//                            icon: Icon(
//                              Icons.add_circle,
//                              color: Color(0xff170e50),
//                              size: 24,
//                            ),
//                            onPressed: () {},
//                          ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Divider(),
                  ),
                  Container(
                    width: double.maxFinite,
                    height: 200,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: myRides.length + 1,
                        itemBuilder: (BuildContext ctxt, int index) {
                          if (index == myRides.length)
                            return Padding(
                                padding: const EdgeInsets.only(
                                    left: 30, right: 30),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      height: 120,
                                      child: new ClipRRect(
                                        borderRadius:
                                        new BorderRadius.circular(
                                            8.0),
                                        child: Stack(
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    new MaterialPageRoute(
                                                        builder: (context) =>
                                                        new AddRide(
                                                            null))).then(
                                                        (onVal) {
                                                      getMyRides();
                                                    });
                                              },
                                              child: Container(
                                                height: 120,
                                                width: 150,
                                                decoration: BoxDecoration(
                                                    color:
                                                    Colors.black12),
                                                child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    children: <Widget>[
                                                      Icon(Icons.add),
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .all(8.0),
                                                        child: Text(
                                                            Translations.of(
                                                                context)
                                                                .text(
                                                                'add_new')),
                                                      )
                                                    ]),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ));
                          else
                            return _buildItem(context, myRides[index]);
                        }),
                  ),
                ],
              ),
            ),
          ),
        ]);
    list.add(mapView);
    if (showfooter) {
      list.add(footerView);
    }
    var appBar = Row(
      children: <Widget>[
        IconButton(
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
          icon: Icon(Icons.menu),
          color: Colors.black,
        )
      ],
    );
    list.add(appBar);
    var searchbar = Positioned(
        top: 60,
        left: MediaQuery.of(context).size.width * 0.05,
        // width: MediaQuery.of(context).size.width * 0.9,
        child: SearchMapPlaceWidget(
          apiKey: "AIzaSyBXKbm--KUa9xthK9KpfWkH2xHJ1GTymF8",
          location: _currentPosition.target,
          radius: 30000,
          onSelected: (place) async {
            final geolocation = await place.geolocation;
            if (markers.length > 0) {
              markers.remove(markers.firstWhere((Marker marker) =>
              marker.markerId == MarkerId("currentLocation")));
            }
            markers.add(Marker(
              markerId: MarkerId("currentLocation"),
              icon: myIcon,
              position: geolocation.coordinates,
              draggable: true,
              onDragEnd: ((value) {
                setState(() {
                  isdragged = true;
                  currentlat=value.latitude;
                  currentlon=value.longitude;
                });
                getLocationAddress(value.latitude, value.longitude);
                _UpdateCurrentLocation(CameraPosition(
                  target: LatLng(value.latitude, value.longitude),
                  zoom: 14.4746,
                ));
              }),
              onTap: () => _onTap(geolocation.coordinates),
            ));
            _UpdateCurrentLocation(CameraPosition(
              target: geolocation.coordinates,
              zoom: 14.4746,
            ));
          },
        ));
    list.add(searchbar);

//    if (showfooter) {
//      list.add(footerView);
//    }
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

  Future getLocationAddress(latitude, longitude) async {
    final coordinates = new Coordinates(latitude, longitude);
    var addresses =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      locationTitle = first.subLocality;
    });
    locations.insert(0,
        new Locations("", "", "Current Location", "", "", "", "", "", "", ""));
    print(isdragged);
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

  void getUpdatedLocation() {

    Future.delayed(const Duration(milliseconds: 100), () {
      location.getLocation().then((LocationData currentLocation) {
        new Timer(new Duration(milliseconds: 2000), () {
          _UpdateCurrentLocation(CameraPosition(
            target: LatLng(currentLocation.latitude, currentLocation.longitude),
            zoom: 14.4746,
          ));

          getLocationAddress(currentLocation.latitude, currentLocation.longitude);
          if (markers.length > 0) {
            markers.remove(markers.firstWhere(
                    (Marker marker) => marker.markerId == MarkerId("currentLocation"),
                orElse: () => null));
          }
          markers.add(Marker(
            markerId: MarkerId("currentLocation"),
            icon: myIcon,
            position: LatLng(currentLocation.latitude, currentLocation.longitude),
            draggable: true,
            onDragEnd: ((value) {
              setState(() {
                isdragged = true;
                currentlat=value.latitude;
                currentlon=value.longitude;
              });
              getLocationAddress(value.latitude, value.longitude);
              _UpdateCurrentLocation(CameraPosition(
                target: LatLng(value.latitude, value.longitude),
                zoom: 14.4746,
              ));
            }),
            onTap: () => _onTap(
                LatLng(currentLocation.latitude, currentLocation.longitude)),
          ));
          setState(() {
            currentLocations = currentLocation;
            currentlat=currentLocation.latitude;
            currentlon=currentLocation.longitude;
            _isLoading = false;
          });
        });
      });
    });


  }

  void setRadioItems() {
    dynamicBuilder = (BuildContext context, List<dynamic> animValues,
        Function updateState, Services services, String value) {
      return GestureDetector(
          onTap: () {
            setState(() {
              widget.radioValue = value;
              selectedServiceCat = services.id;
            });
          },
          child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
              padding: EdgeInsets.all(4.0 + animValues[0] * 6.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: animValues[1],
              ),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/imgs/logo.png',
                image: services.imageurl,
                fit: BoxFit.cover,
              )));
    };
  }

  List<Services> getServices() {
    setState(() {
      _isLoading = true;
    });
    var request = new MultipartRequest(
        "GET", Uri.parse(api_url + "user/getServiceCategories"));
    request.headers['Authorization'] = "Bearer $acccessToken";
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) {
        setState(() {
          _isLoading = false;
        });
        Map data = json.decode(value);
        if (data['code'] == 200) {
          List<Services> tempList = new List();
          if (data['data'].length > 0) {
            for (var i = 0; i < data['data'].length; i++) {
              tempList.add(new Services(
                  data['data'][i]['id'].toString(),
                  data['data'][i]['name'],
                  data['data'][i]['image'],
                  "0",
                  data['data'][i]['active'],
                  "1",
                  data['data'][i]['created_at'],
                  data['data'][i]['updated_at']));
            }
            setState(() {
              services = tempList;
            });
          }
        }
      });
    });
  }

  getLocation() {
    setState(() {
      _isLoading = true;
    });
    var request =
    new MultipartRequest("GET", Uri.parse(api_url + "user/address/list"));
    request.headers['Authorization'] = "Bearer $acccessToken";
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) {
        setState(() {
          _isLoading = false;
        });
        Map data = json.decode(value);
        print(data);
        if (data['code'] == 200) {
          List<Locations> tempList = new List();
          if (data['data'].length > 0) {
            for (var i = 0; i < data['data'].length; i++) {
              tempList.add(new Locations(
                  data['data'][i]['id'].toString(),
                  data['data'][i]['user_id'],
                  data['data'][i]['name'],
                  data['data'][i]['house'],
                  data['data'][i]['landmark'],
                  data['data'][i]['address'],
                  data['data'][i]['lat'],
                  data['data'][i]['lon'],
                  data['data'][i]['created_at'],
                  data['data'][i]['updated_at']));
            }
            setState(() {
              locations = tempList;
//              if(locations.length>0){
//                address_id = locations[0].id;
//              }
              _current = 0;
            });
          }
        }
      });
    });
  }

  List<Rides> getMyRides() {
    setState(() {
      _isLoading = true;
    });
    var request =
    new MultipartRequest("GET", Uri.parse(api_url + "user/getMyRides"));
    request.headers['Authorization'] = "Bearer $acccessToken";
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) {
        setState(() {
          _isLoading = false;
        });
        Map data = json.decode(value);
        print(data);
        if (data['code'] == 200) {
          List<Rides> tempList = new List();
          if (data['data'].length > 0) {
            for (var i = 0; i < data['data'].length; i++) {
              tempList.add(new Rides(
                  data['data'][i]['id'].toString(),
                  data['data'][i]['user_id'],
                  data['data'][i]['image'],
                  data['data'][i]['car_model_id'],
                  data['data'][i]['type'],
                  data['data'][i]['created_at'],
                  data['data'][i]['updated_at'],
                  data['data'][i]['car_model']));
            }
            setState(() {
              myRides = tempList;
            });
          }
        }
      });
    });
  }

  Future setIcons() async {
    myIcon = BitmapDescriptor.fromBytes(
        await getBytesFromAsset('assets/imgs/gps.png', 100));

    workerIcon = BitmapDescriptor.fromBytes(
        await getBytesFromAsset('assets/technician.png', 100));
  }

  _buildItem(BuildContext context, Rides myRid) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 120,
            child: new ClipRRect(
              borderRadius: new BorderRadius.circular(8.0),
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
//                      if (address_id != '') {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new SelectService(
                                  selectedServiceCat,
                                  myRid.type,
                                  address_id,
                                  currentlat,
                                  currentlon)));
//                      } else {
//                        _displaySnackBar(
//                            Translations.of(context).text('no_location'));
//                      }
                    },
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/imgs/placeholder.png',
                      image: myRid.image,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                        size: 24,
                      ),
                      onPressed: () {
                        deleteMyRides(myRid.id);
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              myRid.car_model['name'],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
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

  void deleteMyRides(String id) {
    setState(() {
      _isLoading = true;
    });
    var request =
    new MultipartRequest("POST", Uri.parse(api_url + "user/deleteMyRides"));
    request.fields['ride_id'] = id;
    request.headers['Authorization'] = "Bearer $acccessToken";
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) {
        setState(() {
          _isLoading = false;
        });
        Map data = json.decode(value);
        if (data['code'] == 200) {
          List<Rides> tempList = new List();
          if (data['data'].length > 0) {
            for (var i = 0; i < data['data'].length; i++) {
              tempList.add(new Rides(
                  data['data'][i]['id'].toString(),
                  data['data'][i]['user_id'],
                  data['data'][i]['image'],
                  data['data'][i]['car_model_id'],
                  data['data'][i]['type'],
                  data['data'][i]['created_at'],
                  data['data'][i]['updated_at'],
                  data['data'][i]['car_model']));
            }
            setState(() {
              myRides = tempList;
            });
          } else {
            setState(() {
              myRides = tempList;
            });
          }
        }
      });
    });
  }
}