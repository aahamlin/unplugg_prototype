import 'dart:async';

import 'package:async/async.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:unplugg_prototype/core/data/database.dart';
import 'package:unplugg_prototype/core/bloc/session_state_bloc.dart';
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
      final StreamQueue<Session> queue =
        StreamQueue<Session>(sessionStateBloc.stream);

      sessionStateBloc.start(duration: Duration(seconds: 15));
      expect(await queue.next,
          predicate((Session vm) => vm.result == SessionResult.none));
      verify(dbProvider.beginSession(any)).called(1);

    });


    test('cancel session, if running', () async {
      final StreamQueue<Session> queue =
        StreamQueue<Session>(sessionStateBloc.stream);

      sessionStateBloc.cancel(session);

      expect(await queue.next,
          predicate((Session vm) => vm.result == SessionResult.cancelled));
      verify(dbProvider.endSession(captureThat(isA<Session>()))).called(1);
    });

    test('complete session, successfull', () async {
      final StreamQueue<Session> queue =
        StreamQueue<Session>(sessionStateBloc.stream);

      sessionStateBloc.complete(session);

      expect(await queue.next,
          predicate((Session vm) => vm.result == SessionResult.success));
      verify(dbProvider.endSession(any)).called(1);
    });

    test('fail session', () async {
      final StreamQueue<Session> queue =
        StreamQueue<Session>(sessionStateBloc.stream);

      sessionStateBloc.fail(session);

      expect(await queue.next,
          predicate((Session vm) => vm.result == SessionResult.failure));
      verify(dbProvider.endSession(any)).called(1);

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
      final StreamQueue<Session> queue =
        StreamQueue<Session>(sessionStateBloc.stream);

      await sessionStateBloc.resume(session);

      verify(dbProvider.cancelAllInterrupts(argThat(predicate((id)=>id==1)))).called(1);
      expect(await queue.next,
          predicate((Session vm) => vm.result == SessionResult.none));
    });


    test('resumed session fails', () async {
      final StreamQueue<Session> queue =
        StreamQueue<Session>(sessionStateBloc.stream);

      when(dbProvider.isSessionInterrupted(any))
          .thenAnswer((_) => Future.value(true));

      await sessionStateBloc.resume(session);

      expect(await queue.next,
          predicate((Session vm) => vm.result == SessionResult.failure));
      verifyNever(dbProvider.cancelAllInterrupts(any));

    });
  });
}

class MockDBProvider extends Mock implements DBProvider {}
class MockNotificationManager extends Mock implements NotificationManager {}