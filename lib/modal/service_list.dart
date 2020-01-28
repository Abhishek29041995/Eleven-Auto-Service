import 'package:eleve11/modal/child_services.dart';

class ServiceList {
  String _id;
  String _service_category_id;
  String _name;
  String _image;
  String _sedan_price;
  String _suv_price;
  String _description;
  String _isnew;
  String _iactive;
  String _radioButton;
  String _created_at;
  String _updated_at;
  bool _isChecked;

  ServiceList(this._id, this._service_category_id, this._name,this._image,
      this._sedan_price, this._suv_price, this._description, this._isnew,
      this._iactive, this._radioButton, this._created_at, this._updated_at,
      this._isChecked);

  String get image => _image;

  set image(String value) {
    _image = value;
  }

  bool get isChecked => _isChecked;

  set isChecked(bool value) {
    _isChecked = value;
  }

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

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  String get suv_price => _suv_price;

  set suv_price(String value) {
    _suv_price = value;
  }

  String get sedan_price => _sedan_price;

  set sedan_price(String value) {
    _sedan_price = value;
  }


  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get service_category_id => _service_category_id;

  set service_category_id(String value) {
    _service_category_id = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

}