import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eleve11/modal/Rides.dart';
import 'package:eleve11/modal/manufacturer_list.dart';
import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/utils/datepicker_formfield.dart';
import 'package:eleve11/utils/image_picker_handler.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:eleve11/widgets/dropdownfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http_parser/http_parser.dart';

class AddRide extends StatefulWidget {
  Rides myRides;

  AddRide(Rides myRides) {
    this.myRides = myRides;
  }

  _AddRideState createState() => _AddRideState(this.myRides);
}

class _AddRideState extends State<AddRide>
    with TickerProviderStateMixin, ImagePickerListener {
  DateTime _date = DateTime.now();
  Map<String, dynamic> formData;
  Map userData = null;
  String acccessToken = "";
  bool _isLoading = false;
  bool allOk = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<ManufacturerList> manufacturerList = new List();
  List<ManufacturerList> finalmanufacturerList = new List();
  List<ManufacturerList> modelList = new List();
  List<ManufacturerList> finalmodelList = new List();
  List<Step> my_steps = new List();
  bool ismanufactufrer = true;
  int current_step = 0;
  TextEditingController _manufacturer = TextEditingController();
  TextEditingController _cardmodel = TextEditingController();
  TextEditingController _yearController = TextEditingController();
  int manufacturerId;
  int carModelId;
  String carModeltype;
  final format = DateFormat("yyyy");
  File _image;
  AnimationController _controller;
  ImagePickerHandler imagePicker;

  final searchController1 = TextEditingController();
  final searchController2 = TextEditingController();
  int _selectedYear;
  int _fromYear;
  int _yearRange;
  int _initialYear;

  int get dobYear => _initialYear;

  ///Year lower bound (ex: 1920)
  int fromYear;

  ///Year upper bound (ex: 2020)
  int toYear;

//Ex: 1974
  int initialYear;
  Rides myRides;
  FixedExtentScrollController controller1 = FixedExtentScrollController();
  FixedExtentScrollController controller2 = FixedExtentScrollController();

  _AddRideState(Rides myRides) {
    this.myRides = myRides;
    formData = {
      'manufacturer': '',
      'model': '',
    };
  }

  @override
  void initState() {
    // TODO: implement initState
    int _toYear = toYear ?? _date.year;
    super.initState();
    _fromYear = fromYear ?? _date.year - 100;
    _initialYear = initialYear ?? _date.year;
    assert(_fromYear <= _initialYear && _initialYear <= _toYear,
        "Date Interval Error");
    _selectedYear = _initialYear - _fromYear;
    _yearRange = _toYear - _fromYear;
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    imagePicker = new ImagePickerHandler(this, _controller);
    imagePicker.init();
    checkIsLogin();
    // Start listening to changes.
    searchController1.addListener(() {
      // Start listening to changes.
      List<ManufacturerList> tempList = new List();
      if (searchController1.text.length > 0) {
        tempList = finalmanufacturerList
            .where((i) => i.name
                .toLowerCase()
                .contains(searchController1.text.toLowerCase()))
            .toList();
      } else {
        tempList = finalmanufacturerList;
      }
      manufacturerList = tempList;
      controller1.animateToItem(0,
          duration: Duration(microseconds: 20), curve: ElasticInCurve());
      manufacturerId = int.parse(manufacturerList[0].id);
      _manufacturer.text = manufacturerList[0].name;
      formData['manufacturer'] = manufacturerList[0].name;
    });

    searchController2.addListener(() {
      // Start listening to changes.
      List<ManufacturerList> tempList = new List();
      if (searchController2.text.length > 0) {
        tempList = finalmodelList
            .where((i) => i.name
                .toLowerCase()
                .contains(searchController2.text.toLowerCase()))
            .toList();
      } else {
        tempList = finalmodelList;
      }
      modelList = tempList;
      controller2.animateToItem(0,
          duration: Duration(microseconds: 20), curve: ElasticInCurve());
      _cardmodel.text = modelList[0].name;
      carModelId = int.parse(modelList[0].id);
      carModeltype = modelList[0].type;
      formData['model'] = modelList[0].name;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  userImage(File image) {
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
        child: WillPopScope(
      onWillPop: () async {
        if (ismanufactufrer) {
          return true;
        } else {
          setState(() {
            ismanufactufrer = true;
            return false;
          });
        }
      },
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          key: _scaffoldKey,
          body: Stack(
            children: _buildWidget(context),
          )),
    ));
  }

  Future<Null> checkIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    JsonCodec codec = new JsonCodec();
    userData = codec.decode(prefs.getString("userData"));
    acccessToken = prefs.getString("accessToken");
    getCarManufactureList();
  }

  List<Widget> _buildWidget(BuildContext context) {
    var list = new List<Widget>();
    var appBar = Padding(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 18,
            ),
            color: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              myRides != null
                  ? Translations.of(context).text('edit_ride')
                  : Translations.of(context).text('add_ride'),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xff170e50)),
            ),
          )
        ],
      ),
    );
    list.add(appBar);
    var manufacturer = Padding(
      padding: EdgeInsets.only(top: 60, left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 4),
            onPressed: () async {
              await showModalBottomSheet<int>(
                  context: context,
                  builder: (BuildContext builder) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Card(
                          elevation: 2,
                          margin: EdgeInsets.all(16.0),
                          child: CupertinoTextField(
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 14.0),
                            controller: searchController1,
                            placeholder: 'Enter manufacturer here',
                            suffix: IconButton(
                              icon: Icon(
                                Icons.search,
                                color: Color(0xFFD52D2D),
                              ),
                              onPressed: () {
//                                controller.animateToItem(index,
//                                    duration: Duration(microseconds: 20),
//                                    curve: ElasticInCurve());
                              },
//                          onPressed: _showWarning(),
                            ),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                              squeeze: 1.5,
                              diameterRatio: 1,
                              useMagnifier: true,
                              looping: true,
                              scrollController: controller1,
                              itemExtent: 33.0,
                              backgroundColor: Colors.white,
                              onSelectedItemChanged: (int index) =>
                                  setState(() {
                                    setState(() {
                                      manufacturerId =
                                          int.parse(manufacturerList[index].id);
                                      _manufacturer.text =
                                          manufacturerList[index].name;
                                      formData['manufacturer'] =
                                          manufacturerList[index].name;
                                    });
                                  }),
                              children: new List<Widget>.generate(
                                  manufacturerList.length, (int index) {
                                return new Center(
                                  child: new Text(
                                    manufacturerList[index].name,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                );
                              })),
                        )
                      ],
                    );
                  }).whenComplete(() {
                getCarModelList(manufacturerId.toString());
              });
            },
            child: TextFormField(
              controller: _manufacturer,
              enabled: false,
              decoration: new InputDecoration(
                contentPadding: EdgeInsets.all(15.0),
                counterStyle: TextStyle(
                  height: double.minPositive,
                ),
                counterText: "",
                labelText: Translations.of(context).text('manufacturer'),
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                  borderSide: new BorderSide(),
                ),
                //fillColor: Colors.green
              ),
            ),
          ),
          FlatButton(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 4),
              onPressed: () async {
                if (manufacturerId != null) {
                  await showModalBottomSheet<int>(
                      context: context,
                      builder: (BuildContext builder) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Card(
                              elevation: 2,
                              margin: EdgeInsets.all(16.0),
                              child: CupertinoTextField(
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 14.0),
                                controller: searchController2,
                                placeholder: 'Enter model name',
                                suffix: IconButton(
                                  icon: Icon(
                                    Icons.search,
                                    color: Color(0xFFD52D2D),
                                  ),
                                  onPressed: () {},
//                          onPressed: _showWarning(),
                                ),
                              ),
                            ),
                            Expanded(
                              child: CupertinoPicker(
                                  squeeze: 1.5,
                                  diameterRatio: 1,
                                  useMagnifier: true,
                                  scrollController: controller2,
                                  looping: true,
                                  itemExtent: 33.0,
                                  backgroundColor: Colors.white,
                                  onSelectedItemChanged: (int index) =>
                                      setState(() {
                                        _cardmodel.text = modelList[index].name;
                                        carModelId =
                                            int.parse(modelList[index].id);
                                        carModeltype = modelList[index].type;
                                        formData['model'] =
                                            modelList[index].name;
                                      }),
                                  children: new List<Widget>.generate(
                                      modelList.length, (int index) {
                                    return new Center(
                                      child: new Text(
                                        modelList[index].name,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    );
                                  })),
                            )
                          ],
                        );
                      });
                } else {
                  _displaySnackBar(
                      Translations.of(context).text('choose_manufacturer'));
                }
              },
              child: TextFormField(
                controller: _cardmodel,
                enabled: false,
                decoration: new InputDecoration(
                  contentPadding: EdgeInsets.all(15.0),
                  counterStyle: TextStyle(
                    height: double.minPositive,
                  ),
                  counterText: "",
                  labelText: Translations.of(context).text('car_model'),
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(5.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
              )),
          FlatButton(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 4),
              onPressed: () async {
                if (carModelId != null) {
                  await showModalBottomSheet<int>(
                      context: context,
                      builder: (BuildContext builder) {
                        return CupertinoPicker(
                            squeeze: 1.5,
                            diameterRatio: 1,
                            useMagnifier: true,
                            looping: true,
                            itemExtent: 33.0,
                            backgroundColor: Colors.white,
                            scrollController: FixedExtentScrollController(
                              initialItem: _selectedYear - 1,
                            ),
                            onSelectedItemChanged: (int index) {
                              setState(() {
                                _selectedYear = index;
                                _yearController.text = '${_fromYear + index}';
                              });
                            },
                            children: new List<Widget>.generate(_yearRange,
                                (int index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: Text(
                                  '${_fromYear + index}',
                                  style: TextStyle(
                                    color: _selectedYear == index
                                        ? Colors.white
                                        : Color(0xff170e50).withOpacity(0.6),
                                    fontSize: 18.0,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              );
                            }));
                      });
                } else {
                  _displaySnackBar(
                      Translations.of(context).text('choose_car_model'));
                }
              },
              child: TextFormField(
                controller: _yearController,
                enabled: false,
                decoration: new InputDecoration(
                  contentPadding: EdgeInsets.all(15.0),
                  counterStyle: TextStyle(
                    height: double.minPositive,
                  ),
                  counterText: "",
                  labelText: Translations.of(context).text('year'),
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(5.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
              )),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 20, 8, 20),
            child: Text(
              Translations.of(context).text('add_photo'),
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: new ClipRRect(
                borderRadius: new BorderRadius.circular(8.0),
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => imagePicker.showDialog(context),
                      child: Container(
                        height: 200.0,
                        decoration: new BoxDecoration(
                          color: const Color(0xff7c94b6),
                          image: new DecorationImage(
                            image: new ExactAssetImage(_image != null
                                ? _image.path
                                : 'assets/imgs/placeholder.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
    list.add(manufacturer);
    var submit = Padding(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 20),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
            constraints: const BoxConstraints(
                minWidth: double.infinity, minHeight: 45.0),
            child: RaisedButton(
                child: new Text(Translations.of(context).text('continue')),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          //this right here
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  myRides != null
                                      ? Translations.of(context)
                                          .text('want_to_edit_car')
                                      : Translations.of(context)
                                          .text('want_to_add_car'),
                                  style: TextStyle(
                                      fontSize: 13, fontFamily: 'Montserrat'),
                                ),
                                _image != null
                                    ? Container(
                                        child: new ClipRRect(
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                            child: Stack(children: <Widget>[
                                              Image.file(_image,
                                                  height: 90,
                                                  width: 120,
                                                  fit: BoxFit.cover)
                                            ])),
                                      )
                                    : SizedBox(
                                        height: 0,
                                      ),
                                Text(
                                  formData['manufacturer'] +
                                      "( " +
                                      formData['model'] +
                                      " )",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  Translations.of(context).text('year') +
                                      " - (" +
                                      _yearController.text +
                                      ")",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            bottom: 10,
                                            top: 20),
                                        child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                minWidth: double.infinity,
                                                minHeight: 35.0),
                                            child: RaisedButton(
                                                child: new Text("Cancel"),
                                                onPressed: () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop();
                                                },
                                                textColor: Colors.white,
                                                color: Colors.red,
                                                shape:
                                                    new RoundedRectangleBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                    .circular(
                                                                30.0)))),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            bottom: 10,
                                            top: 20),
                                        child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                minWidth: double.infinity,
                                                minHeight: 35.0),
                                            child: RaisedButton(
                                                child: new Text(myRides != null
                                                    ? Translations.of(context)
                                                        .text('edit')
                                                    : Translations.of(context)
                                                        .text('add')),
                                                onPressed: () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop();
                                                  if (myRides != null) {
                                                    updateRides(
                                                        carModelId.toString(),
                                                        carModeltype);
                                                  } else {
                                                    addMyRide(
                                                        carModelId.toString(),
                                                        carModeltype);
                                                  }
                                                },
                                                textColor: Colors.white,
                                                color: Color(0xff170e50),
                                                shape:
                                                    new RoundedRectangleBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                    .circular(
                                                                30.0)))),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      });
                },
                textColor: Colors.white,
                color: Color(0xff170e50),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)))),
      ),
    );
    if (_yearController.text != '') {
      list.add(submit);
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

  addMyRide(String id, String type) async {
    setState(() {
      _isLoading = true;
    });
    var request =
        new MultipartRequest("POST", Uri.parse(api_url + "user/addToMyRide"));
    request.fields['car_model_id'] = id;
    request.fields['type'] = type;
    request.fields['year'] = _yearController.text;
    if (_image != null) {
      request.files.add(await MultipartFile.fromPath('image', _image.path,
          contentType: new MediaType('image', 'jpeg')));
    }
    request.headers['Authorization'] = "Bearer $acccessToken";
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) {
        setState(() {
          _isLoading = false;
        });
        Map data = json.decode(value);
        presentToast(data['message'], context, 0);
        if (data['code'] == 200) {
          Navigator.of(context).pop();
        }
      });
    });
  }

  updateRides(String id, String type) async {
    setState(() {
      _isLoading = true;
    });
    var request =
        new MultipartRequest("POST", Uri.parse(api_url + "user/updateMyRide"));
    request.fields['id'] = myRides.id;
    request.fields['car_model_id'] = id;
    request.fields['type'] = type;
    request.fields['year'] = _yearController.text;
    if (_image != null) {
      request.files.add(await MultipartFile.fromPath('image', _image.path,
          contentType: new MediaType('image', 'jpeg')));
    }
    request.headers['Authorization'] = "Bearer $acccessToken";
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) {
        setState(() {
          _isLoading = false;
        });
        Map data = json.decode(value);
        presentToast(data['message'], context, 0);
        if (data['code'] == 200) {
          Navigator.of(context).pop();
        }
      });
    });
  }

  void getCarManufactureList() {
    setState(() {
      _isLoading = true;
    });
    var request = new MultipartRequest(
        "GET", Uri.parse(api_url + "user/getCarManufactureList"));
    request.headers['Authorization'] = "Bearer $acccessToken";
    commonMethod(request).then((onResponse) {
      onResponse.stream.transform(utf8.decoder).listen((value) {
        setState(() {
          _isLoading = false;
        });
        Map data = json.decode(value);
        print(data);
        if (data['code'] == 200) {
          if (data['data'].length > 0) {
            List<ManufacturerList> tempList = new List();
            for (var i = 0; i < data['data'].length; i++) {
              tempList.add(new ManufacturerList(
                  data['data'][i]['id'].toString(),
                  data['data'][i]['name'],
                  ""));
            }
            setState(() {
              manufacturerList = tempList;
              finalmanufacturerList = tempList;
            });
          } else {
            presentToast(Translations.of(context).text('no_record'), context, 0);
          }
        } else {
          presentToast(data['message'], context, 0);
        }
      });
    });
  }

  void getCarModelList(String id) {
    setState(() {
      _isLoading = true;
    });
    get(api_url + "user/getCarModelList/" + id, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      'Authorization': "Bearer $acccessToken"
    }).then((response) {
      Map data = json.decode(response.body);
      presentToast(data['message'], context, 0);
      if (data['code'] == 200) {
        if (data['data'].length > 0) {
          List<ManufacturerList> tempList = new List();
          for (var i = 0; i < data['data'].length; i++) {
            tempList.add(new ManufacturerList(data['data'][i]['id'].toString(),
                data['data'][i]['name'], data['data'][i]['type']));
          }
          setState(() {
            modelList = tempList;
            finalmodelList = tempList;
          });
        } else {
          presentToast(Translations.of(context).text("no_record"), context, 0);
        }
      } else {
        presentToast(data['message'], context, 0);
      }
      setState(() {
        _isLoading = false;
      });
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

//  void createSteps(Step step) {
//    my_steps.add(step);
//  }
}
