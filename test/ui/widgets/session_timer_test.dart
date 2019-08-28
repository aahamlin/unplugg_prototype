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
import 'package:unplugg_prototype/core/services/phone_event/phone_event_service.dart';

//import 'package:unplugg_prototype/main.dart';
import 'package:unplugg_prototype/ui/widgets/session_timer.dart';
import 'package:unplugg_prototype/ui/widgets/timer_text.dart';

void main() {
  testWidgets('SessionTimer displays TimerText', (WidgetTester tester) async {
    await tester.pumpWidget(
        Directionality(
            textDirection: TextDirection.ltr,
            child: SessionTimer(
                duration: Duration(seconds: 1),
//                onInterrupt: (event) => null,
                onComplete: () => null))
    );

    // use tester.pump() or tester.pumpAndSettle() to force rebuild

    final sessionTimerFinder = find.byType(TimerText);

    expect(sessionTimerFinder, findsOneWidget);
  });


}