import 'dart:convert';
import 'dart:io';
import 'package:eleve11/landing_page.dart';
import 'package:eleve11/modal/service.dart';
import 'package:eleve11/service_detail_page.dart';
import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/utils/datepicker_formfield.dart';
import 'package:eleve11/utils/image_picker_handler.dart';
import 'package:eleve11/utils/pinkRedGradient.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:eleve11/widgets/wavy_design.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gender_selection/gender_selection.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  String mobile;

  SignUp(String mobile) {
    this.mobile = mobile;
  }

  _SignUp createState() => _SignUp(this.mobile);
}

class _SignUp extends State<SignUp>
    with TickerProviderStateMixin, ImagePickerListener {
  var _ScaffoldStateKey = new GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  TextEditingController _namecontroller = new TextEditingController();
  TextEditingController _emailcontroller = new TextEditingController();
  TextEditingController _datecontroller = new TextEditingController();
  TextEditingController _hearAboutUscontroller = new TextEditingController();
  final format = DateFormat("dd-MM-yyyy");
  String selectedgender = "";
  File _image;
  AnimationController _controller;
  ImagePickerHandler imagePicker;
  String mobile;

  _SignUp(String mobile) {
    this.mobile = mobile;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    imagePicker = new ImagePickerHandler(this, _controller);
    imagePicker.init();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        key: _ScaffoldStateKey,
        body: Stack(
          children: _buildForm(context),
        ),
      ),
    );
  }

  List<Widget> _buildForm(BuildContext context) {
    var list = new List<Widget>();
    var appBar = Row(
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
    );
    list.add(appBar);
    var mainView = new ListView(
      children: <Widget>[
        new GestureDetector(
          onTap: () => imagePicker.showDialog(context),
          child: new Center(
            child: _image == null
                ? new Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: new Stack(fit: StackFit.loose, children: <Widget>[
                        new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
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
                            padding: EdgeInsets.only(top: 60.0, right: 80.0),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              Translations.of(context).text('u_are'),
              style: TextStyle(
                  color: Color(0xff3da4ab),
                  fontSize: 20.0,
                  fontFamily: 'Montserrat'),
            ),
          ),
        ),
        GenderSelection(
          maleText: "",
          //default Male
          femaleText: "",
          //default Female
          linearGradient: pinkRedGradient,
          selectedGenderIconBackgroundColor: Colors.indigo,
          // default red
          checkIconAlignment: Alignment.centerRight,
          // default bottomRight
          selectedGenderCheckIcon: null,
          // default Icons.check
          onChanged: (Gender gender) {
            if (gender == Gender.Male) {
              selectedgender = "MALE";
            } else {
              selectedgender = "FEMALE";
            }
          },
          equallyAligned: true,
          animationDuration: Duration(milliseconds: 400),
          isCircular: true,
          // default : true,
          isSelectedGenderIconCircular: true,
          opacityOfGradient: 0.6,
          padding: const EdgeInsets.all(3),
          size: 70, //default : 120
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
          child: new TextFormField(
            controller: _namecontroller,
            decoration: new InputDecoration(
              contentPadding: EdgeInsets.all(15.0),
              counterStyle: TextStyle(
                height: double.minPositive,
              ),
              counterText: "",
              labelText: Translations.of(context).text('enter_name'),
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
            controller: _emailcontroller,
            decoration: new InputDecoration(
              contentPadding: EdgeInsets.all(15.0),
              counterStyle: TextStyle(
                height: double.minPositive,
              ),
              counterText: "",
              labelText: Translations.of(context).text('enter_email'),
              fillColor: Colors.white,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(5.0),
                borderSide: new BorderSide(),
              ),
              //fillColor: Colors.green
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
          child: new DateTimeField(
            format: format,
            controller: _datecontroller,
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
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
          child: new TextFormField(
            maxLines: 5,
            controller: _hearAboutUscontroller,
            decoration: new InputDecoration(
              contentPadding: EdgeInsets.all(15.0),
              counterStyle: TextStyle(
                height: double.minPositive,
              ),
              counterText: "",
              alignLabelWithHint: true,
              labelText: Translations.of(context).text('how_hear_aboutus'),
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
          height: 20,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 40, 8, 40),
            child: ConstrainedBox(
                constraints: const BoxConstraints(
                    minWidth: double.infinity, minHeight: 45.0),
                child: RaisedButton(
                    child: new Text(Translations.of(context).text('signup')),
                    onPressed: () async {
                      if (_image == null) {
                        _displaySnackBar("Upload profile image");
                      } else if (selectedgender == "") {
                        _displaySnackBar("Select gender");
                      } else if (_namecontroller.text == "") {
                        _displaySnackBar("Enter your name");
                      } else if (_emailcontroller.text == "") {
                        _displaySnackBar("Enter your email id");
                      } else if (!validateEmail(_emailcontroller.text)) {
                        _displaySnackBar("Enter valid email id");
                      } else if (_datecontroller.text == "") {
                        _displaySnackBar("Enter your date of birth");
                      } else if (_hearAboutUscontroller.text == "") {
                        _displaySnackBar(
                            "Please let us know how you hear about us?");
                      } else {
                        print("111111111111111");
                        print(selectedgender);
                        setState(() {
                          print("111111111111111");
                          print(selectedgender);
                          _isLoading = true;
                        });
                        var request = new MultipartRequest(
                            "POST", Uri.parse(api_url + "user/register"));
                        request.fields['name'] = _namecontroller.text;
                        request.fields['mobile'] = mobile;
                        request.fields['gender'] = selectedgender;
                        request.fields['dob'] = _datecontroller.text;
                        request.fields['heard_by'] =
                            _hearAboutUscontroller.text;
                        request.files.add(await MultipartFile.fromPath(
                            'avatar', _image.path,
                            contentType: new MediaType('image', 'jpeg')));
                        request.fields['email'] = _emailcontroller.text;
                        commonMethod(request).then((onResponse) {
                          onResponse.stream
                              .transform(utf8.decoder)
                              .listen((value) {
                            setState(() {
                              _isLoading = false;
                            });
                            try{
                            Map data = json.decode(value);
                            print(data);
                            presentToast(data['message'], context, 0);
                            if (data['code'] == 200) {
                              storeLoginData(
                                  data['user'], data['access_token']);
                              Navigator.pushAndRemoveUntil(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => new LandingPage()),
                                (Route<dynamic> route) => false,
                              );
                            }
                            } catch (onError) {
                              _displaySnackBar(Translations.of(context).text('server_error'));
                            }
                          }).onError((err) =>
                          {_displaySnackBar(Translations.of(context).text('server_error'))});
                        });
                      }
                    },
                    textColor: Colors.white,
                    color: Color(0xff170e50),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)))),
          ),
        ),
      ],
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

  Future<Null> storeLoginData(Map data, String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', 'loggedIn');
    prefs.setString('accessToken', accessToken);
    prefs.setString('userData', json.encode(data));
  }
}
