class OrderList {
  String _id;
  String _name;
  String _description;
  String _code;
  String _value;
  String _type;
  String _image;
  String _terms;
  String _for_new_user;
  String _expires_on;
  String _active;
  String _created_at;
  String _updated_at;

  OrderList(this._id, this._name, this._description, this._code, this._value,
      this._type, this._image, this._terms, this._for_new_user, this._expires_on,
      this._active, this._created_at, this._updated_at);

  String get terms => _terms;

  set terms(String value) {
    _terms = value;
  }

  String get updated_at => _updated_at;

  set updated_at(String value) {
    _updated_at = value;
  }

  String get created_at => _created_at;

  set created_at(String value) {
    _created_at = value;
  }

  String get active => _active;

  set active(String value) {
    _active = value;
  }

  String get expires_on => _expires_on;

  set expires_on(String value) {
    _expires_on = value;
  }

  String get for_new_user => _for_new_user;

  set for_new_user(String value) {
    _for_new_user = value;
  }

  String get image => _image;

  set image(String value) {
    _image = value;
  }

  String get type => _type;

  set type(String value) {
    _type = value;
  }

  String get value => _value;

  set value(String value) {
    _value = value;
  }

  String get code => _code;

  set code(String value) {
    _code = value;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

}
