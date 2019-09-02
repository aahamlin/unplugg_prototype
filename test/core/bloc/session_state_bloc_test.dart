import 'dart:async';
import 'dart:ui';

import 'package:async/async.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:unplugg_prototype/core/data/database.dart';
import 'package:unplugg_prototype/core/bloc/session_state_bloc.dart';
import 'package:unplugg_prototype/viewmodel/session_state_viewmodel.dart';
import 'package:unplugg_prototype/core/data/models/session.dart';
import 'package:unplugg_prototype/core/services/notifications.dart';


void main() {

  SessionStateBloc sessionStateBloc;
  DBProvider dbProvider;

  Session session;

  setUp(() {
    DBProvider.instance = MockDBProvider();
    dbProvider = DBProvider();

    session = Session(
      id: 1,
      startTime: DateTime.now(),
      duration: Duration(seconds: 30));

    // stub sessions behavior
    when(dbProvider.getOrphanedSessions())
      .thenAnswer((_) => Future.value([]));

    when(dbProvider.beginSession(any))
      .thenAnswer((_) => Future.value(session));

    when(dbProvider.getSessionInterrupts(any))
      .thenAnswer((_) => Future.value([]));

    when(dbProvider.getSession(any))
      .thenAnswer((_) => Future.value(session));

    when(dbProvider.isSessionInterrupted(any))
      .thenAnswer((_) => Future.value(false));

    sessionStateBloc = SessionStateBloc(dbProvider: dbProvider);
  });

  group('fresh sessions', () {


    test('start session', () async {
      final StreamQueue<SessionStateViewModel> queue =
        StreamQueue<SessionStateViewModel>(sessionStateBloc.stream);

      sessionStateBloc.start(duration: Duration(seconds: 15));
      expect(await queue.next,
          predicate((SessionStateViewModel vm) => vm.state == SessionState.running));
      verify(dbProvider.beginSession(any)).called(1);

    });


    test('cancel session, if running', () async {
      final StreamQueue<SessionStateViewModel> queue =
        StreamQueue<SessionStateViewModel>(sessionStateBloc.stream);

      sessionStateBloc.cancel(session);

      expect(await queue.next,
          predicate((SessionStateViewModel vm) => vm.state == SessionState.failed));
      //verify(dbProvider.endSession(captureThat(isA<Session>()))).called(1);
      expect(verify(dbProvider.endSession(captureThat(isA<Session>()))).captured.single,
          predicate((session) => session.result == SessionResult.failure));
    });

    test('complete session, successfull', () async {
      final StreamQueue<SessionStateViewModel> queue =
        StreamQueue<SessionStateViewModel>(sessionStateBloc.stream);

      sessionStateBloc.complete(session);

      expect(await queue.next,
          predicate((SessionStateViewModel vm) => vm.state == SessionState.succeeded));
//      verify(dbProvider.endSession(any)).called(1);
      expect(verify(dbProvider.endSession(captureThat(isA<Session>()))).captured.single,
          predicate((session) => session.result == SessionResult.success));
    });

    test('fail session', () async {
      final StreamQueue<SessionStateViewModel> queue =
        StreamQueue<SessionStateViewModel>(sessionStateBloc.stream);

      sessionStateBloc.fail(session);

      expect(await queue.next,
          predicate((SessionStateViewModel vm) => vm.state == SessionState.failed));
//      verify(dbProvider.endSession(any)).called(1);
      expect(verify(dbProvider.endSession(captureThat(isA<Session>()))).captured.single,
          predicate((session) => session.result == SessionResult.failure));

    });
  });

  group('interrupted sessions', ()
  {
    setUp(() {
      NotificationManager.instance = MockNotificationManager();
    });

    test('interrupt noop when not running', () async {
      throw 'Not implemented';
    });

    test('interrupt displays 1st warning', () async {
      throw 'Not implemented';
    });


    test('interrupt fails on 2nd warning', () async {
      throw 'Not implemented';
    });

    test('resume noop when not running', () async {
      throw 'Not implemented';
    });

    test('resumed session continues', () async {
      final StreamQueue<SessionStateViewModel> queue =
        StreamQueue<SessionStateViewModel>(sessionStateBloc.stream);

      await sessionStateBloc.resume(session);

      verify(dbProvider.cancelAllInterrupts(argThat(predicate((id)=>id==1)))).called(1);
      expect(await queue.next,
          predicate((SessionStateViewModel vm) => vm.state == SessionState.running));
    });


    test('resumed session fails', () async {
      final StreamQueue<SessionStateViewModel> queue =
        StreamQueue<SessionStateViewModel>(sessionStateBloc.stream);

      when(dbProvider.isSessionInterrupted(any))
          .thenAnswer((_) => Future.value(true));

      await sessionStateBloc.resume(session);

      expect(await queue.next,
          predicate((SessionStateViewModel vm) => vm.state == SessionState.failed));
      verifyNever(dbProvider.cancelAllInterrupts(any));

    });
  });
}

class MockDBProvider extends Mock implements DBProvider {}
class MockNotificationManager extends Mock implements NotificationManager {}