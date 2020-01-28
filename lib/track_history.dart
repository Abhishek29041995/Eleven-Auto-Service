import 'package:eleve11/modal/booking_track.dart';
import 'package:flutter/material.dart';

class TrackHistory extends StatefulWidget {
  List<BookingTrack> booking_progress;

  TrackHistory(List<BookingTrack> booking_progress) {
    this.booking_progress = booking_progress;
  }

  _TrackHistory createState() => _TrackHistory(this.booking_progress);
}

class _TrackHistory extends State<TrackHistory> {
  List<BookingTrack> booking_progress;
  List<Step> list = new List();
  int current_step = 0;

  _TrackHistory(List<BookingTrack> booking_progress) {
    this.booking_progress = booking_progress;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createSteps(this.booking_progress);
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
        title: new Text("Track History"),

        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        textTheme: TextTheme(
          title: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
      ),
      backgroundColor: Color(0xffF2F2F2),
      body: list.length > 0
          ? Stepper(
              // Using a variable here for handling the currentStep
              currentStep: this.current_step,
              // List the steps you would like to have
              steps: list,
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
            )
          : Center(
              child: Text("No tracking updates"),
            ),
    );
  }

  void createSteps(List<BookingTrack> booking_progress) {
    List<Step> my_steps = new List();
    for (BookingTrack bookingTrack in booking_progress) {
      my_steps.add(Step(
          // Title of the Step
          title: Text(bookingTrack.comment),
          // Content, it can be any widget here. Using basic Text for this example
          content: Text(bookingTrack.created_at),
          isActive: true));
    }
    setState(() {
      list = my_steps;
    });
  }
}
