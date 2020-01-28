import 'package:eleve11/modal/orders.dart';
import 'package:eleve11/track_history.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:eleve11/widgets/dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class CheckOrderHistoryDetails extends StatefulWidget {
  Orders orderList;

  CheckOrderHistoryDetails(Orders orderList) {
    this.orderList = orderList;
  }

  @override
  _CheckOrderHistoryDetails createState() =>
      _CheckOrderHistoryDetails(this.orderList);
}

class _CheckOrderHistoryDetails extends State<CheckOrderHistoryDetails> {
  Orders orderList;

  _CheckOrderHistoryDetails(Orders orderList) {
    this.orderList = orderList;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
            onPressed: () =>
            {
              Navigator.of(context).pop(),
            }),
        automaticallyImplyLeading: false,
        title: new Text("Check Order History Details"),

        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        textTheme: TextTheme(
          title: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
      ),
      backgroundColor: Color(0xffF2F2F2),
      body: Center(
//        child: Padding(padding: EdgeInsets.all(5.0),
          child: ListView(
            children: <Widget>[
              CardData1(),
              Card(
                  child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: InkWell(
                          onTap: () {
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(builder: (context) =>  viewDetailsPage()),
//                    );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: new Text("Service Details",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16)),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 0, 5),
                                child: Text(
                                  orderList.service['name'],
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(15, 0, 0, 10),
                                child: Html(
                                  data: orderList.service['description'],
                                ),
                              )
                            ],
                          )))),
              Card(
                  child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: InkWell(
                          onTap: () {
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(builder: (context) =>  viewDetailsPage()),
//                    );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: new Text("Address Details",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                    orderList.address['house'] +
                                        ",\nnear " +
                                        orderList.address['landmark'],
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: RaisedButton.icon(
                                  icon: Icon(Icons.location_on),
                                  color: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                                  elevation: 0,
                                  label: Flexible(
                                    child: Text(orderList.address['address'],
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  onPressed: () {},
                                ),
                              )
                            ],
                          )))),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: new RaisedButton(
                  child: new Text(Translations.of(context).text('cancel')),
                  textColor: Colors.white,
                  color: Colors.red,
                  onPressed: () {},
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20.0)),
                ),
              )
            ],
          )
//        ),
      ),
    );
  }

  CardData1() {
    return
//      GestureDetector(
//        onTap: () {
//          Navigator.push(
//            context,
//            MaterialPageRoute(builder: (context) =>  viewDetailsPage()),
//          );
//    },
//    child:
      Card(
          child: Container(
              child: InkWell(
                  onTap: () {
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(builder: (context) =>  viewDetailsPage()),
//                    );
                  },
                  child: Column(
                    children: <Widget>[
                      orderList.worker != null ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: new ClipRRect(
                                  borderRadius:
                                  new BorderRadius.circular(100),
                                  child: Stack(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
//                                Navigator.push(
//                                    context,
//                                    new MaterialPageRoute(
//                                        builder: (context) => new SelectService()));
                                        },
                                        child: FadeInImage.assetNetwork(
                                          placeholder: 'assets/imgs/user.png',
                                          image: orderList.worker['avatar'],
                                          fit: BoxFit.cover,
                                          height: 70,
                                          width: 70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text(orderList.worker['name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                          fontSize: 20)),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  new Text(orderList.worker['mobile'],
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                          fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image(
                                image: AssetImage('assets/invoice1.png'),
                                height: 25,
                                width: 25,
                                fit: BoxFit.fitHeight),
                          )
                        ],
                      ) : SizedBox(
                        width: 1,
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Wrap(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Image(
                                    image: AssetImage('assets/invoice1.png'),
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width /
                                        10,
                                    height:
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .height /
                                        20,
                                    fit: BoxFit.fitHeight),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text("Reference Number:",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 16)),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  new Text(orderList.booking_ref,
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                          fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        TrackHistory(
                                            orderList.booking_progress)),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Track",
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.deepOrangeAccent),
                              ),
                            ),
                          )
                        ],
                      ),
                      Divider(),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red),
                                ),
                                SizedBox(width: 5.0),
                                Text("Booking Date:" + orderList.created_at,
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Colors.black,
                                        fontSize: 14)),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Dash(
                                  direction: Axis.vertical,
                                  length: 10,
                                  dashLength: 2,
                                  dashColor: Colors.grey),
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green),
                                ),
                                SizedBox(width: 5.0),
                                Text("Booking Date:" + orderList.created_at,
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Colors.black,
                                        fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Text("Ordered On:",
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                                SizedBox(
                                  height: 5.0,
                                ),
                                new Text(orderList.updated_at,
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        color: Colors.black,
                                        fontSize: 14)),
                              ],
                            ),
                          )
                        ],
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text("Pricing Details",
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Original Price",
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 12)),
                                    Text(orderList.actual_price,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12))
                                  ],
                                ),
                              ),
                              orderList.subscription_discount != ''?Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Subscription",
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 12)),
                                    Text(double.parse(orderList.subscription_discount).toStringAsFixed(2),
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                            fontSize: 12))
                                  ],
                                ),
                              ):SizedBox(width: 1,),
                              orderList.discount_type != '0'?Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Promo Applied",
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 12)),
                                    Text((double.parse(getDiscountPrice(orderList))-double.parse(orderList.subscription_discount)).toStringAsFixed(2),
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                            fontSize: 12))
                                  ],
                                ),
                              ):SizedBox(width: 1,),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(orderList.subscription_discount != '' &&
                                        orderList.discount_type != '0'
                                        ? "Discount (Subscription + Promo)":orderList.subscription_discount == '' &&
                                        orderList.discount_type != '0'?"Discount (Promo)":orderList.subscription_discount != '' &&
                                        orderList.discount_type == '0'?"Discount (Subscription)":"Discount",
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 12)),
                                    Text("- " + getDiscountPrice(orderList),
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                            fontSize: 12))
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                        orderList.payment_type == 'COD'
                                            ? "Amount to pay"
                                            : "Amount Paid",
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 12)),
                                    Text(orderList.discounted_price,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ))));
  }

  String getDiscountPrice(Orders orderList) {
    if (orderList.discount_type == 'PERCENTAGE') {
      return ((double.parse(orderList.actual_price) *
          (double.parse(orderList.discount_value) / 100)) +
          double.parse(orderList.subscription_discount))
          .toStringAsFixed(2);
    } else {
      return (double.parse(orderList.discount_value) +
          double.parse(orderList.subscription_discount)).toStringAsFixed(2);
    }
  }

  String getFinalPrice(Orders orderList) {
    if (orderList.discount_type == 'PERCENTAGE') {
      return (double.parse(orderList.actual_price) -
          double.parse(orderList.actual_price) *
              (double.parse(orderList.discount_value) / 100))
          .toStringAsFixed(2);
    } else {
      return (double.parse(orderList.actual_price) -
          double.parse(orderList.discount_value))
          .toStringAsFixed(2);
    }
  }
}

class MySeparator extends StatelessWidget {
  final double width;
  final Color color;

  const MySeparator({this.width = 1, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
//        final boxWidth = constraints.constrainWidth();
        final boxWidth = constraints.constrainWidth();
        final dashWidth = width;
        final dashHeight = 2.0;
        final dashCount = (boxWidth / dashWidth).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.vertical,
        );
      },
    );
  }
}
