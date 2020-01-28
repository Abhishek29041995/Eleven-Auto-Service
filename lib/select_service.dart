import 'dart:convert';

import 'package:circular_check_box/circular_check_box.dart';
import 'package:eleve11/modal/child_services.dart';
import 'package:eleve11/modal/service_list.dart';
import 'package:eleve11/overview_order.dart';
import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:eleve11/widgets/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectService extends StatefulWidget {
  String selectedServiceCat;
  String type;
  String address_id;
  double latitude;
  double longitude;

  SelectService(String selectedServiceCat, String type, String address_id,
      double latitude, double longitude) {
    this.selectedServiceCat = selectedServiceCat;
    this.type = type;
    this.address_id = address_id;
    this.latitude = latitude;
    this.longitude = longitude;
  }

  _SelectServiceState createState() => _SelectServiceState(
      this.selectedServiceCat,
      this.type,
      this.address_id,
      this.latitude,
      this.longitude);
}

class _SelectServiceState extends State<SelectService> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<ServiceList> serviceList = new List();
  String selectedServiceCat;

  String acccessToken = "";
  Map userData = null;
  bool _isLoading = true;
  String type;
  String price = "";
  String address_id;
  double latitude;
  double longitude;

  _SelectServiceState(String selectedServiceCat, String type, String address_id,
      double latitude, double longitude) {
    this.selectedServiceCat = selectedServiceCat;
    this.type = type;
    this.address_id = address_id;
    this.latitude = latitude;
    this.longitude = longitude;
  }

  @override
  void initState() {
    // TODO: implement initState
    checkIsLogin();
    super.initState();
  }

  Future<Null> checkIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    JsonCodec codec = new JsonCodec();
    userData = codec.decode(prefs.getString("userData"));
    acccessToken = prefs.getString("accessToken");
    getServices();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new SafeArea(
      child: Scaffold(
        body: Stack(
          children: _buildWidget(context),
        ),
      ),
    );
  }

  List<Widget> _buildWidget(BuildContext context) {
    var list = new List<Widget>();
    var appBar = Padding(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 18,
            ),
            color: Colors.grey,
          ),
          CircleAvatar(
            backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                ? Colors.blue
                : Colors.white,
            child: new Container(
                width: 140.0,
                height: 140.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                    image: new ExactAssetImage('assets/imgs/logo.png'),
                    fit: BoxFit.cover,
                  ),
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "WASH",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xff170e50)),
            ),
          )
        ],
      ),
    );
    list.add(appBar);
    var servicelist = Padding(
      padding: EdgeInsets.only(top: 80),
      child: ListView.separated(
          separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(left: 30, right: 10),
                child: Divider(
                  color: Colors.black12,
                ),
              ),
          itemCount: serviceList.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return ExpandableNotifier(
              // <-- Provides ExpandableController to its children
              child: Column(
                children: [
                  Expandable(
                    // <-- Driven by ExpandableController from ExpandableNotifier
                    collapsed: ExpandableButton(
                      // <-- Expands when tapped on the cover photo
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 30, right: 30, top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                FadeInImage.assetNetwork(
                                  placeholder: 'assets/imgs/placeholder.png',
                                  image: serviceList[index].image,
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        serviceList[index].name,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        type == 'SEDAN'
                                            ? serviceList[index].sedan_price
                                            : serviceList[index].suv_price,
                                        style: TextStyle(fontSize: 13),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            CircularCheckBox(
                              value: serviceList[index].isChecked,
                              activeColor: Color(0xff170e50),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              onChanged: (bool x) {
                                setState(() {
                                  serviceList[index].isChecked =
                                      !serviceList[index].isChecked;
                                  if (x) {
                                    if (type == 'SEDAN') {
                                      price = serviceList[index].sedan_price;
                                    } else {
                                      price = serviceList[index].suv_price;
                                    }
                                    for (var i = 0;
                                        i < serviceList.length;
                                        i++) {
                                      if (index != i) {
                                        serviceList[i].isChecked = false;
                                      }
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    expanded: Column(children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 30, right: 30, top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                FadeInImage.assetNetwork(
                                  placeholder: 'assets/imgs/placeholder.png',
                                  image: serviceList[index].image,
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        serviceList[index].name,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green),
                                      ),
                                      Text(
                                        type == 'SEDAN'
                                            ? serviceList[index].sedan_price
                                            : serviceList[index].suv_price,
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.green),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            CircularCheckBox(
                              value: serviceList[index].isChecked,
                              activeColor: Color(0xff170e50),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              onChanged: (bool x) {
                                setState(() {
                                  serviceList[index].isChecked =
                                      !serviceList[index].isChecked;
                                  if (x) {
                                    if (type == 'SEDAN') {
                                      price = serviceList[index].sedan_price;
                                    } else {
                                      price = serviceList[index].suv_price;
                                    }
                                    for (var i = 0;
                                        i < serviceList.length;
                                        i++) {
                                      if (index != i) {
                                        serviceList[i].isChecked = false;
                                      }
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Html(
                        data: serviceList[index].description,
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      ),
//                      _childList(serviceList[index].otherservices),
                    ]),
                  ),
                ],
              ),
            );
          }),
    );
    list.add(servicelist);
    var footer = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 10, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Total :",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    price,
                    style: TextStyle(
                      color: Color(0xff170e50),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              )),
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 20),
            child: ConstrainedBox(
                constraints: const BoxConstraints(
                    minWidth: double.infinity, minHeight: 35.0),
                child: RaisedButton(
                    child: new Text(Translations.of(context).text('continue')),
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new OverViewOrder(
                                  serviceList
                                      .where((i) => i.isChecked == true)
                                      .toList(),
                                  type,
                                  price,
                                  address_id,
                                  latitude.toString(),
                                  longitude.toString(),
                                  selectedServiceCat)));
                    },
                    textColor: Colors.white,
                    color: Color(0xff170e50),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)))),
          )
        ]);
    if (serviceList.where((i) => i.isChecked == true).toList().length > 0) {
      list.add(footer);
    }
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

  List<ServiceList> getServices() {
    print(selectedServiceCat);
    print(acccessToken);
    setState(() {
      _isLoading = true;
    });
    var request = new MultipartRequest(
        "GET", Uri.parse(api_url + "user/getServices/" + selectedServiceCat));
    request.headers['Authorization'] = "Bearer $acccessToken";
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) {
        setState(() {
          _isLoading = false;
        });
        Map data = json.decode(value);
        if (data['code'] == 200) {
          List<ServiceList> tempList = new List();
          print(data['data']);
          if (data['data'].length > 0) {
            for (var i = 0; i < data['data'].length; i++) {
              tempList.add(new ServiceList(
                  data['data'][i]['id'].toString(),
                  data['data'][i]['service_category_id'].toString(),
                  data['data'][i]['name'],
                  data['data'][i]['image'],
                  data['data'][i]['sedan_price'],
                  data['data'][i]['suv_price'],
                  data['data'][i]['description'],
                  "0",
                  data['data'][i]['active'],
                  "1",
                  data['data'][i]['created_at'],
                  data['data'][i]['updated_at'],
                  false));
            }
            setState(() {
              serviceList = tempList;
            });
          }
        }
      });
    });
  }
}
