class Services {
  String _id;
  String _name;
  String _imageurl;
  String _isnew;
  String _iactive;
  String _radioButton;
  String _created_at;
  String _updated_at;


  Services(this._id, this._name, this._imageurl, this._isnew, this._iactive,
      this._radioButton, this._created_at, this._updated_at);

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get name => _name;

  String get updated_at => _updated_at;

  set updated_at(String value) {
    _updated_at = value;
  }

  String get created_at => _created_at;

  set created_at(String value) {
    _created_at = value;
  }

  String get radioButton => _radioButton;

  set radioButton(String value) {
    _radioButton = value;
  }

  String get iactive => _iactive;

  set iactive(String value) {
    _iactive = value;
  }

  String get isnew => _isnew;

  set isnew(String value) {
    _isnew = value;
  }

  String get imageurl => _imageurl;

  set imageurl(String value) {
    _imageurl = value;
  }

  set name(String value) {
    _name = value;
  }

}
