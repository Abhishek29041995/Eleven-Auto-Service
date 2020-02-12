import 'dart:io';

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
  var response = await request.send().then((value) async {
    if (value.statusCode == 200) {
      return value;
    }
  });
  return response;
}

Future<Response> commeonMethod1(Map data,String token,String extraParam) async {
  final response = await post(api_url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'Authorization': "Bearer $token"
      },
      body: data);

  return response;
}
