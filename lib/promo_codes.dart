import 'dart:convert';

//import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:eleve11/modal/order_list.dart';
import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/subscription.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:eleve11/widgets/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PromocodesPage extends StatefulWidget {
  _PromocodesPageState createState() => _PromocodesPageState();
}

class _PromocodesPageState extends State<PromocodesPage> {
  List<Widget> sample = new List();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<OrderList> serviceList = new List();
  Map userData = null;
  String acccessToken = "";
  bool _isLoading = true;

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
        key: _scaffoldKey,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              Translations.of(context).text('promo_codes'),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xff170e50)),
            ),
          )
        ],
      ),
    );
    list.add(appBar);
//    var subscription = Positioned(
//      right: 0,
//      top: 56,
//      child: Card(
//        color: Color(0xff170e50),
//        elevation: 4,
//        shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.only(
//                bottomLeft: Radius.circular(20), topLeft: Radius.circular(20))),
//        child: Padding(
//          padding: const EdgeInsets.all(8.0),
//          child: GestureDetector(
//            onTap: (){
//              Navigator.push(
//                  context,
//                  new MaterialPageRoute(
//                      builder: (context) =>
//                      new SubscriptionPlans()));
//            },
//            child: Text(
//              "Subscribe",
//              style: TextStyle(
//                color: Colors.white,
//                fontSize: 11,
//                fontFamily: 'Montserrat',
//              ),
//            ),
//          ),
//        ),
//      ),
//    );
//    list.add(subscription);
    var servicelist = Padding(
      padding: EdgeInsets.only(top: 80),
      child: ListView.separated(
          separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(left: 0, right: 0),
                child: Divider(
                  color: Colors.black12,
                ),
              ),
          itemCount: serviceList.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(2.0)),
                          color: Color(0xFFFFD180)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onLongPress: () {
//                            ClipboardManager.copyToClipBoard(serviceList[index].code).then((result) {
//                              final snackBar = SnackBar(
//                                content: Text('Copied to Clipboard'),
//                                action: SnackBarAction(
//                                  label: 'Undo',
//                                  onPressed: () {},
//                                ),
//                              );
//                              _scaffoldKey.currentState.showSnackBar(snackBar);
//                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FadeInImage.assetNetwork(
                                placeholder: 'assets/imgs/placeholder.png',
                                image: serviceList[index].image,
                                height: 20,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                serviceList[index].code,
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      serviceList[index].name,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Divider(),
                    Text(
                      serviceList[index].description,
                      style: TextStyle(fontSize: 13),
                    ),
                    ExpandableNotifier(
                      // <-- Provides ExpandableController to its children
                        child: Column(
                            children: [
                              Expandable(
                                // <-- Driven by ExpandableController from ExpandableNotifier
                                  collapsed: ExpandableButton(child: Padding(
                                    padding: const EdgeInsets.only(top: 4,bottom: 4,right: 4),
                                    child: Text(
                                        "+More",style:TextStyle(color: Colors.deepOrangeAccent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',)),
                                  )),
                                  expanded: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Html(
                                        data: serviceList[index].terms,
                                        defaultTextStyle:TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Montserrat',),
                                        padding: EdgeInsets.fromLTRB(
                                            16, 8, 16, 8),
                                      ),
                                      ExpandableButton(child: Padding(
                                        padding: const EdgeInsets.only(top: 4,bottom: 4,right: 4),
                                        child: Text(
                                            "-Less",style:TextStyle(color: Colors.deepOrangeAccent,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Montserrat',)),
                                      ))
                                    ],
                                  )),
                            ])
                    )
                  ],
                ));
          }),
    );
    list.add(servicelist);
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

  List<OrderList> getServices() {
    setState(() {
      _isLoading = true;
    });
    var request =
        new MultipartRequest("GET", Uri.parse(api_url + "user/coupons/list"));
    request.headers['Authorization'] = "Bearer $acccessToken";
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) {
        setState(() {
          _isLoading = false;
        });
        try {
          Map data = json.decode(value);
          if (data['code'] == 200) {
            List<OrderList> tempList = new List();
            if (data['data'].length > 0) {
              for (var i = 0; i < data['data'].length; i++) {
                print(data['data'][i]['terms']);
                tempList.add(new OrderList(
                    data['data'][i]['id'].toString(),
                    data['data'][i]['name'],
                    data['data'][i]['description'],
                    data['data'][i]['code'],
                    data['data'][i]['value'],
                    data['data'][i]['type'],
                    data['data'][i]['image'],
                    data['data'][i]['terms'],
                    data['data'][i]['for_new_user'],
                    data['data'][i]['expires_on'],
                    data['data'][i]['active'],
                    data['data'][i]['created_at'],
                    data['data'][i]['updated_at']));
              }
              setState(() {
                serviceList = tempList;
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
}
