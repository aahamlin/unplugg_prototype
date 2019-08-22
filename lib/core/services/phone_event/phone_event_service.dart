import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;


enum PhoneState {
  locking,
  unlocked,
  exiting
}

class PhoneEventService {

  factory PhoneEventService() {
    if (_instance == null) {
      final EventChannel eventChannel =
        const EventChannel('unpluggyourself.com/phone_event');
      _instance = PhoneEventService.private(eventChannel);
    }
    return _instance;
  }

  @visibleForTesting
  PhoneEventService.private(this._eventChannel);

  static PhoneEventService _instance;

  final EventChannel _eventChannel;
  Stream<PhoneState> _onPhoneStateChanged;

  Stream<PhoneState> get onPhoneStateChanged {
    if(_onPhoneStateChanged == null) {
      _onPhoneStateChanged = _eventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => _parsePhoneState(event));
    }

    return _onPhoneStateChanged;
  }

  PhoneState _parsePhoneState(String state) {
    switch(state) {
      case 'locking':
        return PhoneState.locking;
      case 'unlocked':
        return PhoneState.unlocked;
      case 'exiting':
        return PhoneState.exiting;
      default:
        throw ArgumentError('$state is not valid PhoneState');
    }
  }
}