import 'dart:convert';

import 'package:eleve11/modal/faq.dart';
import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:eleve11/widgets/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';

class FAQs extends StatefulWidget {
  _FAQsState createState() => _FAQsState();
}

class _FAQsState extends State<FAQs> {
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<FAQ> faqList = new List();

  @override
  void initState() {
    super.initState();
    getFAQs();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
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
        title: new Text(Translations.of(context).text('faq')),
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
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[bodyCard()],
    )
//        ),
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

  bodyCard() {
    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: faqList.length,
        itemBuilder: (BuildContext context, int index) {
//          final item = finalDepData[index];
//          return tableRowDept(item);
          return CardData(faqList[index], index + 1);
        },
      ),
    );
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

  void getFAQs() {
    setState(() {
      _isLoading = true;
    });
    var request = new MultipartRequest("GET", Uri.parse(api_url + "faqs"));
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) {
        setState(() {
          _isLoading = false;
        });
        try {
          Map data = json.decode(value);
          print(data);
          if (data['code'] == 200) {
            List<FAQ> tempList = new List();
            if (data['data'].length > 0) {
              for (var i = 0; i < data['data'].length; i++) {
                tempList.add(new FAQ(
                    data['data'][i]['id'].toString(),
                    data['data'][i]['question'],
                    data['data'][i]['answer'],
                    data['data'][i]['created_at'],
                    data['data'][i]['updated_at']));
              }
              setState(() {
                faqList = tempList;
              });
            }
          }
        } catch (onError) {
          _displaySnackBar(Translations.of(context).text('server_error'));
        }
      }).onError((err) =>
          {_displaySnackBar(Translations.of(context).text('server_error'))});
    });
  }

  CardData(FAQ faqList, int i) {
    return ExpandableNotifier(
      // <-- Provides ExpandableController to its children
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expandable(
              // <-- Driven by ExpandableController from ExpandableNotifier
              collapsed: ExpandableButton(
                // <-- Expands when tapped on the cover photo
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, top: 10, bottom: 10),
                  child: Text(
                    "Q." + i.toString() + " " + faqList.question,
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              expanded: ExpandableButton(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 10, bottom: 10),
                          child: Text(
                            "Q." + i.toString() + " " + faqList.question,
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold),
                          )),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.lightGreen,
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(2),bottomRight: Radius.circular(2))),
                        child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 10),
                            child: Text(
                              "Ans. " + faqList.answer,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold),
                            )),
                      ),
//                      _childList(serviceList[index].otherservices),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
