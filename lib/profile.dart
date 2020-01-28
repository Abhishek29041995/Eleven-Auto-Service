import 'dart:convert';
import 'dart:io';

import 'package:eleve11/landing_page.dart';
import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/utils/datepicker_formfield.dart';
import 'package:eleve11/utils/image_picker_handler.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage();

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<ProfilePage>
    with SingleTickerProviderStateMixin, ImagePickerListener {
  bool _status = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FocusNode myFocusNode = FocusNode();
  TextEditingController _namecontroller = new TextEditingController();
  TextEditingController _emailcontroller = new TextEditingController();
  TextEditingController _mobilecontroller = new TextEditingController();
  TextEditingController _dateController = new TextEditingController();
  Map userData = null;
  String acccessToken = "";
  final format = DateFormat("dd-MM-yyyy");
  bool _isLoading = false;
  File _image;
  AnimationController _controller;
  ImagePickerHandler imagePicker;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    imagePicker = new ImagePickerHandler(this, _controller.view);
    imagePicker.init();
    checkIsLogin();
  }

  Future<Null> checkIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    JsonCodec codec = new JsonCodec();
    setState(() {
      userData = codec.decode(prefs.getString("userData"));
    });
    _namecontroller.text = userData['name'];
    _emailcontroller.text = userData['email'];
    _mobilecontroller.text = userData['mobile'];
    _dateController.text = userData['dob'];
    acccessToken = prefs.getString("accessToken");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        body: new Stack(
          children: _buildWidget(),
        ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text(Translations.of(context).text('save')),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: () async {
                  if (_namecontroller.text == "") {
                    _displaySnackBar("Enter your name");
                  } else if (_emailcontroller.text == "") {
                    _displaySnackBar("Enter your email id");
                  } else if (!validateEmail(_emailcontroller.text)) {
                    _displaySnackBar("Enter valid email id");
                  } else if (_dateController.text == "") {
                    _displaySnackBar("Enter your date of birth");
                  } else {
                    setState(() {
                      _isLoading = true;
                    });
                    var request = new MultipartRequest(
                        "POST", Uri.parse(api_url + "user/profile"));
                    request.fields['name'] = _namecontroller.text;
                    request.fields['mobile'] = _mobilecontroller.text;
                    request.fields['dob'] = _dateController.text;
                    if (_image != null) {
                      request.files.add(await MultipartFile.fromPath(
                          'avatar', _image.path,
                          contentType: new MediaType('image', 'jpeg')));
                    }
                    request.fields['email'] = _emailcontroller.text;
                    request.headers['Authorization'] = "Bearer $acccessToken";
                    commonMethod(request).then((onResponse) {
                      onResponse.stream.transform(utf8.decoder).listen((value) {
                        setState(() {
                          _isLoading = false;
                        });
                        Map data = json.decode(value);
                        print(data);
                        presentToast(data['message'], context, 0);
                        if (data['code'] == 200) {
                          storeLoginData(data['data']);
                          Navigator.pushAndRemoveUntil(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new LandingPage()),
                            (Route<dynamic> route) => false,
                          );
                        }
                      });
                    });
                  }
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text(Translations.of(context).text('cancel')),
                textColor: Colors.white,
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: new Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        Future.delayed(
            Duration.zero,
            () => setState(() {
                  _status = false;
                }));
      },
    );
  }

  @override
  userImage(File _image) {
    setState(() {
      this._image = _image;
    });
  }

  bool validateEmail(String email) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    return emailValid;
  }

  Future<Null> storeLoginData(Map data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userData', json.encode(data));
  }

  List<Widget> _buildWidget() {
    List<Widget> list = new List();
    var mainView = Container(
      color: Colors.white,
      child: new ListView(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              (_status && userData != null)
                  ? Center(
                      child: new ClipRRect(
                          borderRadius: new BorderRadius.circular(100),
                          child: Stack(children: <Widget>[
                            FadeInImage.assetNetwork(
                              placeholder: 'assets/imgs/user.png',
                              image: userData['avatar'],
                              fit: BoxFit.cover,
                              height: 90,
                              width: 90,
                            )
                          ])),
                    )
                  : new GestureDetector(
                      onTap: () => imagePicker.showDialog(context),
                      child: new Center(
                        child: _image == null
                            ? new Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 20.0),
                                  child: new Stack(
                                      fit: StackFit.loose,
                                      children: <Widget>[
                                        new Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            new Container(
                                                width: 90.0,
                                                height: 90.0,
                                                decoration: new BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: new DecorationImage(
                                                    image: new ExactAssetImage(
                                                        'assets/imgs/user.png'),
                                                    fit: BoxFit.cover,
                                                  ),
                                                )),
                                          ],
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                top: 60.0, right: 80.0),
                                            child: new Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                new CircleAvatar(
                                                  backgroundColor: Colors.red,
                                                  radius: 15.0,
                                                  child: new Icon(
                                                    Icons.camera_alt,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                )
                                              ],
                                            )),
                                      ]),
                                ),
                              )
                            : new ClipRRect(
                                borderRadius: new BorderRadius.circular(100),
                                child: Stack(children: <Widget>[
                                  Image.file(_image,
                                      height: 90, width: 90, fit: BoxFit.cover)
                                ])),
                      ),
                    ),
              new Container(
                color: Color(0xffFFFFFF),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 25.0, top: 25.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(left: 25.0, right: 25.0),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new Text(
                                    Translations.of(context)
                                        .text('personal_info'),
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  _status ? _getEditIcon() : new Container(),
                                ],
                              )
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new TextFormField(
                            enabled: !_status,
                            controller: _namecontroller,
                            decoration: new InputDecoration(
                              contentPadding: EdgeInsets.all(15.0),
                              counterStyle: TextStyle(
                                height: double.minPositive,
                              ),
                              counterText: "",
                              labelText: Translations.of(context).text('name'),
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(5.0),
                                borderSide: new BorderSide(),
                              ),
                              //fillColor: Colors.green
                            ),
                            keyboardType: TextInputType.text,
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new TextFormField(
                            enabled: !_status,
                            controller: _emailcontroller,
                            decoration: new InputDecoration(
                              contentPadding: EdgeInsets.all(15.0),
                              counterStyle: TextStyle(
                                height: double.minPositive,
                              ),
                              counterText: "",
                              labelText: Translations.of(context).text('email'),
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(5.0),
                                borderSide: new BorderSide(),
                              ),
                              //fillColor: Colors.green
                            ),
                            keyboardType: TextInputType.emailAddress,
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new TextFormField(
                            enabled: false,
                            controller: _mobilecontroller,
                            decoration: new InputDecoration(
                              contentPadding: EdgeInsets.all(15.0),
                              counterStyle: TextStyle(
                                height: double.minPositive,
                              ),
                              counterText: "",
                              labelText: Translations.of(context)
                                  .text('mobile_number'),
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(5.0),
                                borderSide: new BorderSide(),
                              ),
                              //fillColor: Colors.green
                            ),
                            keyboardType: TextInputType.phone,
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: DateTimeField(
                            enabled: !_status,
                            controller: _dateController,
                            format: format,
                            decoration: new InputDecoration(
                              contentPadding: EdgeInsets.all(15.0),
                              counterStyle: TextStyle(
                                height: double.minPositive,
                              ),
                              counterText: "",
                              labelText: Translations.of(context).text('dob'),
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(5.0),
                                borderSide: new BorderSide(),
                              ),
                              //fillColor: Colors.green
                            ),
                            onShowPicker: (context, currentValue) {
                              return showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1900),
                                  initialDate: currentValue ?? DateTime.now(),
                                  lastDate: DateTime(2100));
                            },
                          )),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
    list.add(mainView);

    var footerView = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[_getActionButtons()]);
    if (!_status) {
      list.add(footerView);
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
