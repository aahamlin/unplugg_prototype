import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

enum PhoneEventName {
  locking,
  unlocked,
  exiting
}

class PhoneEvent {
  PhoneEvent(this._name);

  PhoneEventName _name;
  final DateTime _dateTime = DateTime.now();

  PhoneEventName get name => _name;
  DateTime get dateTime => _dateTime;

  PhoneEvent.fromString(String str) {
    PhoneEventName pen = PhoneEventName.values.firstWhere((pen) => describeEnum(pen) == str);
    assert(pen != null);
    this._name = pen;
  }

  @override toString() {
    return '${_name}@${_dateTime.toString()}';
  }
}

class PhoneEventService {

  static final PhoneEventService instance = new PhoneEventService._();

  final _eventChannel = EventChannel('unpluggyourself.com/phone_event');

  final List<PhoneEventObserver> _observers = List<PhoneEventObserver>();

  PhoneEventService._() {
    _eventChannel.receiveBroadcastStream().listen(
      this._handlePhoneEvent,
      onError: this._handleError,
      onDone: this._handleDone,
    );
  }

  void addObserver(PhoneEventObserver o) {
    _observers.add(o);
  }

  void removeObserver(PhoneEventObserver o) {
    _observers.remove(o);
  }

  void _handlePhoneEvent(rawEvent) {
    var event = PhoneEvent.fromString(rawEvent);
    print('platform event: ${event.toString()}');
    _notifyObservers(event);

  }

  void _handleError(error) {
    print('platform error: $error');
    //_notifyObservers('error: ${error.toString()}');
  }

  void _handleDone() {
    // not sure what, if anything, needs to be done
    print('platform stream closed');
    //_notifyObservers('platform stream closed');
    _observers.clear();
  }

  void _notifyObservers(PhoneEvent event) {
    //_observers.forEach((o) => o.onPhoneEvent(event));
    for(PhoneEventObserver observer in _observers) {
      observer.onPhoneEvent(event);
    }
  }
}


abstract class PhoneEventObserver {

  void onPhoneEvent(PhoneEvent event);

}