class QusAns{
  String _id;
  String _question;
  String _answer;

  QusAns(this._id,this._question, this._answer);
  Map<String, dynamic> toJsonAttr() => {
    'question': this._question,
    'answer': this._answer
  };
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