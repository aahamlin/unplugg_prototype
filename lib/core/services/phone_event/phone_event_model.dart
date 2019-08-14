import 'package:flutter/foundation.dart';
import 'package:unplugg_prototype/core/services/phone_event/phone_event_state.dart';

class PhoneEventModel {
  PhoneEventModel(this._name);

  PhoneEventState _name;
  final DateTime _dateTime = DateTime.now();

  PhoneEventState get state => _name;
  DateTime get dateTime => _dateTime;

  PhoneEventModel.fromString(String str) {
    PhoneEventState pen = PhoneEventState.values.firstWhere((pen) => describeEnum(pen) == str);
    assert(pen != null);
    this._name = pen;
  }

  @override toString() {
    return '${_name}@${_dateTime.toString()}';
  }
}