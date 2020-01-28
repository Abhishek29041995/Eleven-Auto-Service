import 'dart:async';
import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:eleve11/landing_page.dart';
import 'package:eleve11/main.dart';
import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/signup.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpPage extends StatefulWidget {
  String mobile;
  String phoneCode;

  OtpPage(String mobile, String phoneCode) {
    this.mobile = mobile;
    this.phoneCode = phoneCode;
  }

  @override
  OtpPageState createState() => OtpPageState(this.mobile, this.phoneCode);
}

class OtpPageState extends State<OtpPage> {
  TextEditingController controller1 = new TextEditingController();
  TextEditingController controller2 = new TextEditingController();
  TextEditingController controller3 = new TextEditingController();
  TextEditingController controller4 = new TextEditingController();
  TextEditingController controller5 = new TextEditingController();
  TextEditingController controller6 = new TextEditingController();

  TextEditingController currController = new TextEditingController();
  bool _isLoading = false;
  Timer _timer;
  int _start = 60;
  String mobile;
  String phoneCode;
  var _ScaffoldStateKey = new GlobalKey<ScaffoldState>();

  OtpPageState(String mobile, String phoneCode) {
    this.mobile = mobile;
    this.phoneCode = phoneCode;
  }

  @override
  void dispose() {
    super.dispose();
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    controller4.dispose();
    controller5.dispose();
    controller6.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currController = controller1;
    startTimer();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    _timer.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: new Scaffold(
        key: _ScaffoldStateKey,
        resizeToAvoidBottomPadding: false,
        backgroundColor: Color(0xFFeaeaea),
        body: new Stack(
          children: buildWidget(context),
        ),
      ),
    );
  }

  void inputTextToField(String str) {
    //Edit first textField
    if (currController == controller1) {
      controller1.text = str;
      currController = controller2;
    }

    //Edit second textField
    else if (currController == controller2) {
      controller2.text = str;
      currController = controller3;
    }

    //Edit third textField
    else if (currController == controller3) {
      controller3.text = str;
      currController = controller4;
    }

    //Edit fourth textField
    else if (currController == controller4) {
      controller4.text = str;
      currController = controller5;
    }

    //Edit fifth textField
    else if (currController == controller5) {
      controller5.text = str;
      currController = controller6;
    }

    //Edit sixth textField
    else if (currController == controller6) {
      controller6.text = str;
      currController = controller6;
    }
  }

  void deleteText() {
    if (currController.text.length == 0) {
    } else {
      currController.text = "";
      currController = controller5;
      return;
    }

    if (currController == controller1) {
      controller1.text = "";
    } else if (currController == controller2) {
      controller1.text = "";
      currController = controller1;
    } else if (currController == controller3) {
      controller2.text = "";
      currController = controller2;
    } else if (currController == controller4) {
      controller3.text = "";
      currController = controller3;
    } else if (currController == controller5) {
      controller4.text = "";
      currController = controller4;
    } else if (currController == controller6) {
      controller5.text = "";
      currController = controller5;
    }
  }

  void matchOtp(String mobile) {
    setState(() {
      _isLoading = true;
    });
    var request =
        new MultipartRequest("POST", Uri.parse(api_url + "user/verifyOtp"));
    request.fields['mobile'] = mobile;
    request.fields['otp'] = controller1.text +
        controller2.text +
        controller3.text +
        controller4.text +
        controller5.text +
        controller6.text;
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) {
        setState(() {
          _isLoading = false;
        });
        Map data = json.decode(value);
        if (data['code'] == 200) {
          AwesomeDialog(
              context: context,
              dialogType: DialogType.SUCCES,
              animType: AnimType.BOTTOMSLIDE,
              tittle: Translations.of(context).text('sucessfully'),
              desc: Translations.of(context).text('otp_matched'),
              btnOkOnPress: () {
                if (data['access_token'] == '') {
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (context) => new SignUp(mobile)));
                } else {
                  storeLoginData(data['user'], data['access_token']);
                  presentToast("Login successful", context, 0);
                  Navigator.pushAndRemoveUntil(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new LandingPage()),
                    (Route<dynamic> route) => false,
                  );
                }
              }).show();
        } else {
          presentToast(data['message'], context, 0);
        }
      });
    });
  }

  Future<Null> storeLoginData(Map data, String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', 'loggedIn');
    prefs.setString('accessToken', accessToken);
    prefs.setString('userData', json.encode(data));
  }

  List<Widget> buildWidget(BuildContext context) {
    List<Widget> widgetList = [
      Padding(
        padding: EdgeInsets.only(left: 0.0, right: 2.0),
        child: new Container(
          color: Colors.transparent,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
        child: new Container(
            alignment: Alignment.center,
            decoration: new BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                border: new Border.all(
                    width: 1.0, color: Color.fromRGBO(0, 0, 0, 0.1)),
                borderRadius: new BorderRadius.circular(4.0)),
            child: new TextField(
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
              ],
              enabled: false,
              controller: controller1,
              autofocus: false,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0, color: Colors.black),
            )),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
        child: new Container(
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              border: new Border.all(
                  width: 1.0, color: Color.fromRGBO(0, 0, 0, 0.1)),
              borderRadius: new BorderRadius.circular(4.0)),
          child: new TextField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
            ],
            controller: controller2,
            autofocus: false,
            enabled: false,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24.0, color: Colors.black),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
        child: new Container(
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              border: new Border.all(
                  width: 1.0, color: Color.fromRGBO(0, 0, 0, 0.1)),
              borderRadius: new BorderRadius.circular(4.0)),
          child: new TextField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
            ],
            keyboardType: TextInputType.number,
            controller: controller3,
            textAlign: TextAlign.center,
            autofocus: false,
            enabled: false,
            style: TextStyle(fontSize: 24.0, color: Colors.black),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
        child: new Container(
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              border: new Border.all(
                  width: 1.0, color: Color.fromRGBO(0, 0, 0, 0.1)),
              borderRadius: new BorderRadius.circular(4.0)),
          child: new TextField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
            ],
            textAlign: TextAlign.center,
            controller: controller4,
            autofocus: false,
            enabled: false,
            style: TextStyle(fontSize: 24.0, color: Colors.black),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
        child: new Container(
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              border: new Border.all(
                  width: 1.0, color: Color.fromRGBO(0, 0, 0, 0.1)),
              borderRadius: new BorderRadius.circular(4.0)),
          child: new TextField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
            ],
            textAlign: TextAlign.center,
            controller: controller5,
            autofocus: false,
            enabled: false,
            style: TextStyle(fontSize: 24.0, color: Colors.black),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 2.0, left: 2.0),
        child: new Container(
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              border: new Border.all(
                  width: 1.0, color: Color.fromRGBO(0, 0, 0, 0.1)),
              borderRadius: new BorderRadius.circular(4.0)),
          child: new TextField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
            ],
            textAlign: TextAlign.center,
            controller: controller6,
            autofocus: false,
            enabled: false,
            style: TextStyle(fontSize: 24.0, color: Colors.black),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 2.0, right: 0.0),
        child: new Container(
          color: Colors.transparent,
        ),
      ),
    ];
    List<Widget> list = new List();
    var mainView = Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                ),
                color: Colors.grey,
              )
            ],
          ),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    Translations.of(context).text('verify_number'),
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, top: 4.0, right: 16.0),
                  child: Text(
                    Translations.of(context).text('type_verification_code'),
                    style: TextStyle(
                        fontSize: 15.0, fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 30.0, top: 2.0, right: 30.0),
                  child: Text(
                    "+" + phoneCode + " " + mobile,
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Image(
                    image: AssetImage('assets/imgs/otp-icon.png'),
                    height: 120.0,
                    width: 120.0,
                  ),
                )
              ],
            ),
            flex: 90,
          ),
          Flexible(
            child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  GridView.count(
                      crossAxisCount: 8,
                      mainAxisSpacing: 10.0,
                      shrinkWrap: true,
                      primary: false,
                      scrollDirection: Axis.vertical,
                      children: List<Container>.generate(8,
                          (int index) => Container(child: widgetList[index]))),
                ]),
            flex: 20,
          ),
          _start == 0
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _start = 60;
                    });
                    startTimer();
                  },
                  child: Text(Translations.of(context).text('regenerate_otp')),
                )
              : RichText(
                  text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      text: Translations.of(context).text('regenerate_otp_in'),
                      children: <TextSpan>[
                      TextSpan(
                          text: _start.toString(),
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      TextSpan(
                          text: " sec", style: TextStyle(color: Colors.black))
                    ])),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, top: 16.0, right: 8.0, bottom: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        MaterialButton(
                          onPressed: () {
                            inputTextToField("1");
                          },
                          child: Text("1",
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center),
                        ),
                        MaterialButton(
                          onPressed: () {
                            inputTextToField("2");
                          },
                          child: Text("2",
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center),
                        ),
                        MaterialButton(
                          onPressed: () {
                            inputTextToField("3");
                          },
                          child: Text("3",
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                ),
                new Container(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, top: 4.0, right: 8.0, bottom: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        MaterialButton(
                          onPressed: () {
                            inputTextToField("4");
                          },
                          child: Text("4",
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center),
                        ),
                        MaterialButton(
                          onPressed: () {
                            inputTextToField("5");
                          },
                          child: Text("5",
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center),
                        ),
                        MaterialButton(
                          onPressed: () {
                            inputTextToField("6");
                          },
                          child: Text("6",
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                ),
                new Container(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, top: 4.0, right: 8.0, bottom: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        MaterialButton(
                          onPressed: () {
                            inputTextToField("7");
                          },
                          child: Text("7",
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center),
                        ),
                        MaterialButton(
                          onPressed: () {
                            inputTextToField("8");
                          },
                          child: Text("8",
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center),
                        ),
                        MaterialButton(
                          onPressed: () {
                            inputTextToField("9");
                          },
                          child: Text("9",
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                ),
                new Container(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, top: 4.0, right: 8.0, bottom: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        MaterialButton(
                            onPressed: () {
                              deleteText();
                            },
                            child: Image.asset('assets/imgs/delete.png',
                                width: 25.0, height: 25.0)),
                        MaterialButton(
                          onPressed: () {
                            inputTextToField("0");
                          },
                          child: Text("0",
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center),
                        ),
                        MaterialButton(
                            onPressed: () {
                              if (controller1.text.length > 0 &&
                                  controller2.text.length > 0 &&
                                  controller3.text.length > 0 &&
                                  controller4.text.length > 0 &&
                                  controller5.text.length > 0 &&
                                  controller6.text.length > 0) {
                                matchOtp(mobile);
                              } else {
                                _displaySnackBar("Enter valid OTP");
                              }
                            },
                            child: Image.asset('assets/imgs/success.png',
                                width: 25.0, height: 25.0)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            flex: 90,
          ),
        ],
      ),
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
    _ScaffoldStateKey.currentState.showSnackBar(snackBar);
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
}
