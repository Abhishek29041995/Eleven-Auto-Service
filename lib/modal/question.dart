import 'package:eleve11/modal/answer.dart';

class Question{
  String _id;
  String _question;
  String _created_at;
  String _updated_at;
  List<Answer> _answer;

  Question(this._id, this._question, this._created_at, this._updated_at,
      this._answer);

  List<Answer> get answer => _answer;

  set answer(List<Answer> value) {
    _answer = value;
  }

  String get updated_at => _updated_at;

  set updated_at(String value) {
    _updated_at = value;
  }

  String get created_at => _created_at;

  set created_at(String value) {
    _created_at = value;
  }

  String get question => _question;

  set question(String value) {
    _question = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

}