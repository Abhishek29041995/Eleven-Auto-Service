class BookingTrack {
  String _id;
  String _booking_id;
  String _comment;
  String _created_at;
  String _updated_at;

  BookingTrack(this._id, this._booking_id, this._comment, this._created_at,
      this._updated_at);

  String get updated_at => _updated_at;

  set updated_at(String value) {
    _updated_at = value;
  }

  String get created_at => _created_at;

  set created_at(String value) {
    _created_at = value;
  }

  String get comment => _comment;

  set comment(String value) {
    _comment = value;
  }

  String get booking_id => _booking_id;

  set booking_id(String value) {
    _booking_id = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

}
