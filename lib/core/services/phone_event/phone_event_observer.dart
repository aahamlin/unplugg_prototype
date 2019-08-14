import 'package:unplugg_prototype/core/services/phone_event/phone_event_model.dart';
export 'phone_event_service.dart';
export 'phone_event_state.dart';
export 'phone_event_model.dart';

abstract class PhoneEventObserver {

  void onPhoneEvent(PhoneEventModel event);

}
