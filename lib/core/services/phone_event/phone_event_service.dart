import 'package:flutter/services.dart';
import 'package:unplugg_prototype/core/services/phone_event/phone_event_model.dart';
import 'package:unplugg_prototype/core/services/phone_event/phone_event_observer.dart';

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
    var event = PhoneEventModel.fromString(rawEvent);
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

  void _notifyObservers(PhoneEventModel event) {
    //_observers.forEach((o) => o.onPhoneEvent(event));
    for(PhoneEventObserver observer in _observers) {
      observer.onPhoneEvent(event);
    }
  }
}