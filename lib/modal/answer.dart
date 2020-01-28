class Answer {
  String _id;
  String _question_id;
  String _answer;
  bool _status;
  String _created_at;
  String _updated_at;

  Answer(this._id, this._question_id, this._answer,this._status, this._created_at,
      this._updated_at);

  String get id => _id;

  bool get status => _status;

  set status(bool value) {
    _status = value;
  }

  set id(String value) {
    _id = value;
  }

  String get question_id => _question_id;

  String get updated_at => _updated_at;

  set updated_at(String value) {
    _updated_at = value;
  }

  String get created_at => _created_at;

  set created_at(String value) {
    _created_at = value;
  }

  String get answer => _answer;

  set answer(String value) {
    _answer = value;
  }

  set question_id(String value) {
    _question_id = value;
  }

}
