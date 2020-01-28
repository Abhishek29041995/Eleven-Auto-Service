import 'dart:convert';

import 'package:eleve11/modal/notification.dart';
import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notifications extends StatefulWidget {
  _NotificationsState createState() => _NotificationsState();
}
class _NotificationsState extends State<Notifications> {
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<NotificationL> notificationList = new List();

  String acccessToken = "";
  @override
  void initState() {
    super.initState();
    checkIsLogin();
  }
  Future<Null> checkIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    acccessToken = prefs.getString("accessToken");
    getNotifications();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
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
        title: new Text(Translations.of(context).text('notifications')),
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

  void getNotifications() {
    setState(() {
      _isLoading = true;
    });
    var request = new MultipartRequest("GET", Uri.parse(api_url + "user/my-notifications"));
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
            List<NotificationL> tempList = new List();
            if (data['data'].length > 0) {
              for (var i = 0; i < data['data'].length; i++) {
                tempList.add(new NotificationL(
                    data['data'][i]['id'].toString(),
                    data['data'][i]['user_id'],
                    data['data'][i]['title'],
                    data['data'][i]['body'],
                    data['data'][i]['created_at'],
                    data['data'][i]['updated_at']));
              }
              setState(() {
                notificationList = tempList;
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
        itemCount: notificationList.length,
        itemBuilder: (BuildContext context, int index) {
          return CardData(notificationList[index], index + 1);
        },
      ),
    );
  }

  CardData(NotificationL notificationList, int i) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset("assets/imgs/notification.svg",
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
                      new Text(notificationList.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                              color: Colors.black,
                              fontSize: 14)),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(notificationList.body,
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
            padding: const EdgeInsets.all(8.0),
            child: Text(notificationList.created_at['new_date'],
                softWrap: true,
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.grey,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
