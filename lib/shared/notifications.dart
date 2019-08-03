import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:unplugg_prototype/bloc/session_state_bloc.dart';
import 'package:unplugg_prototype/shared/timer_formatter.dart';

class SessionNotificationDetails {
  int sessionId;
  DateTime expiry;

  SessionNotificationDetails.fromJson(Map<String, dynamic> map)
    : sessionId = map['session_id'],
      expiry = DateTime.fromMillisecondsSinceEpoch(map['expiry']);

  SessionNotificationDetails({this.sessionId, this.expiry});

  Map<String, dynamic> toJson() =>
      {
        'session_id': sessionId,
        'expiry': expiry.millisecondsSinceEpoch,
      };
}

class NotificationManager {

  factory NotificationManager() => _instance;

  static const MOMENTS_EXPIRING_ID = 0;
  static const MOMENTS_EARNED_ID = 1;

  static final NotificationManager _instance = NotificationManager.private();

  NotificationManager.private();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void configureLocalNotifications() {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  getNotificationAppLaunchDetails() {
    return flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  }

  Future<void> showMomentsExpiringNotification(
      SessionNotificationDetails sessionNotificationDetails,
      DateTime scheduledTime) async {
    var notificationId = MOMENTS_EXPIRING_ID;

    var expiry = sessionNotificationDetails.expiry;

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'unplugg_prototype_channel_id', 'unplugg_prototype_channel',
        'Unplugg Prototype Notifications',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
      notificationId,
      'Unplugg Expiration Warning',
      'Your session will expire at ${expiry.toString()}.',
      scheduledTime,
      platformChannelSpecifics,
      payload: jsonEncode(sessionNotificationDetails.toJson()),
    );
  }

  Future<void> cancelMomentsExpiringNotification() async {
    await flutterLocalNotificationsPlugin.cancel(MOMENTS_EXPIRING_ID);
  }


  Future<void> showMomentsEarnedNotification() async {
    // todo: implement
    throw UnimplementedError();
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> onSelectNotification(String payload) async {
    var details = SessionNotificationDetails.fromJson(jsonDecode(payload));

    await Navigator.pushNamed(
        null,
        '/session',
        arguments: SessionModel(id: details.sessionId)
    );
  }

  Future<void> onDidReceiveLocalNotification(int id, String title, String body,
      String payload) async {
    print('iOS local notification: ' + payload);
    var details = SessionNotificationDetails.fromJson(jsonDecode(payload));
    // display a dialog with the notification details, tap ok to go to another page
    await showDialog(
      context: null,
      builder: (BuildContext context) =>
          CupertinoAlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Ok'),
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                  await Navigator.pushNamed(
                      context,
                      '/session',
                      arguments: SessionModel(id: details.sessionId)
                  );
                },
              )
            ],
          ),
    );
  }
}