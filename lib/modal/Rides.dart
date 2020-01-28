class Rides {
  String _id;
  String _user_id;
  String _image;
  String _car_model_id;
  String _type;
  String _created_at;
  String _updated_at;
  Map _car_model;

  Map get car_model => _car_model;

  set car_model(Map value) {
    _car_model = value;
  }

  Rides(this._id, this._user_id,this._image, this._car_model_id, this._type,
      this._created_at, this._updated_at,this._car_model);

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get image => _image;

  set image(String value) {
    _image = value;
  }

  String get user_id => _user_id;

  String get updated_at => _updated_at;

  set updated_at(String value) {
    _updated_at = value;
  }

  String get created_at => _created_at;

  set created_at(String value) {
    _created_at = value;
  }

  String get type => _type;

  set type(String value) {
    _type = value;
  }

  String get car_model_id => _car_model_id;

  set car_model_id(String value) {
    _car_model_id = value;
  }

  set user_id(String value) {
    _user_id = value;
  }

}