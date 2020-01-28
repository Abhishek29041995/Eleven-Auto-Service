import 'dart:convert';

import 'package:eleve11/modal/locations.dart';
import 'package:eleve11/modal/notification.dart';
import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyLocations extends StatefulWidget {
  _MyLocationsState createState() => _MyLocationsState();
}

class _MyLocationsState extends State<MyLocations> {
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _loccontroller = new TextEditingController();
  TextEditingController _addresscontroller = new TextEditingController();
  TextEditingController _housecontroller = new TextEditingController();
  TextEditingController _lndMrkcontroller = new TextEditingController();
  List<Locations> locationsList = new List();

  String acccessToken = "";

  @override
  void initState() {
    super.initState();
    checkIsLogin();
  }

  Future<Null> checkIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    acccessToken = prefs.getString("accessToken");
    getLocations();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
//          backgroundColor: Color(0xffFF9800),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                const Color(0xff0463EA),
                const Color(0xff09C1F8),
              ],
            ),
          ),
        ),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => {
                  Navigator.of(context).pop(),
                }),
        automaticallyImplyLeading: false,
        title: new Text(Translations.of(context).text('my_locations')),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        textTheme: TextTheme(
          title: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
      ),
      body: Stack(
        children: _buildWidget(),
      ),
    );
  }

  List<Widget> _buildWidget() {
    List<Widget> list = new List();
    var mainView = Center(
//        child: Padding(padding: EdgeInsets.all(5.0),
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[bodyCard()],
    )
//        ),
        );
    list.add(mainView);
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

  updateLocation(id, location, house, landmark, address) {
    setState(() {
      _isLoading = true;
    });
    var request = new MultipartRequest(
        "POST", Uri.parse(api_url + "user/address/update"));
    request.fields['id'] = id;
    request.fields['name'] = location;
    request.fields['house'] = house;
    request.fields['landmark'] = landmark;
    request.fields['address'] = address;
    request.headers['Authorization'] = "Bearer $acccessToken";
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) {
        setState(() {
          _isLoading = false;
        });
        try {
          Map data = json.decode(value);
          print(data);
          if (data['code'] == 200) {
            setState(() {
              _loccontroller.text = '';
              _addresscontroller.text = '';
              _housecontroller.text = '';
              _lndMrkcontroller.text = '';
            });
            getLocations();
          }
        } catch (onError) {
          _displaySnackBar(Translations.of(context).text('server_error'));
        }
      }).onError((err) =>
          {_displaySnackBar(Translations.of(context).text('server_error'))});
    });
  }

  void getLocations() {
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
        try {
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
                locationsList = tempList;
              });
            }
          }
        } catch (onError) {
          _displaySnackBar(Translations.of(context).text('server_error'));
        }
      }).onError((err) =>
          {_displaySnackBar(Translations.of(context).text('server_error'))});
    });
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

  _displaySnackBar(msg) {
    final snackBar = new SnackBar(
      content: Text(msg),
      backgroundColor: Colors.black,
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          // Some code to undo the change!
        },
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  bodyCard() {
    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: locationsList.length,
        itemBuilder: (BuildContext context, int index) {
          return CardData(locationsList[index], index + 1);
        },
      ),
    );
  }

  CardData(Locations locations, int i) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Card(
        elevation: 2,
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset("assets/imgs/locations.svg",
                          allowDrawingOutsideViewBox: true,
                          height: 30,
                          width: 30,
                          color: Colors.orange),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text( locations.name!=null?locations.name:'No name',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat',
                                    color: Colors.black,
                                    fontSize: 14)),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(locations.address,
                                softWrap: true,
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.black,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 5, 10),
                  child: Text(locations.house + ", near " + locations.landmark,
                      softWrap: true,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.grey,
                          fontSize: 12)),
                )
              ],
            ),
            Positioned(
              right: 0,
              child: IconButton(
                onPressed: () => {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text("Edit Location"),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: new TextField(
                                      autofocus: true,
                                      controller: _loccontroller,
                                      decoration: new InputDecoration(
                                          labelText: 'Location',
                                          hintText: locations.name,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 8),
                                          border: new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(5.0),
                                            borderSide: new BorderSide(),
                                          )),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: new TextField(
                                      autofocus: true,
                                      controller: _housecontroller,
                                      decoration: new InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 8),
                                          labelText: 'House',
                                          hintText: locations.house,
                                          border: new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(5.0),
                                            borderSide: new BorderSide(),
                                          )),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: new TextField(
                                      autofocus: true,
                                      controller: _lndMrkcontroller,
                                      decoration: new InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 8),
                                          labelText: 'Landmark',
                                          hintText: locations.landmark,
                                          border: new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(5.0),
                                            borderSide: new BorderSide(),
                                          )),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: new TextField(
                                      maxLines: 5,
                                      autofocus: true,
                                      controller: _addresscontroller,
                                      decoration: new InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 8),
                                        labelText: 'Address',
                                        alignLabelWithHint: true,
                                        hintText: locations.address,
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(5.0),
                                          borderSide: new BorderSide(),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("Cancel"),
                                onPressed: () => Navigator.pop(context, false),
                              ),
                              FlatButton(
                                child: Text("Edit"),
                                onPressed: () => {
                                  if (_loccontroller.text == '' &&
                                      _housecontroller.text == '' &&
                                      _lndMrkcontroller.text == '' &&
                                      _addresscontroller.text == '')
                                    {
                                      presentToast(
                                          'Nothing to update', context, 2)
                                    }
                                  else
                                    {
                                      Navigator.pop(context, false),
                                      updateLocation(
                                          locations.id,
                                          _loccontroller.text != ''
                                              ? _loccontroller.text
                                              : locations.name,
                                          _housecontroller.text != ''
                                              ? _housecontroller.text
                                              : locations.house,
                                          _lndMrkcontroller.text != ''
                                              ? _lndMrkcontroller.text
                                              : locations.landmark,
                                          _addresscontroller.text != ''
                                              ? _addresscontroller.text
                                              : locations.address)
                                    }
                                },
                              ),
                            ],
                          ))
                },
                icon: Icon(
                  Icons.edit,
                  size: 20,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
