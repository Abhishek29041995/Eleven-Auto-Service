class FAQ{
  String _id;
  String _question;
  String _answer;
  String _created_at;
  String _updated_at;

  FAQ(this._id, this._question, this._answer, this._created_at,
      this._updated_at);

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

  String get question => _question;

  set question(String value) {
    _question = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

}