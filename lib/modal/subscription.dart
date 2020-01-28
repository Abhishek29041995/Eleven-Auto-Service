class Subription {
  String _id;
  String _title;
  List<String> _description;
  String _validity;
  String _price;
  String _discount;
  String _discount_type;
  String _created_at;
  String _updated_at;

  Subription(this._id, this._title, this._description, this._validity,
      this._price, this._discount, this._discount_type, this._created_at,
      this._updated_at);

  String get updated_at => _updated_at;

  set updated_at(String value) {
    _updated_at = value;
  }

  String get created_at => _created_at;

  set created_at(String value) {
    _created_at = value;
  }

  String get discount_type => _discount_type;

  set discount_type(String value) {
    _discount_type = value;
  }

  String get discount => _discount;

  set discount(String value) {
    _discount = value;
  }

  String get price => _price;

  set price(String value) {
    _price = value;
  }

  String get validity => _validity;

  set validity(String value) {
    _validity = value;
  }


  List<String> get description => _description;

  set description(List<String> value) {
    _description = value;
  }

  String get title => _title;

  set title(String value) {
    _title = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

}
