class NotificationL {
  String _id;
  String _user_id;
  String _title;
  String _body;
  Map _created_at;
  String _updated_at;

  NotificationL(this._id, this._user_id, this._title, this._body,
      this._created_at, this._updated_at);

  String get updated_at => _updated_at;

  set updated_at(String value) {
    _updated_at = value;
  }

  Map get created_at => _created_at;

  set created_at(Map value) {
    _created_at = value;
  }

  String get body => _body;

  set body(String value) {
    _body = value;
  }

  String get title => _title;

  set title(String value) {
    _title = value;
  }

  String get user_id => _user_id;

  set user_id(String value) {
    _user_id = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }
}
