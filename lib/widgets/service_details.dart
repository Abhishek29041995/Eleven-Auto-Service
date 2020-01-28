import 'package:eleve11/modal/service.dart';
import 'package:eleve11/widgets/arc_banner_image.dart';
import 'package:eleve11/widgets/poster.dart';
import 'package:eleve11/widgets/rating_information.dart';
import 'package:flutter/material.dart';

class ServiceDetailHeader extends StatelessWidget {
  ServiceDetailHeader(this.service);

  final Service service;

  List<Widget> _buildCategoryChips(TextTheme textTheme) {
    return service.categories.map((category) {
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Chip(
          label: Text(category),
          labelStyle: textTheme.caption,
          backgroundColor: Colors.black12,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    var movieInformation = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          service.title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: "Montserrat",
                color: Color(0xffFFD700),
                shadows: [Shadow(color: Colors.black, blurRadius: 8, offset: Offset(5, 5))]),
        ),
        SizedBox(height: 8.0),
        RatingInformation(service),
        SizedBox(height: 12.0),
        Wrap(children: _buildCategoryChips(textTheme),),
      ],
    );

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 140.0),
          child: ArcBannerImage(service.bannerUrl),
        ),
        Positioned(
          bottom: 0.0,
          left: 16.0,
          right: 16.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Poster(
                service.posterUrl,
                height: 180.0,
              ),
              SizedBox(width: 16.0),
              Expanded(child: movieInformation),
            ],
          ),
        ),
      ],
    );
  }
}
