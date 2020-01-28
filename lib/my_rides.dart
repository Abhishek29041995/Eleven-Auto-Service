import 'dart:convert';

import 'package:eleve11/modal/Rides.dart';
import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyRides extends StatefulWidget {
  _MyRidesState createState() => _MyRidesState();
}

class _MyRidesState extends State<MyRides> {
  String acccessToken = "";
  bool _isLoading = false;
  List<Rides> myRides = new List();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    checkIsLogin();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Null> checkIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    acccessToken = prefs.getString("accessToken");
    getMyRides();
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
        title: new Text(Translations.of(context).text('my_rides')),

        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        textTheme: TextTheme(
          title: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
      ),
      backgroundColor: Color(0xffF2F2F2),
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

  bodyCard() {
    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: myRides.length,
        itemBuilder: (BuildContext context, int index) {
//          final item = finalDepData[index];
//          return tableRowDept(item);
          return CardData(myRides[index]);
        },
      ),
    );
  }

  CardData(Rides myRides) {
    return InkWell(
      onTap: () {
        print("clicked");
//        Navigator.push(
//          context,
//          MaterialPageRoute(
//              builder: (context) => CheckOrderHistoryDetails(orderList)),
//        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Wrap(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Image(
                            image: myRides.type == 'SEDAN'
                                ? AssetImage('assets/imgs/sedan.png')
                                : AssetImage('assets/imgs/suv.png'),
                            width: 40,
                            height: 40,
                            fit: BoxFit.fitHeight),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(myRides.car_model['name'],
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text("Updated On:" + myRides.created_at,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 11)),
                          SizedBox(height: 10.0),
                        ],
                      ),
                    ],
                  ),
                  Flexible(
                    child: Column(
                      children: <Widget>[
                        myRides.image != null
                            ? Padding(
                                padding: EdgeInsets.all(10),
                                child: Container(
                                  child: new ClipRRect(
                                    borderRadius:
                                        new BorderRadius.circular(8.0),
                                    child: Stack(
                                      children: <Widget>[
                                        FadeInImage.assetNetwork(
                                          placeholder:
                                              'assets/imgs/placeholder.png',
                                          image: myRides.image,
                                          height: 90,
                                          width: 90,
                                          fit: BoxFit.cover,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                width: 70.0,
                                height: 70.0,
                                decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                    image: new ExactAssetImage(
                                        'assets/imgs/placeholder.png'),
                                    fit: BoxFit.cover,
                                  ),
                                )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
}
