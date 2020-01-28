import 'dart:ui';

import 'package:flutter/foundation.dart';

class LocaleModel with ChangeNotifier {
  Locale locale = Locale('en');
  Locale get getlocale => locale;
  void changelocale(Locale l) {
    locale = l;
    notifyListeners();
  }
}