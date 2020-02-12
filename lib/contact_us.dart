import 'dart:convert';

import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  bool _isLoading = false;
  String acccessToken = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _subjectcontroller = new TextEditingController();
  TextEditingController _messagecontroller = new TextEditingController();
  String mobile = "";
  String email = "";
  String address = "";

  @override
  void initState() {
    super.initState();
    checkIsLogin();
  }

  Future<Null> checkIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    acccessToken = prefs.getString("accessToken");
    getContactDetails();
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
        title: new Text(Translations.of(context).text('contacts')),
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
        child: ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () => launch("tel:"+mobile),
                icon: Icon(
                  Icons.call,
                  color: Colors.orange,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Translations.of(context).text('contact'),
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      mobile,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Montserrat',
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () => launch("mailto:"+email),
                icon: Icon(
                  Icons.mail,
                  color: Colors.orange,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        color: Colors.black,
                      ),
                    ),
                    Text(
                     email,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Montserrat',
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () => {},
                icon: Icon(
                  Icons.location_on,
                  color: Colors.orange,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Translations.of(context).text('address'),
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      address,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Montserrat',
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Divider(),
              ),
              Expanded(
                  child: Text(
                Translations.of(context).text('writeus'),
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )),
              Expanded(
                child: Divider(),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
          child: new TextFormField(
            controller: _subjectcontroller,
            decoration: new InputDecoration(
              contentPadding: EdgeInsets.all(15.0),
              counterStyle: TextStyle(
                height: double.minPositive,
              ),
              counterText: "",
              labelText: Translations.of(context).text('subject'),
              fillColor: Colors.white,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(5.0),
                borderSide: new BorderSide(),
              ),
              //fillColor: Colors.green
            ),
            keyboardType: TextInputType.text,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
          child: new TextFormField(
            maxLines: 5,
            controller: _messagecontroller,
            decoration: new InputDecoration(
              contentPadding: EdgeInsets.all(15.0),
              counterStyle: TextStyle(
                height: double.minPositive,
              ),
              counterText: "",
              alignLabelWithHint: true,
              labelText: Translations.of(context).text('message'),
              fillColor: Colors.white,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(5.0),
                borderSide: new BorderSide(),
              ),
              //fillColor: Colors.green
            ),
            keyboardType: TextInputType.text,
          ),
        ),
      ],
    )
//        ),
        );
    list.add(mainView);
    var footerView = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Center(
            child: new RaisedButton(
              child: new Text(Translations.of(context).text('continue')),
              textColor: Colors.white,
              color: Colors.lightGreen,
              onPressed: () {
                if (_subjectcontroller.text == '') {
                  _displaySnackBar(Translations.of(context).text('enter_subject'));
                } else if (_messagecontroller.text == '') {
                  _displaySnackBar(Translations.of(context).text('enter_message'));
                } else {
                  submitQuery();
                }
              },
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(20.0)),
            ),
          )
        ]);
    list.add(footerView);
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

  void submitQuery() {
    setState(() {
      _isLoading = true;
    });
    var request = new MultipartRequest(
        "POST", Uri.parse(api_url + "user/contact/feedback"));
    request.fields['subject'] = _subjectcontroller.text;
    request.fields['message'] = _messagecontroller.text;
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
            presentToast('Feedback sent successfully', context, 0);
            setState(() {
              _subjectcontroller.text = "";
              _messagecontroller.text = "";
            });
          }
        } catch (onError) {
          _displaySnackBar(Translations.of(context).text('server_error'));
        }
      }).onError((err) =>
          {_displaySnackBar(Translations.of(context).text('server_error'))});
    });
  }

  void getContactDetails() {
    setState(() {
      _isLoading = true;
    });
    var request = new MultipartRequest("GET", Uri.parse(api_url + "contact"));
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
              mobile = data['data']['phone'];
              email = data['data']['email'];
              address = data['data']['address'];
            });
          }
        } catch (onError) {
          _displaySnackBar(Translations.of(context).text('server_error'));
        }
      }).onError((err) =>
          {_displaySnackBar(Translations.of(context).text('server_error'))});
    });
  }
}
