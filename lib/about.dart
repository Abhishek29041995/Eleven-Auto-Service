import 'package:flutter/material.dart';

class About extends StatefulWidget {
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
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
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("ELEVE 11",
                      softWrap: true,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text("Version 1.0.0",
                      softWrap: true,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.black,
                          fontSize: 12)),
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
                  Text("@ Pavel Enteprises",
                      softWrap: true,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.black,
                          fontSize: 11)),
                ],
              )
            ],
          )),
    );
  }
}
