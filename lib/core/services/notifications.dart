
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:unplugg_prototype/core/shared/log_manager.dart';

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

  factory NotificationManager() {
    if(instance == null) {
      instance = NotificationManager._();
    }
    return instance;
  }

  static const MOMENTS_EXPIRING_ID = 0;
  static const MOMENTS_EXPIRING_INTERRUPT_ID = 1;
  static const MOMENTS_EXPIRING_FAILED_ID = 2;
  static const MOMENTS_EARNED_ID = 3;

  static NotificationManager instance;

  NotificationManager._() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final _logger = LogManager.getLogger('NotificationManager');

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

//  Future<void> showMomentsExpiringNotification(
//      Duration expiry,
//      Duration notify) async {
//    _logger.d('Schedule moments expiring notification');
//    var scheduledTime = DateTime.now().add(notify);
//    var remainingExpiry = expiry - notify;
//
//    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
//        'unplugg_prototype_channel_id', 'unplugg_prototype_channel',
//        'Unplugg Prototype Notifications',
//        importance: Importance.Max, priority: Priority.High);
//    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
//    var platformChannelSpecifics = new NotificationDetails(
//        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//    await flutterLocalNotificationsPlugin.schedule(
//      MOMENTS_EXPIRING_ID,
//      'Unplugg Expiration Warning',
//      'Your session will expire in ${remainingExpiry.inSeconds} seconds.',
//      scheduledTime,
//      platformChannelSpecifics,
//      //payload: jsonEncode(sessionNotificationDetails.toJson()),
//    );
//  }

//  Future<void> cancelMomentsExpiringNotification() async {
//    _logger.d('Cancel moments expiring notification');
//    var pending = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
//    if(pending.any((req) => req.id == MOMENTS_EXPIRING_ID)) {
//      await flutterLocalNotificationsPlugin.cancel(MOMENTS_EXPIRING_ID);
//    }
//  }

  Future<void> scheduleSessionInterruptNotification() async {
    _logger.d('Schedule session interrupted notification');

    var scheduledTime = DateTime.now().add(Duration(seconds: 2));
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
      'Did you get distracted? Return to Unplugg to continue maximizing your moments.',
      scheduledTime,
      platformChannelSpecifics,
      //payload: jsonEncode(sessionNotificationDetails.toJson()),
    );
  }

  Future<void> cancelSessionInterruptedNotification() async {
    _logger.d('Cancel session interrupted notification');
    var pending = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    if(pending.any((req) => req.id == MOMENTS_EXPIRING_INTERRUPT_ID)) {
      await flutterLocalNotificationsPlugin.cancel(
          MOMENTS_EXPIRING_INTERRUPT_ID);
    }
  }

  Future<void> showSessionFailedNotification() async {
    _logger.d('Schedule session failed notification');

//    var scheduledTime = DateTime.now().add(Duration(seconds: 2));
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'unplugg_prototype_channel_id', 'unplugg_prototype_channel',
        'Unplugg Prototype Notifications',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      MOMENTS_EXPIRING_FAILED_ID,
      'Unplugg Session Failed',
      'Sorry, you have left Unplugg too many times and have not met your goal.',
//      scheduledTime,
      platformChannelSpecifics,
      //payload: jsonEncode(sessionNotificationDetails.toJson()),
    );
  }

  Future<void> scheduleMomentsEarnedNotification(DateTime scheduledTime, int points) async {
    _logger.d('Schedule moments earned notification at $scheduledTime');

    final momentsEarned = 'Congratulations! You earned $points moments.';

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'unplugg_prototype_channel_id', 'unplugg_prototype_channel',
        'Unplugg Prototype Notifications',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
      MOMENTS_EARNED_ID,
      'Unplugg Moments Earned',
      momentsEarned,
      scheduledTime,
      platformChannelSpecifics,
      //payload: jsonEncode(sessionNotificationDetails.toJson()),
    );
  }

  Future<void> cancelMomentsEarnedNotification() async {
    _logger.d('Cancel moments earned notification');
    var pending = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    if(pending.any((req) => req.id == MOMENTS_EARNED_ID)) {
      await flutterLocalNotificationsPlugin.cancel(
          MOMENTS_EARNED_ID);
    }
  }

  Future<void> _cancelAllNotifications() async {
    _logger.d('Cancel all notifications');
    var pending = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    if(pending.isNotEmpty) {
      await flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  Future<void> onSelectNotification(String payload) async {
   // todo: Scan for running session or provide session id in payload?
    _logger.i('User tapped notification');
  }

  Future<void> onDidReceiveLocalNotification(int id, String title, String body,
      String payload) async {
    _logger.d('iOS local notification: $payload');
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