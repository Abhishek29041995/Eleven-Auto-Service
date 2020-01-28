class Locations {
  String _id;
  String _user_id;
  String _name;
  String _house;
  String _landmark;
  String _address;
  String _lat;
  String _lon;
  String _created_at;
  String _updated_at;

  Locations(this._id, this._user_id, this._name, this._house, this._landmark,
      this._address, this._lat, this._lon, this._created_at, this._updated_at);

  String get updated_at => _updated_at;

  set updated_at(String value) {
    _updated_at = value;
  }

  String get created_at => _created_at;

  set created_at(String value) {
    _created_at = value;
  }

  String get lon => _lon;

  set lon(String value) {
    _lon = value;
  }

  String get lat => _lat;

  set lat(String value) {
    _lat = value;
  }

  String get address => _address;

  set address(String value) {
    _address = value;
  }

  String get landmark => _landmark;

  set landmark(String value) {
    _landmark = value;
  }

  String get house => _house;

  set house(String value) {
    _house = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
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
