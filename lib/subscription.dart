import 'dart:convert';
import 'dart:math';

import 'package:eleve11/modal/subscription.dart';
import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/utils/controlled_animation.dart';
import 'package:eleve11/utils/multi_track_tween.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:eleve11/widgets/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnimatedWave extends StatelessWidget {
  final double height;
  final double speed;
  final double offset;

  AnimatedWave({this.height, this.speed, this.offset = 0.0});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: height,
        width: constraints.biggest.width,
        child: ControlledAnimation(
            playback: Playback.LOOP,
            duration: Duration(milliseconds: (5000 / speed).round()),
            tween: Tween(begin: 0.0, end: 2 * pi),
            builder: (context, value) {
              return CustomPaint(
                foregroundPainter: CurvePainter(value + offset),
              );
            }),
      );
    });
  }
}

class CurvePainter extends CustomPainter {
  final double value;

  CurvePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white.withAlpha(60);
    final path = Path();

    final y1 = sin(value);
    final y2 = sin(value + pi / 2);
    final y3 = sin(value + pi);

    final startPointY = size.height * (0.5 + 0.4 * y1);
    final controlPointY = size.height * (0.5 + 0.4 * y2);
    final endPointY = size.height * (0.5 + 0.4 * y3);

    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("color1").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xff6959d2), end: Colors.lightBlue.shade900)),
      Track("color2").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xff6959d2), end: Colors.blue.shade600))
    ]);

    return ControlledAnimation(
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, animation) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [animation["color1"], animation["color2"]])),
        );
      },
    );
  }
}

class SubscriptionPlans extends StatefulWidget {
  _SubscriptionPlansState createState() => _SubscriptionPlansState();
}

class _SubscriptionPlansState extends State<SubscriptionPlans>
    with SingleTickerProviderStateMixin {
  List<Subription> subcriptionList = new List();
  String acccessToken = "";
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List child = new List();

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  //Manually operated Carousel
  CarouselSlider manualCarouselDemo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIsLogin();
  }

  Future<Null> checkIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    acccessToken = prefs.getString("accessToken");
    getSubscription();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: _buildWidget(),
        ),
      ),
    );
  }

  getSubscription() {
    setState(() {
      _isLoading = true;
    });
    var request = new MultipartRequest(
        "GET", Uri.parse(api_url + "user/subscription/plans"));
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
            List<Subription> tempList = new List();
            if (data['data'].length > 0) {
              for (var i = 0; i < data['data'].length; i++) {
                List<String> tempDesc = new List();
                for (var j = 0;
                    j < data['data'][i]['description'].length;
                    j++) {
                  tempDesc.add(data['data'][i]['description'][j]);
                }
                tempList.add(new Subription(
                    data['data'][i]['id'].toString(),
                    data['data'][i]['title'],
                    tempDesc,
                    data['data'][i]['validity'],
                    data['data'][i]['price'],
                    data['data'][i]['discount'],
                    data['data'][i]['discount_type'],
                    data['data'][i]['created_at'],
                    data['data'][i]['updated_at']));
              }
              setState(() {
                subcriptionList = tempList;
              });
              setSubscriptionData();
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

  onBottom(Widget child) => Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      );

  List<Widget> _buildWidget() {
    List<Widget> list = new List();
    var backGround = Positioned.fill(child: AnimatedBackground());
    list.add(backGround);
    var animate1 = onBottom(AnimatedWave(
      height: 180,
      speed: 1.0,
    ));
    list.add(animate1);
    var animate2 = onBottom(AnimatedWave(
      height: 120,
      speed: 0.9,
      offset: pi,
    ));
    list.add(animate2);

    var amimate3 = onBottom(AnimatedWave(
      height: 220,
      speed: 1.2,
      offset: pi / 2,
    ));
    list.add(amimate3);
    var mainView = Padding(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        child: Column(children: [
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
              ),
              Text(
                "Subscription Plans",
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
          Expanded(
            child: (child.length > 0)
                ? manualCarouselDemo
                : SizedBox(
                    height: 10,
                  ),
          ),
        ]));
    if (subcriptionList.length > 0) {
      list.add(mainView);
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

  void setSubscriptionData() {
    setState(() {
      child = map<Widget>(
        subcriptionList,
        (index, item) {
          print(item.description);
          return Container(
            margin: EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: Column(children: <Widget>[
                Container(
                  color: Colors.orange,
                  width: 400,
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(item.title),
                      SizedBox(
                        height: 20,
                      ),
                      RichText(
                          text: TextSpan(
                              style: TextStyle(color: Colors.black),
                              text: "IQD ",
                              children: <TextSpan>[
                            TextSpan(
                                text: item.price,
                                style: TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: "/" + item.validity+" days",
                                    style: TextStyle(color: Colors.black))
                          ]))
                    ],
                  ),
                ),
                Container(
                  width: 400,
                  color: Colors.grey,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: item.description.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(item.description[index]),
                      );
                    },
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            minWidth: double.infinity, minHeight: 45.0),
                        child: RaisedButton(
                            child: new Text("Subscribe"),
                            onPressed: () {},
                            textColor: Colors.white,
                            color: Color(0xff170e50),
                            shape: new RoundedRectangleBorder(
                                borderRadius:
                                    new BorderRadius.circular(30.0)))),
                  ),
                ),
              ]),
            ),
          );
        },
      ).toList();

      manualCarouselDemo = CarouselSlider(
        items: child,
        autoPlay: false,
        enlargeCenterPage: true,
        viewportFraction: 0.8,
        aspectRatio: 1.0,
        initialPage: 1,
      );
    });
  }
}
