import 'package:flutter/foundation.dart';
import 'bloc_base.dart';
import 'package:unplugg_prototype/core/data/database.dart';
import 'package:unplugg_prototype/core/data/models/session.dart';
import 'package:unplugg_prototype/core/data/models/expiry.dart';
import 'package:unplugg_prototype/viewmodel/session_viewmodel.dart';

/**
 * Moves session through its states: None, Running, Complete, Incomplete
 */
class SessionStateBloc extends BlocBase<SessionViewModel> {

  final DBProvider dbProvider;

  SessionStateBloc({DBProvider this.dbProvider}) {
    _scan();
  }

  Future<void> _scan() async {
    debugPrint('Scanning for current session.');
    var session = await dbProvider.getCurrentSession();
    // kick off app in running session, allow session page to complete
    if (session != null) {
      var sessionEndTime = session.startTime.add(session.duration);

      if (DateTime.now().isAfter(sessionEndTime)) {
        final vm = SessionViewModel(
          id: session.id,
          startTime: session.startTime,
          duration: session.duration,
        );
        return complete(vm);
      }
      else {
        final vm = SessionViewModel(
          id: session.id,
          startTime: session.startTime,
          duration: session.duration,
          state: SessionViewState.running,
        );
        this.inSink.add(vm);
      }
    }
  }

  Future<void> start({Duration duration}) async {
    debugPrint('start: ${duration.inMinutes}');
    var session = await dbProvider.insertSession(
        Session(duration:duration, startTime: DateTime.now()));

    final vm = SessionViewModel(
      id: session.id,
      startTime: session.startTime,
      duration: session.duration,
      state: SessionViewState.running,
    );

    this.inSink.add(vm);
  }


  Future<void> cancel(final SessionViewModel input) async {
    debugPrint('cancel: ${input}');
    assert(input.state == SessionViewState.running);

    var session = Session(id: input.id,
      duration: input.duration,
      startTime: input.startTime,
      result: SessionResult.failure,
      reason: 'User cancelled');

    await dbProvider.updateSessionAndDeleteExpiry(session);

    final output = SessionViewModel(
      id: session.id,
      duration: session.duration,
      startTime: session.startTime,
      state: SessionViewState.cancelled,
    );

    this.inSink.add(output);
  }


  Future<void> complete(final SessionViewModel input) async {
    debugPrint('complete: ${input}');
    assert(input.state == SessionViewState.running);

    var session = Session(id: input.id,
      duration: input.duration,
      startTime: input.startTime,
    );

    var sessionHasExpired = await _checkForExpiredSession(session);

    if(sessionHasExpired) {
      session.result = SessionResult.failure;
      session.reason = 'User left session for too long';
    }
    else {
      session.result = SessionResult.success;
      session.reason = 'Success';
    }

    await dbProvider.updateSessionAndDeleteExpiry(session);

    final output = SessionViewModel(
      id: session.id,
      duration: session.duration,
      startTime: session.startTime,
      state: session.result == SessionResult.success ? SessionViewState.succeeded : SessionViewState.failed,
    );
    this.inSink.add(output);
  }

  Future<void> fail(final SessionViewModel input) async {
    var session = await dbProvider.getSession(input.id);
    session.result = SessionResult.failure;
    session.reason = 'User interrupted session';

    await dbProvider.updateSessionAndDeleteExpiry(session);

    final output = SessionViewModel(
      id: session.id,
      duration: session.duration,
      startTime: session.startTime,
      state: SessionViewState.failed,
    );

    this.inSink.add(output);
  }

  Future<int> setExpiryOnSession(SessionViewModel vm, Duration expiry) async {
    debugPrint('setExpiryOnSession: ${vm}');
    var expireTime = DateTime.now().add(expiry);
    var runExpiry = Expiry(session_fk: vm.id, expiry: expireTime);
    var expiryWarnings = await dbProvider.insertExpiryWarning(runExpiry);
    return expiryWarnings.length;
  }

  Future<void> cancelExpiryOnSession(SessionViewModel vm) async {
    var runExpiry = Expiry(session_fk: vm.id);
    var listOfInterrupts = await dbProvider.cancelExpiryWarning(runExpiry);
    if (listOfInterrupts.isNotEmpty) {
      debugPrint(
          'cancelled ${listOfInterrupts.last} of ${listOfInterrupts.length}');
    }
  }

  Future<bool> _checkForExpiredSession(Session session) async {
    debugPrint('_checkForExpiredSession: ${session}');
    var sessionEndTime = session.startTime.add(session.duration);
    var sessionHasExpired = (await dbProvider.getExpiryWarning(session.id))
        .any((e) => e.cancelled != true && e.expiry.isBefore(sessionEndTime));
    return sessionHasExpired;
  }
}