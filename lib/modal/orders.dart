import 'package:eleve11/modal/booking_track.dart';

class Orders {
  String _id;
  String _booking_ref;
  String _user_id;
  String _address_id;
  String _service_id;
  String _actual_price;
  String _discount_value;
  String _discount_type;
  String _payment_type;
  String _subscription_id;
  String _subscription_discount;
  String _discounted_price;
  String _user_lat;
  String _user_lon;
  String _status;
  String _created_at;
  String _updated_at;
  Map _service;
  Map _address;
  Map _worker;
  String _feedback_count;
  List<BookingTrack> _booking_progress;

  Orders(this._id, this._booking_ref, this._user_id, this._address_id,
      this._service_id, this._actual_price, this._discount_value,
      this._discount_type, this._payment_type,this._subscription_id,this._subscription_discount, this._discounted_price,
      this._user_lat, this._user_lon, this._status, this._created_at,
      this._updated_at, this._service, this._address, this._worker, this._feedback_count,
      this._booking_progress);


  String get feedback_count => _feedback_count;

  set feedback_count(String value) {
    _feedback_count = value;
  }

  String get subscription_id => _subscription_id;

  set subscription_id(String value) {
    _subscription_id = value;
  }

  List<BookingTrack> get booking_progress => _booking_progress;

  set booking_progress(List<BookingTrack> value) {
    _booking_progress = value;
  }

  Map get worker => _worker;

  set worker(Map value) {
    _worker = value;
  }

  Map get address => _address;

  set address(Map value) {
    _address = value;
  }

  Map get service => _service;

  set service(Map value) {
    _service = value;
  }

  String get updated_at => _updated_at;

  set updated_at(String value) {
    _updated_at = value;
  }

  String get created_at => _created_at;

  set created_at(String value) {
    _created_at = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get user_lon => _user_lon;

  set user_lon(String value) {
    _user_lon = value;
  }

  String get user_lat => _user_lat;

  set user_lat(String value) {
    _user_lat = value;
  }

  String get discounted_price => _discounted_price;

  set discounted_price(String value) {
    _discounted_price = value;
  }

  String get payment_type => _payment_type;

  set payment_type(String value) {
    _payment_type = value;
  }

  String get discount_type => _discount_type;

  set discount_type(String value) {
    _discount_type = value;
  }

  String get discount_value => _discount_value;

  set discount_value(String value) {
    _discount_value = value;
  }

  String get actual_price => _actual_price;

  set actual_price(String value) {
    _actual_price = value;
  }

  String get service_id => _service_id;

  set service_id(String value) {
    _service_id = value;
  }

  String get address_id => _address_id;

  set address_id(String value) {
    _address_id = value;
  }

  String get user_id => _user_id;

  set user_id(String value) {
    _user_id = value;
  }

  String get booking_ref => _booking_ref;

  set booking_ref(String value) {
    _booking_ref = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get subscription_discount => _subscription_discount;

  set subscription_discount(String value) {
    _subscription_discount = value;
  }


}
