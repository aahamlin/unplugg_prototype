import 'dart:async';
import 'dart:ui';

import 'package:async/async.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:unplugg_prototype/core/data/database.dart';
import 'package:unplugg_prototype/core/bloc/session_state_bloc.dart';
import 'package:unplugg_prototype/viewmodel/session_viewmodel.dart';
import 'package:unplugg_prototype/core/data/models/session.dart';
import 'package:unplugg_prototype/core/services/notifications.dart';


void main() {

  SessionStateBloc sessionStateBloc;
  DBProvider dbProvider;

  setUp(() {
    DBProvider.instance = MockDBProvider();
    dbProvider = DBProvider();
    sessionStateBloc = SessionStateBloc(dbProvider: dbProvider);
  });

  group('fresh sessions', () {

    setUp(() {
      when(dbProvider.getCurrentSession())
        .thenAnswer((_) => Future.value(null));
    });

    test('start session', () async {
      final StreamQueue<SessionViewModel> queue =
        StreamQueue<SessionViewModel>(sessionStateBloc.stream);

      when(dbProvider.beginSession(any))
      .thenAnswer((_) => Future.value(Session(duration: Duration(seconds:15), startTime: DateTime.now())));
      sessionStateBloc.start(duration: Duration(seconds: 15));
      expect(await queue.next,
          predicate((SessionViewModel vm) => vm.state == SessionViewState.running));
      verify(dbProvider.beginSession(any)).called(1);

    });


    test('cancel session, if running', () async {
      final StreamQueue<SessionViewModel> queue =
        StreamQueue<SessionViewModel>(sessionStateBloc.stream);

      var runningSessionViewModel = SessionViewModel(
          id: 1,
          state: SessionViewState.running);

      sessionStateBloc.cancel(runningSessionViewModel);

      expect(await queue.next,
          predicate((SessionViewModel vm) => vm.state == SessionViewState.cancelled));
      verify(dbProvider.endSession(any)).called(1);
    });

    test('complete session, successfull', () async {
      final StreamQueue<SessionViewModel> queue =
        StreamQueue<SessionViewModel>(sessionStateBloc.stream);

      var runningSessionViewModel = SessionViewModel(
          id: 1,
          state: SessionViewState.running);

      when(dbProvider.isSessionInterrupted(any))
        .thenAnswer((_) => Future.value(false));

      sessionStateBloc.complete(runningSessionViewModel);

      expect(await queue.next,
          predicate((SessionViewModel vm) => vm.state == SessionViewState.succeeded));
      verify(dbProvider.endSession(any)).called(1);
    });

    test('complete session, interrupted', () async {
      final StreamQueue<SessionViewModel> queue =
      StreamQueue<SessionViewModel>(sessionStateBloc.stream);

      var runningSessionViewModel = SessionViewModel(
          id: 1,
          state: SessionViewState.running);

      when(dbProvider.isSessionInterrupted(any))
          .thenAnswer((_) => Future.value(true));

      sessionStateBloc.complete(runningSessionViewModel);

      expect(await queue.next,
          predicate((SessionViewModel vm) => vm.state == SessionViewState.failed));
      verify(dbProvider.endSession(any)).called(1);
    });

    test('fail session', () async {
      final StreamQueue<SessionViewModel> queue =
        StreamQueue<SessionViewModel>(sessionStateBloc.stream);

      var runningSessionViewModel = SessionViewModel(
          id: 1,
          state: SessionViewState.running);

      sessionStateBloc.fail(runningSessionViewModel);

      expect(await queue.next,
          predicate((SessionViewModel vm) => vm.state == SessionViewState.failed));
      verify(dbProvider.endSession(any)).called(1);
    });
  });

  group('interrupted sessions', ()
  {
    setUp(() {
      NotificationManager.instance = MockNotificationManager();
    });

    test('interrupt displays 1st warning', () async {
      throw 'Not implemented';
    });


    test('interrupt fails on 2nd warning', () async {
      throw 'Not implemented';
    });

    test('resume session before end', () async {
      final StreamQueue<SessionViewModel> queue =
        StreamQueue<SessionViewModel>(sessionStateBloc.stream);

      when(dbProvider.getCurrentSession())
          .thenAnswer((_) => Future.value(Session(
          id: 1, duration: Duration(seconds:15), startTime: DateTime.now())));

      sessionStateBloc.resume(SessionViewModel(id: 1, startTime: null, duration: null, state: SessionViewState.running));

      verify(dbProvider.cancelInterrupt(argThat(predicate((e)=>e.id==1)))).called(1);
      expect(await queue.next,
          predicate((SessionViewModel vm) => vm.state == SessionViewState.running));
    });

    test('resume session after end', () async {
      final StreamQueue<SessionViewModel> queue =
        StreamQueue<SessionViewModel>(sessionStateBloc.stream);

      when(dbProvider.getCurrentSession())
          .thenAnswer((_) => Future.value(Session(
          id: 1, duration: Duration(seconds:15), startTime: DateTime.now().subtract(Duration(seconds: 20)))));

      when(dbProvider.isSessionInterrupted(any))
          .thenAnswer((_) => Future.value(false));

      sessionStateBloc.resume(SessionViewModel(id: 1, startTime: null, duration: null, state: SessionViewState.running));
      verify(dbProvider.cancelInterrupt(argThat(predicate((e)=>e.id==1)))).called(1);
      expect(await queue.next,
          predicate((SessionViewModel vm) => vm.state == SessionViewState.succeeded));
    });

    test('resume session interrupted', () async {
      final StreamQueue<SessionViewModel> queue =
        StreamQueue<SessionViewModel>(sessionStateBloc.stream);

      when(dbProvider.getCurrentSession())
          .thenAnswer((_) => Future.value(Session(
          id: 1, duration: Duration(seconds:15), startTime: DateTime.now().subtract(Duration(seconds: 20)))));

      when(dbProvider.isSessionInterrupted(any))
          .thenAnswer((_) => Future.value(true));


      sessionStateBloc.resume(SessionViewModel(id: 1, startTime: null, duration: null, state: SessionViewState.running));
      verify(dbProvider.cancelInterrupt(argThat(predicate((e)=>e.id==1)))).called(1);
      expect(await queue.next,
          predicate((SessionViewModel vm) => vm.state == SessionViewState.failed));
    });
  });
}

class MockDBProvider extends Mock implements DBProvider {}
class MockNotificationManager extends Mock implements NotificationManager {}