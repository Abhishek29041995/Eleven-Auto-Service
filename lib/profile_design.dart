import 'dart:convert';

import 'package:eleve11/profile.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePageDesign extends StatefulWidget {
  _ProfilePageDesign createState() => _ProfilePageDesign();
}

class _ProfilePageDesign extends State<ProfilePageDesign> {
  TextStyle _style() {
    return TextStyle(fontWeight: FontWeight.bold);
  }

  Map userData = null;
  String acccessToken = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIsLogin();
  }

  Future<Null> checkIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    JsonCodec codec = new JsonCodec();
    setState(() {
      userData = codec.decode(prefs.getString("userData"));
      acccessToken = prefs.getString("accessToken");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(userData),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: userData!=null?Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Name"),
            SizedBox(
              height: 4,
            ),
            Text(
              userData['name'],
              style: _style(),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              "Email",
              style: _style(),
            ),
            SizedBox(
              height: 4,
            ),
            Text(userData['email']),
            SizedBox(
              height: 16,
            ),
            Text(
              "Date of birth",
              style: _style(),
            ),
            SizedBox(
              height: 4,
            ),
            Text(userData['dob']),
            SizedBox(
              height: 16,
            ),
            Text(
              "Mobile number",
              style: _style(),
            ),
            SizedBox(
              height: 4,
            ),
            Text(userData['mobile']),
            SizedBox(
              height: 16,
            )
          ],
        ):SizedBox(
          height: 10,
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  Map userData;
  CustomAppBar(Map userData){
    this.userData = userData;}

  @override
  Size get preferredSize => Size(double.infinity, 280);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MyClipper(),
      child: Container(
        padding: EdgeInsets.only(top: 4),
        decoration: BoxDecoration(color: Color(0xffcccccc), boxShadow: [
          BoxShadow(
              color: Color(0xff170e50), blurRadius: 20, offset: Offset(0, 0))
        ]),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Text(
                  "Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    userData!=null?Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover, image: NetworkImage(userData['avatar']))),
                    ):SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      userData['name'],
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )
                  ],
                ),
//                Padding(
//                  padding: const EdgeInsets.only(top: 16.0),
//                  child: Row(
//                    children: <Widget>[
//                      SvgPicture.asset(
//                        "assets/imgs/facebook.svg",
//                        allowDrawingOutsideViewBox: true,
//                        height: 40,
//                        width: 30,
//                      ),
//                      Padding(
//                        padding: const EdgeInsets.all(8.0),
//                        child: Text(
//                          "milan.short854@gmail.com",
//                          style: TextStyle(fontSize: 12, color: Colors.white),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  print("//TODO: button clicked");
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new ProfilePage()));
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 24, 16, 0),
                  child: Transform.rotate(
                    angle: (math.pi * 0.05),
                    child: Container(
                      width: 110,
                      height: 32,
                      child: Center(
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 20)
                          ]),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();

    p.lineTo(0, size.height - 70);
    p.lineTo(size.width, size.height);

    p.lineTo(size.width, 0);

    p.close();

    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
