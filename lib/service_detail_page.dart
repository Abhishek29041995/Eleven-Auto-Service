import 'package:eleve11/modal/service.dart';
import 'package:eleve11/widgets/photo_scroller.dart';
import 'package:eleve11/widgets/service_details.dart';
import 'package:eleve11/widgets/story_line.dart';
import 'package:flutter/material.dart';

class ServiceDetailPage extends StatelessWidget {
  ServiceDetailPage(this.service);

  final Service service;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ServiceDetailHeader(service),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Storyline(service.storyline),
            ),
            PhotoScroller(service.photoUrls),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
