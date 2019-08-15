
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/*class SessionNotificationDetails {
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
}*/

class NotificationManager {

  factory NotificationManager() => _instance;

  static const MOMENTS_EXPIRING_ID = 0;
  static const MOMENTS_EXPIRING_INTERRUPT_ID = 1;
  static const MOMENTS_EXPIRING_FAILED_ID = 2;
  static const MOMENTS_EARNED_ID = 3;

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
      Duration expiry,
      Duration notify) async {
    print('Schedule moments expiring notification');
    var scheduledTime = DateTime.now().add(notify);
    var remainingExpiry = expiry - notify;

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'unplugg_prototype_channel_id', 'unplugg_prototype_channel',
        'Unplugg Prototype Notifications',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
      MOMENTS_EXPIRING_ID,
      'Unplugg Expiration Warning',
      'Your session will expire in ${remainingExpiry.inSeconds} seconds.',
      scheduledTime,
      platformChannelSpecifics,
      //payload: jsonEncode(sessionNotificationDetails.toJson()),
    );
  }

  Future<void> cancelMomentsExpiringNotification() async {
    print('Cancel moments expiring notification');
    await flutterLocalNotificationsPlugin.cancel(MOMENTS_EXPIRING_ID);
  }

  Future<void> showSessionInterruptNotification() async {
    var scheduledTime = DateTime.now().add(Duration(seconds: 1));
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'unplugg_prototype_channel_id', 'unplugg_prototype_channel',
        'Unplugg Prototype Notifications',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
      MOMENTS_EXPIRING_INTERRUPT_ID,
      'Unplugg Session Warning',
      'Did you get distracted? Interrupting your session once more will terminate it.',
      scheduledTime,
      platformChannelSpecifics,
      //payload: jsonEncode(sessionNotificationDetails.toJson()),
    );
  }
  Future<void> showSessionFailedNotification() async {
    var scheduledTime = DateTime.now().add(Duration(seconds: 1));
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'unplugg_prototype_channel_id', 'unplugg_prototype_channel',
        'Unplugg Prototype Notifications',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
      MOMENTS_EXPIRING_FAILED_ID,
      'Unplugg Session Failed',
      'You interrupted your session.',
      scheduledTime,
      platformChannelSpecifics,
      //payload: jsonEncode(sessionNotificationDetails.toJson()),
    );
  }

  Future<void> showMomentsEarnedNotification() async {
    // todo: implement moments earned notification
    throw UnimplementedError();
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> onSelectNotification(String payload) async {
   // todo: Scan for running session or provide session id in payload?
    debugPrint('User tapped selection');
  }

  Future<void> onDidReceiveLocalNotification(int id, String title, String body,
      String payload) async {
    print('iOS local notification: ' + payload);
    //var details = SessionNotificationDetails.fromJson(jsonDecode(payload));
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
                      //arguments: SessionModel(id: details.sessionId)
                  );
                },
              )
            ],
          ),
    );
  }
}