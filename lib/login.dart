import 'dart:async';
import 'dart:convert';

import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:eleve11/landing_page.dart';
import 'package:eleve11/otp.dart';
import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  _LoginSate createState() => _LoginSate();
}

class _LoginSate extends State<LoginPage> {
  final LocalAuthentication auth = LocalAuthentication();
  String _authorized = 'Not Authorized';
  Country _selectedDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode('964');
  bool _canCheckBiometrics = false;
  var _ScaffoldStateKey = new GlobalKey<ScaffoldState>();
  bool _isLoggedIn = false;
  Map userProfile;
  final facebookLogin = FacebookLogin();

  _loginWithFB() async {
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}');
        final profile = jsonDecode(graphResponse.body);
        print(profile);
        setState(() {
          userProfile = profile;
          _isLoggedIn = true;
        });
        break;

      case FacebookLoginStatus.cancelledByUser:
        setState(() => _isLoggedIn = false);
        break;
      case FacebookLoginStatus.error:
        setState(() => _isLoggedIn = false);
        break;
    }
  }

  _logout() {
    facebookLogin.logOut();
    if (!mounted) return;
    setState(() {
      _isLoggedIn = false;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
    _authorized = authenticated ? "Authenticated" : 'Not Authorized';
    if (authenticated) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', 'loggedIn');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => new LandingPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  bool _isLoading = false;
  bool showImage = true;
  String telecom = "iraq";
  String bio = "";
  TextEditingController _controller = new TextEditingController();

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
    _checkBiometrics();
  }

  Future<Null> checkIsLogin() async {
    String _token = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token");
    bio = prefs.getString("bio");
    if (_token != "" && _token != null) {
      //replace it with the login page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => new LandingPage()),
        (Route<dynamic> route) => false,
      );
      //your home page is loaded
    } else {
      print("not logged in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: _onDeviceBack,
      child: Scaffold(
        resizeToAvoidBottomPadding: true,
        key: _ScaffoldStateKey,
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/imgs/logo_water.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(children: _buildForm(context))),
      ),
    );
  }

  List<Widget> _buildForm(BuildContext context) {
    List<Widget> list = new List();
    var mainView = showImage
        ? Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Image.asset(
                'assets/imgs/logo.png',
                height: 150,
              ),
            ),
          )
        : SizedBox(
            height: 0,
          );
    var footerView = Padding(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 20),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                "LET'S GET STARTED",
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xff170e50)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                SizedBox(width: 8.0),
                RaisedButton.icon(
                  onPressed: _openCountryPickerDialog,
                  elevation: 0.0,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5.0),
                  ),
                  color: Colors.transparent,
                  icon: SizedBox(
                    width: 25,
                    height: 20,
                    child: CountryPickerUtils.getDefaultFlagImage(
                        _selectedDialogCountry),
                  ),
                  label: Text(
                    "+${_selectedDialogCountry.phoneCode}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                Expanded(
                  child: TextField(
                    maxLength: 11,
                    controller: _controller,
                    style: TextStyle(fontSize: 13.0),
                    decoration: new InputDecoration(
                      counterStyle: TextStyle(
                        height: double.minPositive,
                      ),
                      counterText: "",
                      hintText: Translations.of(context).text('enter_mobile'),
                      hintStyle: TextStyle(fontSize: 13),
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      //fillColor: Colors.green
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: new Divider(),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      minWidth: double.infinity, minHeight: 45.0),
                  child: RaisedButton(
                      child: new Text(Translations.of(context).text('login')),
                      onPressed: () {
                        if (_controller.text.length < 10) {
                          _displaySnackBar("Enter valid mobile number");
                        } else {
                          setState(() {
                            _isLoading = true;
                          });
                          var request = new MultipartRequest(
                              "POST", Uri.parse(api_url + "user/login"));
                          request.fields['mobile'] = _controller.text;
                          request.fields['country_code'] =
                              _selectedDialogCountry.phoneCode;
                          commonMethod(request).then((onResponse) {
                            onResponse.stream
                                .transform(utf8.decoder)
                                .listen((value) {
                              setState(() {
                                _isLoading = false;
                              });
                              Map data = json.decode(value);
                              presentToast(data['message'], context, 0);
                              if (data['code'] == 200) {
                                Navigator.of(context).push(
                                    new MaterialPageRoute(
                                        builder: (context) => new OtpPage(
                                            _controller.text,
                                            _selectedDialogCountry.phoneCode)));
                              }
                            });
                          });
                        }
                      },
                      textColor: Colors.white,
                      color: Color(0xff170e50),
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0)))),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _canCheckBiometrics
                    ? Column(
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                child: new SvgPicture.asset(
                                  "assets/imgs/bio.svg",
                                  allowDrawingOutsideViewBox: true,
                                  height: 40,
                                  width: 30,
                                ),
                                onTap: () {
                                  bio == 'enable' ? _authenticate() : null;
                                },
                              )),
                        ],
                      )
                    : SizedBox(),
                Column(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          child: new SvgPicture.asset(
                            "assets/imgs/facebook.svg",
                            allowDrawingOutsideViewBox: true,
                            height: 40,
                            width: 30,
                          ),
                          onTap: () {
                            _loginWithFB();
                          },
                        )),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
    list.add(footerView);
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

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Widget _buildDialogItem1(Country country) => Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          SizedBox(width: 8.0),
          Text("+${country.phoneCode}"),
        ],
      );

  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.pink),
            child: CountryPickerDialog(
                titlePadding: EdgeInsets.all(8.0),
                searchCursorColor: Colors.pinkAccent,
                searchInputDecoration: InputDecoration(hintText: 'Search...'),
                isSearchable: true,
                title: Text('Select your phone code'),
                onValuePicked: (Country country) =>
                    setState(() => _selectedDialogCountry = country),
                itemBuilder: _buildDialogItem1)),
      );

  // Device back show dilog box
  Future<bool> _onDeviceBack() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Exit"),
              content: Text("Are you sure you want to exit the app?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("No"),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatButton(
                  child: Text("Yes"),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ));
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
    _ScaffoldStateKey.currentState.showSnackBar(snackBar);
  }

  Widget _customicon(BuildContext context, int index) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          "assets/imgs/logo.png",
          height: 500,
          width: 500,
        ),
      ),
      decoration: new BoxDecoration(
          color: Color(0xffffffff),
          borderRadius: new BorderRadius.circular(5.0)),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
