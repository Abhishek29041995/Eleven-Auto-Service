import 'dart:convert';

import 'package:circular_check_box/circular_check_box.dart';
import 'package:eleve11/landing_page.dart';
import 'package:eleve11/modal/service_list.dart';
import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/show_directions.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverViewOrder extends StatefulWidget {
  List<ServiceList> serviceList;
  String price;
  String address_id;
  String latitude;
  String longitude;
  String selectedServiceCat;
  String type;

  OverViewOrder(
      List<ServiceList> serviceList,
      String type,
      String price,
      String address_id,
      String latitude,
      String longitude,
      String selectedServiceCat) {
    this.serviceList = serviceList;
    this.type = type;
    this.price = price;
    this.address_id = address_id;
    this.latitude = latitude;
    this.longitude = longitude;
    this.selectedServiceCat = selectedServiceCat;
  }

  _OverViewOrderState createState() => _OverViewOrderState(
      this.serviceList,
      this.type,
      this.price,
      this.address_id,
      this.latitude,
      this.longitude,
      this.selectedServiceCat);
}

class _OverViewOrderState extends State<OverViewOrder> {
  List<ServiceList> serviceList;
  String isCash = "0";
  String price = "";
  String type = "";
  String address_id;
  String latitude;
  String longitude;
  String selectedServiceCat;
  String originalPrice = "";
  String acccessToken = "";
  Map userData = null;
  bool _isLoading = false;
  TextEditingController _promoCodecontroller = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int textLength = 0;
  bool couponapplied = false;
  bool subscribed = false;
  String msg = "";
  String subdiscountId = "";
  String subdiscountValue = "0";
  String subdiscountType = "0";
  String subdiscountedPrice = "0";

  String discountCode = "";
  String discountValue = "0";
  String discountType = "0";
  String discountedPrice = "0";

  bool showImage = true;
  bool focuschanged = false;

  _OverViewOrderState(
      List<ServiceList> serviceList,
      String type,
      String price,
      String address_id,
      String latitude,
      String longitude,
      String selectedServiceCat) {
    this.serviceList = serviceList;
    this.originalPrice = price;
    this.type = type;
    this.price = price;
    this.address_id = address_id;
    this.latitude = latitude;
    this.longitude = longitude;
    this.selectedServiceCat = selectedServiceCat;
  }

