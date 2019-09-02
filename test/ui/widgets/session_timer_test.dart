// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:unplugg_prototype/core/bloc/session_state_bloc.dart';
import 'package:unplugg_prototype/core/data/models/session.dart';
import 'package:unplugg_prototype/core/services/phone_event/phone_event_service.dart';

//import 'package:unplugg_prototype/main.dart';
import 'package:unplugg_prototype/ui/widgets/session_timer.dart';
import 'package:unplugg_prototype/ui/widgets/timer_text.dart';

void main() {

  SessionStateBloc bloc;
  Session session;

  setUp(() {
    bloc = MockSessionStateBloc();
    session = Session(
      startTime: DateTime.now().subtract(Duration(seconds: 1)),
      duration: Duration(seconds:5));
  });

  testWidgets('SessionTimer displays TimerText', (WidgetTester tester) async {

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SessionTimer(session: session, bloc: bloc),
      ),
    );

    // use tester.pump() or tester.pumpAndSettle() to force rebuild
    final timerTextFinder = find.byType(TimerText);
    expect(timerTextFinder, findsOneWidget);
  });

  testWidgets('sessiontimer value', (WidgetTester tester) async {

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SessionTimer(session: session, bloc: bloc),
      ),
    );

    final sessionTimerFinder = find.byType(SessionTimer);
    expect(sessionTimerFinder, findsOneWidget);

  });

}

class MockSessionStateBloc extends Mock implements SessionStateBloc {}