import 'dart:convert';
import 'dart:io';

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
  _AddRideState createState() => _AddRideState();
}

class _AddRideState extends State<AddRide>
    with TickerProviderStateMixin, ImagePickerListener {
  Map<String, dynamic> formData;
  Map userData = null;
  String acccessToken = "";
  bool _isLoading = false;
  bool allOk = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey _pickerKey = GlobalKey();
  List<ManufacturerList> manufacturerList = new List();
  List<ManufacturerList> modelList = new List();
  List<Step> my_steps = new List();
  bool ismanufactufrer = true;
  int current_step = 0;
  TextEditingController _manufacturer = TextEditingController();
  TextEditingController _cardmodel = TextEditingController();
  TextEditingController _yearController = TextEditingController();
  final format = DateFormat("yyyy");
  File _image;
  AnimationController _controller;
  ImagePickerHandler imagePicker;

  _AddRideState() {
    formData = {
      'manufacturer': '',
      'model': '',
    };
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
      my_steps[my_steps.length - 1] = Step(
          // Title of the Step
          title: Text("Add Photo"),
          // Content, it can be any widget here. Using basic Text for this example
          content: Container(
            child: new ClipRRect(
                borderRadius: new BorderRadius.circular(8.0),
                child: Stack(children: <Widget>[
                  Image.file(_image, height: 90, width: 150, fit: BoxFit.cover)
                ])),
          ),
          isActive: true);
    });
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
    checkIsLogin();
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
              "Add Ride",
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
    if (my_steps.length > 0) {
      var manufacturerNames = Padding(
        padding: EdgeInsets.only(top: 56),
        child: Stepper(
          key: Key("mysuperkey-" + my_steps.length.toString()),
          // Using a variable here for handling the currentStep
          currentStep: this.current_step,
          // List the steps you would like to have
          steps: my_steps,
          // Define the type of Stepper style
          // StepperType.horizontal :  Horizontal Style
          // StepperType.vertical   :  Vertical Style
          type: StepperType.vertical,
          // Know the step that is tapped
          onStepTapped: (step) {
            // On hitting step itself, change the state and jump to that step
            setState(() {
              // update the variable handling the current step value
              // jump to the tapped step
              current_step = step;
            });
            // Log function call
            print("onStepTapped : " + step.toString());
          },
          controlsBuilder: (BuildContext context,
              {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
            return Row(
              children: <Widget>[
                Container(
                  child: null,
                ),
                Container(
                  child: null,
                ),
              ],
            );
          },
        ),
      );
      list.add(manufacturerNames);
    }
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
                                  "Are you sure you want to add?",
                                  style: TextStyle(
                                      fontSize: 13, fontFamily: 'Montserrat'),
                                ),
                                Container(
                                  child: new ClipRRect(
                                      borderRadius:
                                          new BorderRadius.circular(8.0),
                                      child: Stack(children: <Widget>[
                                        Image.file(_image,
                                            height: 90,
                                            width: 120,
                                            fit: BoxFit.cover)
                                      ])),
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
                                                child: new Text("Add"),
                                                onPressed: () {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop();
                                                  addMyRide(
                                                      modelList[modelList
                                                              .indexWhere((i) =>
                                                                  i.name ==
                                                                  formData[
                                                                      'model'])]
                                                          .id,
                                                      modelList[modelList
                                                              .indexWhere((i) =>
                                                                  i.name ==
                                                                  formData[
                                                                      'model'])]
                                                          .type);
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
    if (current_step == 3 && _image != null) {
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
          color: Color(0xff170e50),
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
                  data['data'][i]['image'],
                  "",
                  data['data'][i]['created_at'],
                  data['data'][i]['updated_at']));
            }
            setState(() {
              manufacturerList = tempList;
              createSteps(Step(
                  // Title of the Step
                  title: Text("Manufacturer"),
                  // Content, it can be any widget here. Using basic Text for this example
                  content: DropDownField(
                    controller: _manufacturer,
                    value: formData['manufacturer'],
                    icon: Icon(Icons.location_city),
                    required: true,
                    hintText: 'Choose a manufacturer',
                    labelText: 'Manufacturer *',
                    items: manufacturerList,
                    strict: false,
                    setter: (dynamic newValue) {
                      formData['manufacturer'] = newValue.name;
                    },
                    onValueChanged: (val) {
                      formData['manufacturer'] = val;
                      getCarModelList(manufacturerList[
                              manufacturerList.indexWhere((i) => i.name == val)]
                          .id);
                    },
                  ),
                  isActive: true));
            });
          } else {
            presentToast("No record found", context, 0);
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
    var request = new MultipartRequest(
        "GET", Uri.parse(api_url + "user/getCarModelList/" + id));
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
          if (data['data'].length > 0) {
            List<ManufacturerList> tempList = new List();
            for (var i = 0; i < data['data'].length; i++) {
              tempList.add(new ManufacturerList(
                  data['data'][i]['id'].toString(),
                  data['data'][i]['name'],
                  data['data'][i]['image'],
                  data['data'][i]['type'],
                  data['data'][i]['created_at'],
                  data['data'][i]['updated_at']));
            }
            setState(() {
              modelList = tempList;
              ismanufactufrer = false;
              if (my_steps.length == 1) {
                createSteps(Step(
                    // Title of the Step
                    title: Text("Car Model"),
                    // Content, it can be any widget here. Using basic Text for this example
                    content: DropDownField(
                      controller: _cardmodel,
                      value: formData['model'],
                      icon: Icon(Icons.location_city),
                      required: true,
                      hintText: 'Choose a car model',
                      labelText: 'Car model *',
                      items: modelList,
                      strict: false,
                      setter: (dynamic newValue) {
                        formData['model'] = newValue.name;
                      },
                      onValueChanged: (val) {
                        print(val);
                        formData['model'] = val;
                        setState(() {
                          if (my_steps.length == 2) {
                            createSteps(Step(
                                // Title of the Step
                                title: Text("Year"),
                                // Content, it can be any widget here. Using basic Text for this example
                                content: TextFormField(
                                  controller: _yearController,
                                  style: TextStyle(fontSize: 13.0),
                                  maxLength: 4,
                                  decoration: InputDecoration(
                                      hintStyle: TextStyle(fontSize: 13.0),
                                      hintText: 'Enter Year',
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.calendar_today)),
                                  onChanged: (text) {
                                    var date = new DateTime.now();
                                    int currentYear = date.year;
                                    if (text.trim().length > 3 &&
                                        (int.parse(text.trim()) < 1900 ||
                                            int.parse(text.trim()) >=
                                                currentYear)) {
                                      _displaySnackBar(
                                          "Year must be between 1900 and $currentYear");
                                    } else if (text.trim().length == 4) {
                                      setState(() {
                                        if (my_steps.length == 3) {
                                          createSteps(Step(
                                              // Title of the Step
                                              title: Text("Add Photo"),
                                              // Content, it can be any widget here. Using basic Text for this example
                                              content: Container(
                                                child: new ClipRRect(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          8.0),
                                                  child: Stack(
                                                    children: <Widget>[
                                                      GestureDetector(
                                                        onTap: () => imagePicker
                                                            .showDialog(
                                                                context),
                                                        child: Container(
                                                          height: 90.0,
                                                          width: 150.0,
                                                          decoration:
                                                              new BoxDecoration(
                                                            color: const Color(
                                                                0xff7c94b6),
                                                            image:
                                                                new DecorationImage(
                                                              image: new ExactAssetImage(
                                                                  'assets/imgs/placeholder.png'),
                                                              fit: BoxFit.cover,
                                                            ),
                                                            border: Border.all(
                                                                color: Color(
                                                                    0xff170e50),
                                                                width: 1.0),
                                                            borderRadius:
                                                                new BorderRadius
                                                                        .all(
                                                                    const Radius
                                                                            .circular(
                                                                        10.0)),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              isActive: true));
                                        } else {
                                          my_steps[3] = Step(
                                              // Title of the Step
                                              title: Text("Add Photo"),
                                              // Content, it can be any widget here. Using basic Text for this example
                                              content: Container(
                                                child: new ClipRRect(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          8.0),
                                                  child: Stack(
                                                    children: <Widget>[
                                                      GestureDetector(
                                                        onTap: () => imagePicker
                                                            .showDialog(
                                                                context),
                                                        child: Container(
                                                          height: 90.0,
                                                          width: 150.0,
                                                          decoration:
                                                              new BoxDecoration(
                                                            color: const Color(
                                                                0xff7c94b6),
                                                            image:
                                                                new DecorationImage(
                                                              image: new ExactAssetImage(
                                                                  'assets/imgs/placeholder.png'),
                                                              fit: BoxFit.cover,
                                                            ),
                                                            border: Border.all(
                                                                color: Color(
                                                                    0xff170e50),
                                                                width: 1.0),
                                                            borderRadius:
                                                                new BorderRadius
                                                                        .all(
                                                                    const Radius
                                                                            .circular(
                                                                        10.0)),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              isActive: true);
                                        }
                                        current_step = current_step + 1;
                                      });
                                    }
                                  },
                                ),
                                isActive: true));
                          } else {
                            my_steps[2] = Step(
                                // Title of the Step
                                title: Text("Year"),
                                // Content, it can be any widget here. Using basic Text for this example
                                content: TextFormField(
                                  controller: _yearController,
                                  style: TextStyle(fontSize: 13.0),
                                  maxLength: 4,
                                  decoration: InputDecoration(
                                      hintStyle: TextStyle(fontSize: 13.0),
                                      hintText: 'Enter Year',
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.calendar_today)),
                                  onChanged: (text) {
                                    var date = new DateTime.now();
                                    int currentYear = date.year;
                                    if (text.trim().length > 3 &&
                                        (int.parse(text.trim()) < 1900 ||
                                            int.parse(text.trim()) >=
                                                currentYear)) {
                                      _displaySnackBar(
                                          "Year must be between 1900 and $currentYear");
                                    } else if (text.trim().length == 4) {
                                      setState(() {
                                        if (my_steps.length == 3) {
                                          createSteps(Step(
                                              // Title of the Step
                                              title: Text("Add Photo"),
                                              // Content, it can be any widget here. Using basic Text for this example
                                              content: Container(
                                                child: new ClipRRect(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          8.0),
                                                  child: Stack(
                                                    children: <Widget>[
                                                      GestureDetector(
                                                        onTap: () => imagePicker
                                                            .showDialog(
                                                                context),
                                                        child: Container(
                                                          height: 90.0,
                                                          width: 150.0,
                                                          decoration:
                                                              new BoxDecoration(
                                                            color: const Color(
                                                                0xff7c94b6),
                                                            image:
                                                                new DecorationImage(
                                                              image: new ExactAssetImage(
                                                                  'assets/imgs/placeholder.png'),
                                                              fit: BoxFit.cover,
                                                            ),
                                                            border: Border.all(
                                                                color: Color(
                                                                    0xff170e50),
                                                                width: 1.0),
                                                            borderRadius:
                                                                new BorderRadius
                                                                        .all(
                                                                    const Radius
                                                                            .circular(
                                                                        10.0)),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              isActive: true));
                                        } else {
                                          my_steps[3] = Step(
                                              // Title of the Step
                                              title: Text("Add Photo"),
                                              // Content, it can be any widget here. Using basic Text for this example
                                              content: Container(
                                                child: new ClipRRect(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          8.0),
                                                  child: Stack(
                                                    children: <Widget>[
                                                      GestureDetector(
                                                        onTap: () => imagePicker
                                                            .showDialog(
                                                                context),
                                                        child: Container(
                                                          height: 90.0,
                                                          width: 150.0,
                                                          decoration:
                                                              new BoxDecoration(
                                                            color: const Color(
                                                                0xff7c94b6),
                                                            image:
                                                                new DecorationImage(
                                                              image: new ExactAssetImage(
                                                                  'assets/imgs/placeholder.png'),
                                                              fit: BoxFit.cover,
                                                            ),
                                                            border: Border.all(
                                                                color: Color(
                                                                    0xff170e50),
                                                                width: 1.0),
                                                            borderRadius:
                                                                new BorderRadius
                                                                        .all(
                                                                    const Radius
                                                                            .circular(
                                                                        10.0)),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              isActive: true);
                                        }
                                        current_step = current_step + 1;
                                      });
                                    }
                                  },
                                ),
                                isActive: true);
                          }
                          current_step = current_step + 1;
                        });
                      },
                    ),
                    isActive: true));
              } else {
                my_steps[1] = Step(
                    // Title of the Step
                    title: Text("Car Model"),
                    // Content, it can be any widget here. Using basic Text for this example
                    content: DropDownField(
                      controller: _cardmodel,
                      value: formData['model'],
                      icon: Icon(Icons.location_city),
                      required: true,
                      hintText: 'Choose a car model',
                      labelText: 'Car model *',
                      items: modelList,
                      strict: false,
                      setter: (dynamic newValue) {
                        formData['model'] = newValue.name;
                      },
                      onValueChanged: (val) {
                        print(val);
                        formData['model'] = val;
                        setState(() {
                          if (my_steps.length == 2) {
                            createSteps(Step(
                                // Title of the Step
                                title: Text("Year"),
                                // Content, it can be any widget here. Using basic Text for this example
                                content: TextFormField(
                                  controller: _yearController,
                                  style: TextStyle(fontSize: 13.0),
                                  maxLength: 4,
                                  decoration: InputDecoration(
                                      hintStyle: TextStyle(fontSize: 13.0),
                                      hintText: 'Enter Year',
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.calendar_today)),
                                  onChanged: (text) {
                                    var date = new DateTime.now();
                                    int currentYear = date.year;
                                    if (text.trim().length > 3 &&
                                        (int.parse(text.trim()) < 1900 ||
                                            int.parse(text.trim()) >=
                                                currentYear)) {
                                      _displaySnackBar(
                                          "Year must be between 1900 and $currentYear");
                                    } else if (text.trim().length == 4) {
                                      setState(() {
                                        if (my_steps.length == 3) {
                                          createSteps(Step(
                                              // Title of the Step
                                              title: Text("Add Photo"),
                                              // Content, it can be any widget here. Using basic Text for this example
                                              content: Container(
                                                child: new ClipRRect(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          8.0),
                                                  child: Stack(
                                                    children: <Widget>[
                                                      GestureDetector(
                                                        onTap: () => imagePicker
                                                            .showDialog(
                                                                context),
                                                        child: Container(
                                                          height: 90.0,
                                                          width: 150.0,
                                                          decoration:
                                                              new BoxDecoration(
                                                            color: const Color(
                                                                0xff7c94b6),
                                                            image:
                                                                new DecorationImage(
                                                              image: new ExactAssetImage(
                                                                  'assets/imgs/placeholder.png'),
                                                              fit: BoxFit.cover,
                                                            ),
                                                            border: Border.all(
                                                                color: Color(
                                                                    0xff170e50),
                                                                width: 1.0),
                                                            borderRadius:
                                                                new BorderRadius
                                                                        .all(
                                                                    const Radius
                                                                            .circular(
                                                                        10.0)),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              isActive: true));
                                        } else {
                                          my_steps[3] = Step(
                                              // Title of the Step
                                              title: Text("Add Photo"),
                                              // Content, it can be any widget here. Using basic Text for this example
                                              content: Container(
                                                child: new ClipRRect(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          8.0),
                                                  child: Stack(
                                                    children: <Widget>[
                                                      GestureDetector(
                                                        onTap: () => imagePicker
                                                            .showDialog(
                                                                context),
                                                        child: Container(
                                                          height: 90.0,
                                                          width: 150.0,
                                                          decoration:
                                                              new BoxDecoration(
                                                            color: const Color(
                                                                0xff7c94b6),
                                                            image:
                                                                new DecorationImage(
                                                              image: new ExactAssetImage(
                                                                  'assets/imgs/placeholder.png'),
                                                              fit: BoxFit.cover,
                                                            ),
                                                            border: Border.all(
                                                                color: Color(
                                                                    0xff170e50),
                                                                width: 1.0),
                                                            borderRadius:
                                                                new BorderRadius
                                                                        .all(
                                                                    const Radius
                                                                            .circular(
                                                                        10.0)),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              isActive: true);
                                        }
                                        current_step = current_step + 1;
                                      });
                                    }
                                  },
                                ),
                                isActive: true));
                          } else {
                            my_steps[2] = Step(
                                // Title of the Step
                                title: Text("Year"),
                                // Content, it can be any widget here. Using basic Text for this example
                                content: TextFormField(
                                  controller: _yearController,
                                  style: TextStyle(fontSize: 13.0),
                                  maxLength: 4,
                                  decoration: InputDecoration(
                                      hintStyle: TextStyle(fontSize: 13.0),
                                      hintText: 'Enter Year',
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.calendar_today)),
                                  onChanged: (text) {
                                    var date = new DateTime.now();
                                    int currentYear = date.year;
                                    if (text.trim().length > 3 &&
                                        (int.parse(text.trim()) < 1900 ||
                                            int.parse(text.trim()) >=
                                                currentYear)) {
                                      _displaySnackBar(
                                          "Year must be between 1900 and $currentYear");
                                    } else if (text.trim().length == 4) {
                                      setState(() {
                                        if (my_steps.length == 3) {
                                          createSteps(Step(
                                              // Title of the Step
                                              title: Text("Add Photo"),
                                              // Content, it can be any widget here. Using basic Text for this example
                                              content: Container(
                                                child: new ClipRRect(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          8.0),
                                                  child: Stack(
                                                    children: <Widget>[
                                                      GestureDetector(
                                                        onTap: () => imagePicker
                                                            .showDialog(
                                                                context),
                                                        child: Container(
                                                          height: 90.0,
                                                          width: 150.0,
                                                          decoration:
                                                              new BoxDecoration(
                                                            color: const Color(
                                                                0xff7c94b6),
                                                            image:
                                                                new DecorationImage(
                                                              image: new ExactAssetImage(
                                                                  'assets/imgs/placeholder.png'),
                                                              fit: BoxFit.cover,
                                                            ),
                                                            border: Border.all(
                                                                color: Color(
                                                                    0xff170e50),
                                                                width: 1.0),
                                                            borderRadius:
                                                                new BorderRadius
                                                                        .all(
                                                                    const Radius
                                                                            .circular(
                                                                        10.0)),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              isActive: true));
                                        } else {
                                          my_steps[3] = Step(
                                              // Title of the Step
                                              title: Text("Add Photo"),
                                              // Content, it can be any widget here. Using basic Text for this example
                                              content: Container(
                                                child: new ClipRRect(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          8.0),
                                                  child: Stack(
                                                    children: <Widget>[
                                                      GestureDetector(
                                                        onTap: () => imagePicker
                                                            .showDialog(
                                                                context),
                                                        child: Container(
                                                          height: 90.0,
                                                          width: 150.0,
                                                          decoration:
                                                              new BoxDecoration(
                                                            color: const Color(
                                                                0xff7c94b6),
                                                            image:
                                                                new DecorationImage(
                                                              image: new ExactAssetImage(
                                                                  'assets/imgs/placeholder.png'),
                                                              fit: BoxFit.cover,
                                                            ),
                                                            border: Border.all(
                                                                color: Color(
                                                                    0xff170e50),
                                                                width: 1.0),
                                                            borderRadius:
                                                                new BorderRadius
                                                                        .all(
                                                                    const Radius
                                                                            .circular(
                                                                        10.0)),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              isActive: true);
                                        }
                                        current_step = current_step + 1;
                                      });
                                    }
                                  },
                                ),
                                isActive: true);
                          }
                          current_step = current_step + 1;
                        });
                      },
                    ),
                    isActive: true);
              }
              current_step = current_step + 1;
            });
          } else {
            presentToast("No record found", context, 0);
          }
        } else {
          presentToast(data['message'], context, 0);
        }
      });
    });
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

  void createSteps(Step step) {
    my_steps.add(step);
  }
}