  Future<Null> checkIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    JsonCodec codec = new JsonCodec();
    userData = codec.decode(prefs.getString("userData"));
    acccessToken = prefs.getString("accessToken");
    getSubscription();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        setState(() {
          showImage = !showImage;
          print(showImage);
        });
      },
    );

    checkIsLogin();
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
              "Overview",
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
    var servicelist = showImage
        ? Padding(
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
                  return Padding(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                      ],
                    ),
                  );
                }),
          )
        : SizedBox(
            height: 0,
          );
    list.add(servicelist);
    var footer = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    maxLength: 10,
                    onChanged: (text) {
                      setState(() {
                        textLength = text.length;
                      });
                    },
                    controller: _promoCodecontroller,
                    style: TextStyle(fontSize: 13.0),
                    decoration: new InputDecoration(
                      counterStyle: TextStyle(
                        height: double.minPositive,
                      ),
                      counterText: "",
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: couponapplied ? Colors.green : Colors.red),
                      ),
                      errorText: couponapplied
                          ? "PROMO Applied successfully"
                          : msg != '' ? msg : null,
                      errorStyle: TextStyle(
                          color: couponapplied ? Colors.green : Colors.red),
                      labelText: "PROMO CODE",
                      hintStyle: TextStyle(fontSize: 13),
                      fillColor: Colors.white,
                      //fillColor: Colors.green
                    ),
                  ),
                ),
                textLength > 0
                    ? Wrap(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              couponCheck();
                            },
                            child: Text(
                              "Apply",
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.deepOrangeAccent),
                            ),
                          )
                        ],
                      )
                    : Text('')
              ],
            ),
          ),
          (couponapplied || subscribed)
              ? Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, right: 16.0, top: 20),
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                  Translations.of(context)
                                      .text('original_price'),
                                  style: TextStyle(
                                      fontFamily: 'Montserrat', fontSize: 12)),
                              Text(originalPrice,
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("Discount",
                                  style: TextStyle(
                                      fontFamily: 'Montserrat', fontSize: 12)),
                              Text(
                                  (double.parse(discountedPrice) +
                                          double.parse(subdiscountedPrice))
                                      .toStringAsFixed(2),
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(Translations.of(context).text('amounttopay'),
                                  style: TextStyle(
                                      fontFamily: 'Montserrat', fontSize: 12)),
                              Text(
                                  (double.parse(originalPrice) -
                                          (double.parse(discountedPrice) +
                                              double.parse(subdiscountedPrice)))
                                      .toStringAsFixed(2),
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  width: 10,
                ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isCash = "1";
                    });
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        "assets/imgs/fastpay.png",
                        height: 15,
                      ),
                      (isCash != null && isCash == "1")
                          ? CircularCheckBox(
                              value: true,
                              activeColor: Color(0xff170e50),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              onChanged: (bool x) {},
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
                Container(
                  height: 18,
                  width: 1,
                  color: Colors.grey,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isCash = "2";
                    });
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        "assets/imgs/cash.png",
                        height: 15,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Pay Cash",
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xff34a953)),
                      ),
                      (isCash != null && isCash == "2")
                          ? CircularCheckBox(
                              value: true,
                              activeColor: Color(0xff170e50),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              onChanged: (bool x) {},
                            )
                          : SizedBox(),
                    ],
                  ),
                )
              ],
            ),
          ),
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
                      if (isCash == '0') {
                        _displaySnackBar('Choose payment mode');
                      } else {
                        bookingAdd();
                      }
                    },
                    textColor: Colors.white,
                    color: Color(0xff170e50),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)))),
          )
        ]);
    list.add(footer);
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

  void showSucessDialog(data) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    "assets/imgs/drop.svg",
                    allowDrawingOutsideViewBox: true,
                    height: 40,
                    width: 40,
                  ),
                  Text(
                    Translations.of(context).text('thank_u'),
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    Translations.of(context).text('for_ordering'),
                    style: TextStyle(fontSize: 13, fontFamily: 'Montserrat'),
                  ),
                  Text(
                    data['booking_ref'],
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Color(0xff68CCEA)),
                  ),
                  Text(
                    Translations.of(context).text('is_reference_no'),
                    style: TextStyle(fontSize: 13, fontFamily: 'Montserrat'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 10, top: 20),
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            minWidth: double.infinity, minHeight: 35.0),
                        child: RaisedButton(
                            child:
                                new Text(Translations.of(context).text('ok')),
                            onPressed: () {
//                              Navigator.push(
//                                  context,
//                                  new MaterialPageRoute(
//                                      builder: (context) =>
//                                          new ShowDirections(data)));
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
                                borderRadius:
                                    new BorderRadius.circular(30.0)))),
                  )
                ],
              ),
            ),
          );
        });
  }

  void couponCheck() {
    setState(() {
      _isLoading = true;
    });
    var request =
        new MultipartRequest("POST", Uri.parse(api_url + "user/coupon/check"));
    request.fields['code'] = _promoCodecontroller.text;
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
              couponapplied = true;
              discountCode = data['coupon']['code'];
              if (data['coupon']['type'] == 'PERCENTAGE') {
                discountedPrice = (double.parse(originalPrice) *
                        (double.parse(data['coupon']['value']) / 100))
                    .toStringAsFixed(2);
              } else {
                discountedPrice =
                    double.parse(data['coupon']['value']).toStringAsFixed(2);
              }
              discountValue = data['coupon']['value'];
              discountType = data['coupon']['type'];
            });
          } else {
            setState(() {
              couponapplied = false;
              msg = data['message'];
            });
          }
        } catch (onError) {
          _displaySnackBar(Translations.of(context).text('server_error'));
        }
      }).onError((err) =>
          {_displaySnackBar(Translations.of(context).text('server_error'))});
    });
  }

  void getSubscription() {
    setState(() {
      _isLoading = true;
    });
    var request = new MultipartRequest(
        "GET", Uri.parse(api_url + "user/subscription/subscribed-plans"));
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
              if (data['data'].length > 0) {
                subscribed = true;
                subdiscountId = data['data'][0]['subscription_id'];
                if (data['data'][0]['subscription']['discount_type'] ==
                    'PERCENTAGE') {
                  subdiscountedPrice = (double.parse(originalPrice) *
                          (double.parse(
                                  data['data'][0]['subscription']['discount']) /
                              100))
                      .toStringAsFixed(2);
                } else {
                  subdiscountedPrice =
                      double.parse(data['data'][0]['subscription']['discount'])
                          .toStringAsFixed(2);
                }
                subdiscountValue = data['data'][0]['subscription']['discount'];
                subdiscountType =
                    data['data'][0]['subscription']['discount_type'];
              }
            });
          } else {
            setState(() {
              subscribed = false;
            });
          }
        } catch (onError) {
          print(onError);
          _displaySnackBar(Translations.of(context).text('server_error'));
        }
      }).onError((err) =>
          {_displaySnackBar(Translations.of(context).text('server_error'))});
    });
  }

  void bookingAdd() {
    setState(() {
      _isLoading = true;
    });
    var request =
        new MultipartRequest("POST", Uri.parse(api_url + "user/booking/add"));
    request.fields['address_id'] = address_id;
    request.fields['service_id'] = selectedServiceCat;
    request.fields['actual_price'] = originalPrice;
    request.fields['payment_type'] = isCash == '1' ? "FAST PAY" : "COD";
    request.fields['discount_value'] = discountValue;
    request.fields['discount_type'] = discountType;
    request.fields['discounted_price'] = (double.parse(originalPrice) -
            (double.parse(discountedPrice) + double.parse(subdiscountedPrice)))
        .toStringAsFixed(2);
    request.fields['user_lat'] = latitude;
    request.fields['user_lon'] = longitude;
    request.fields['car_type'] = type;
    request.fields['discount_code'] = discountCode;
    request.fields['subscription_id'] = subdiscountId;
    request.fields['subscription_discount'] = subdiscountedPrice;
    request.headers['Authorization'] = "Bearer $acccessToken";
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) {
        setState(() {
          _isLoading = false;
        });
        try {
          Map data = json.decode(value);
          presentToast(data['message'], context, 0);
          if (data['code'] == 200) {
            showSucessDialog(data['data']);
          } else {
            presentToast(data['message'], context, 0);
          }
        } catch (onError) {
          print(onError);
          _displaySnackBar(Translations.of(context).text('server_error'));
        }
      }).onError((err) =>
          {_displaySnackBar(Translations.of(context).text('server_error'))});
    });
  }
}
