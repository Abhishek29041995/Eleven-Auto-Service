import 'dart:convert';

import 'package:eleve11/modal/answer.dart';
import 'package:eleve11/modal/question.dart';
import 'package:eleve11/modal/qus_ans.dart';
import 'package:eleve11/services/api_services.dart';
import 'package:eleve11/utils/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackDynamic extends StatefulWidget {
  String orderId;

  FeedbackDynamic(String orderId) {
    this.orderId = orderId;
  }

  _FeedbackDynamicState createState() => _FeedbackDynamicState(this.orderId);
}

class _FeedbackDynamicState extends State<FeedbackDynamic> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String orderId;

  _FeedbackDynamicState(String orderId) {
    this.orderId = orderId;
  }

  List<Step> get listSteps => createSteps();
  List<Question> questionList = new List();
  int current_step = 0;
  String acccessToken = "";
  bool _isLoading = true;

  List<QusAns> qusAns = new List();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        key: _scaffoldKey,
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
          title: new Text(Translations.of(context).text('feedback')),

          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          textTheme: TextTheme(
            title: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
        ),
        backgroundColor: Color(0xffF2F2F2),
        body: Stack(
          children: _buildWidget(),
        ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIsLogin();
  }

  Future<Null> checkIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    JsonCodec codec = new JsonCodec();
    acccessToken = prefs.getString("accessToken");
    getquestions();
  }

  void getquestions() {
    setState(() {
      _isLoading = true;
    });
    var request = new MultipartRequest(
        "GET", Uri.parse(api_url + "user/feedback/questionnaire"));
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
            List<Question> tempList = new List();
            if (data['data'].length > 0) {
              for (var i = 0; i < data['data'].length; i++) {
                List<Answer> answer = new List();
                for (var j = 0; j < data['data'][i]['answer'].length; j++) {
                  answer.add(new Answer(
                      data['data'][i]['answer'][j]['id'].toString(),
                      data['data'][i]['answer'][j]['question_id'],
                      data['data'][i]['answer'][j]['answer'],
                      false,
                      data['data'][i]['answer'][j]['created_at'],
                      data['data'][i]['answer'][j]['updated_at']));
                }
                tempList.add(new Question(
                    data['data'][i]['id'].toString(),
                    data['data'][i]['question'],
                    data['data'][i]['created_at'],
                    data['data'][i]['updated_at'],
                    answer));
              }
              setState(() {
                questionList = tempList;
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

  List<Widget> _buildWidget() {
    List<Widget> list = new List();
    if (listSteps.length > 0) {
      var manufacturerNames = Stepper(
        key: Key("mysuperkey-" + listSteps.length.toString()),
        // Using a variable here for handling the currentStep
        currentStep: this.current_step,
        // List the steps you would like to have
        steps: listSteps,
        // Define the type of Stepper style
        // StepperType.horizontal :  Horizontal Style
        // StepperType.vertical   :  Vertical Style
        type: StepperType.horizontal,
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
                  if (qusAns.length == questionList.length) {
                    addFeedback();
                  } else {
                    _displaySnackBar(Translations.of(context).text('give_all_feed'));
                  }
                },
                textColor: Colors.white,
                color: Color(0xff170e50),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)))),
      ),
    );
    if (listSteps.length > 0 && current_step == listSteps.length - 1) {
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

  createSteps() {
    List<Step> my_steps = new List();
    for (Question question in questionList) {
      my_steps.add(Step(
          // Title of the Step
          title: Text(""),
          // Content, it can be any widget here. Using basic Text for this example
          content: Column(
            children: <Widget>[
              Text(
                  Translations.of(context).text('qus') +
                      (questionList.indexOf(question) + 1).toString() +
                      " " +
                      question.question,
                  style: TextStyle(fontFamily: 'Montserrat')),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: question.answer.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return new InkWell(
                        //highlightColor: Colors.red,
                        splashColor: Colors.blueAccent,
                        onTap: () {
                          setState(() {
                            question.answer
                                .forEach((element) => element.status = false);
                            question.answer[index].status = true;
                            if (qusAns.length == 0) {
                              qusAns.add(new QusAns(
                                  question.id,
                                  question.question,
                                  question.answer[index].answer));
                            } else {
                              if (qusAns
                                      .indexWhere((i) => i.id == question.id) ==
                                  -1) {
                                qusAns.add(new QusAns(
                                    question.id,
                                    question.question,
                                    question.answer[index].answer));
                              } else {
                                qusAns[qusAns.indexWhere(
                                        (i) => i.id == question.id)] =
                                    new QusAns(question.id, question.question,
                                        question.answer[index].answer);
                              }
                            }

                            if (current_step < questionList.length - 1) {
                              setState(() {
                                current_step = current_step + 1;
                              });
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: new Container(
                            height: 50.0,
                            width: 50.0,
                            child: new Center(
                              child: new Text(question.answer[index].answer,
                                  style: new TextStyle(
                                      color: question.answer[index].status
                                          ? Colors.white
                                          : Colors.black,
                                      //fontWeight: FontWeight.bold,
                                      fontSize: 18.0)),
                            ),
                            decoration: new BoxDecoration(
                              color: question.answer[index].status
                                  ? Colors.blueAccent
                                  : Colors.transparent,
                              border: new Border.all(
                                  width: 1.0,
                                  color: question.answer[index].status
                                      ? Colors.blueAccent
                                      : Colors.grey),
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(2.0)),
                            ),
                          ),
                        ));
                  })
            ],
          ),
          isActive: true));
    }
    return my_steps;
  }

  addFeedback() {
    setState(() {
      _isLoading = true;
    });
    var jsonvar = jsonEncode(qusAns.map((e) => e.toJsonAttr()).toList());
    var request = new MultipartRequest(
        "POST", Uri.parse(api_url + "user/feedback/submit"));
    request.fields['answers'] = jsonvar;
    request.fields['booking_id'] = orderId;
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
}
