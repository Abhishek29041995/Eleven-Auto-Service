class ManufacturerList{
  String _id;
  String _name;
  String _image;
  String _type;
  String _created_at;
  String _updated_at;

  String get type => _type;

  set type(String value) {
    _type = value;
  }

  ManufacturerList(this._id, this._name, this._image,this._type, this._created_at,
      this._updated_at);

  String get updated_at => _updated_at;

  set updated_at(String value) {
    _updated_at = value;
  }

  String get created_at => _created_at;

  set created_at(String value) {
    _created_at = value;
  }

  String get image => _image;

  set image(String value) {
    _image = value;
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