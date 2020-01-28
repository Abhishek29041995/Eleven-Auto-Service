import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:toast/toast.dart';

String api_url = "http://eleve11.demoonline.co.in/api/";
presentToast(msg, context, position) {
  Toast.show(msg, context,
      duration: Toast.LENGTH_LONG,
      backgroundColor: Color(0xff170e50),
      gravity: position);
}
Future<StreamedResponse> commonMethod(request) async {
  var response = await request.send();
  return response;
}
