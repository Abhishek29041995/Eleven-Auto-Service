import 'dart:convert';

import 'package:eleve11/checkOrderHistoryDetails.dart';
import 'package:eleve11/feedback_dynamic.dart';
import 'package:eleve11/main.dart';
import 'package:eleve11/modal/booking_track.dart';
import 'package:eleve11/modal/orders.dart';
import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:eleve11/widgets/dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckOrderHistory extends StatefulWidget {
  String from;

  CheckOrderHistory(String from) {
    this.from = from;
  }

  @override
  _CheckOrderHistory createState() => _CheckOrderHistory(this.from);
}

class _CheckOrderHistory extends State<CheckOrderHistory> {
  String acccessToken = "";
  bool _isLoading = false;
  List<Orders> orderList = new List();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String from;

  _CheckOrderHistory(String from) {
    this.from = from;
  }

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
    getServices();
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
        title: from == 'Feedback'
            ? new Text(Translations.of(context).text('feedback'))
            : new Text(Translations.of(context).text('check_order_history')),

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

  bodyCard() {
    return from == "Feedback"
        ? orderList.where((i) => i.feedback_count == "0").toList().length > 0
            ? Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: from == "Feedback"
                      ? orderList
                          .where((i) => i.feedback_count == "0")
                          .toList()
                          .length
                      : orderList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CardData(from == "Feedback"
                        ? orderList
                            .where((i) => i.feedback_count == "0")
                            .toList()[index]
                        : orderList[index]);
                  },
                ),
              )
            : Expanded(
                child: Center(
                  child: Text(
                    Translations.of(context).text('no_feedback'),
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.black,
                        fontSize: 14),
                  ),
                ),
              )
        : orderList.length > 0
            ? Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: from == "Feedback"
                      ? orderList
                          .where((i) => i.feedback_count == "0")
                          .toList()
                          .length
                      : orderList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CardData(from == "Feedback"
                        ? orderList
                            .where((i) => i.feedback_count == "0")
                            .toList()[index]
                        : orderList[index]);
                  },
                ),
              )
            : Expanded(
                child: Center(
                  child: Text(
                    'No orders found',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.black,
                        fontSize: 14),
                  ),
                ),
              );
  }

  CardData(Orders orderList) {
    return InkWell(
      onTap: () {
        print("clicked");
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CheckOrderHistoryDetails(orderList)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Wrap(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(6),
                    child: Image(
                        image: AssetImage('assets/smart-car.png'),
                        width: 30,
                        height: 30,
                        fit: BoxFit.fitHeight),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(orderList.booking_ref,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          )),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(Translations.of(context).text('ordered_on') + orderList.updated_at,
                          style: TextStyle(color: Colors.black, fontSize: 11)),
                      SizedBox(height: 10.0),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.red),
                          ),
                          SizedBox(width: 5.0),
                          Text(Translations.of(context).text('booking_date') + orderList.created_at,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 11)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Dash(
                            direction: Axis.vertical,
                            length: 10,
                            dashLength: 2,
                            dashColor: Colors.red),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.green),
                          ),
                          SizedBox(width: 5.0),
                          Text(Translations.of(context).text('booking_date') + orderList.created_at,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 11)),
                        ],
                      ),
                      from == 'Feedback' &&
                              int.parse(orderList.feedback_count) == 0
                          ? FlatButton.icon(
                              shape: Border.all(width: 1, color: Colors.orange),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) =>
                                            new FeedbackDynamic(
                                                orderList.id))).then((onValue) {
                                  getServices();
                                });
                              },
                              icon: Icon(
                                Icons.feedback,
                                color: Colors.grey,
                              ),
                              label: Text(
                                "Give Feedback",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ))
                          : SizedBox(
                              height: 0,
                              width: 0,
                            )
                    ],
                  ),
                ],
              ),
              Flexible(
                child: Column(
                  children: <Widget>[
                    Text("IQD " + orderList.discounted_price,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        )),
                    orderList.worker != null
                        ? Padding(
                            padding: EdgeInsets.all(10),
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
                                      image: orderList.worker['avatar'],
                                      fit: BoxFit.cover,
                                      height: 70,
                                      width: 70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            width: 70.0,
                            height: 70.0,
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                image:
                                    new ExactAssetImage('assets/imgs/user.png'),
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
    );
  }

  getServices() {
    setState(() {
      _isLoading = true;
    });
    var request = new MultipartRequest(
        "GET", Uri.parse(api_url + "user/booking/history"));
    request.headers['Authorization'] = "Bearer $acccessToken";
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) {
        setState(() {
          _isLoading = false;
        });
        try {
          Map data = json.decode(value);
          if (data['code'] == 200) {
            List<Orders> tempList = new List();
            if (data['data'].length > 0) {
              for (var i = 0; i < data['data'].length; i++) {
                List<BookingTrack> tempBookingTrList = new List();
                for (var j = 0;
                    j < data['data'][i]['booking_progress'].length;
                    j++) {
                  tempBookingTrList.add(BookingTrack(
                      data['data'][i]['booking_progress'][j]['id'].toString(),
                      data['data'][i]['booking_progress'][j]['booking_id'],
                      data['data'][i]['booking_progress'][j]['comment'],
                      data['data'][i]['booking_progress'][j]['created_at'],
                      data['data'][i]['booking_progress'][j]['updated_at']));
                }
                tempList.add(new Orders(
                    data['data'][i]['id'].toString(),
                    data['data'][i]['booking_ref'],
                    data['data'][i]['user_id'],
                    data['data'][i]['address_id'],
                    data['data'][i]['service_id'],
                    data['data'][i]['actual_price'],
                    data['data'][i]['discount_value'],
                    data['data'][i]['discount_type'],
                    data['data'][i]['payment_type'],
                    data['data'][i]['subscription_id'],
                    data['data'][i]['subscription_discount'],
                    data['data'][i]['discounted_price'],
                    data['data'][i]['user_lat'],
                    data['data'][i]['user_lon'],
                    data['data'][i]['status'],
                    data['data'][i]['created_at'],
                    data['data'][i]['updated_at'],
                    data['data'][i]['service'],
                    data['data'][i]['address'],
                    data['data'][i]['worker'],
                    data['data'][i]['feedback_count'],
                    tempBookingTrList));
              }
              setState(() {
                orderList = tempList;
              });
            }
          }
        } catch (onError) {
          print(onError);
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
        label: Translations.of(context).text('ok'),
        onPressed: () {
          // Some code to undo the change!
        },
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
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
          color: Color(0xffffffff),
          borderRadius: new BorderRadius.circular(5.0)),
    );
  }
}

class MySeparator extends StatelessWidget {
  final double width;
  final Color color;

  const MySeparator({this.width = 1, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
//        final boxWidth = constraints.constrainWidth();
        final boxWidth = constraints.constrainWidth();
        final dashWidth = width;
        final dashHeight = 2.0;
        final dashCount = (boxWidth / dashWidth).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.vertical,
        );
      },
    );
  }
}
