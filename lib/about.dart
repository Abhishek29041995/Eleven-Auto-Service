import 'dart:convert';

import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/rich_text_parser.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:html/dom.dart' as dom;
import 'package:shared_preferences/shared_preferences.dart';

class About extends StatefulWidget {
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  bool _isLoading = false;
  String acccessToken = "";
  String description = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    checkIsLogin();
  }

  Future<Null> checkIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    acccessToken = prefs.getString("accessToken");
    getAboutDetails();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/imgs/logo_water.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: _buildWidget(),
          )),
    );
  }

  void getAboutDetails() {
    setState(() {
      _isLoading = true;
    });
    var request = new MultipartRequest("GET", Uri.parse(api_url + "about"));
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
              description = data['data']['about'];
            });
          }
        } catch (onError) {
          _displaySnackBar(Translations.of(context).text('server_error'));
        }
      }).onError((err) =>
          {_displaySnackBar(Translations.of(context).text('server_error'))});
    });
  }

  List<Widget> _buildWidget() {
    List<Widget> list = new List();
    var header = IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: Colors.grey,
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    list.add(header);
    var mainView = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text("ELEVEN AUTO SERVICES",
            softWrap: true,
            style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        Text("Version 1.0.2",
            softWrap: true,
            style: TextStyle(
                fontFamily: 'Montserrat', color: Colors.black, fontSize: 12)),
        SizedBox(
          height: 20,
        ),
        Center(
            child: Image.asset(
          'assets/imgs/logo.png',
          height: 100,
          width: 100,
        )),
        SizedBox(
          height: 20,
        ),
        Html(
            data: description,
         customTextStyle: (dom.Node node,TextStyle basestyle){
              return basestyle.merge( TextStyle(
                  fontFamily: 'Montserrat', color: Colors.black, fontSize: 11));
         },customTextAlign:(dom.Element elem){
              return TextAlign.center;
        } ,),
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
}
