import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unplugg_prototype/provider_setup.dart';
import 'package:unplugg_prototype/router.dart';
import 'package:unplugg_prototype/shared/notifications.dart';

void main() async {

  var notificationManager = NotificationManager();
  notificationManager.configureLocalNotifications();

  var notificationAppLaunchDetails =
    await notificationManager.getNotificationAppLaunchDetails();

  if(notificationAppLaunchDetails.didNotificationLaunchApp) {
//    var details = SessionNotificationDetails.fromJson(
//        jsonDecode(notificationAppLaunchDetails.payload));

    Router.initialRoute = RouteNames.SESSION;
  }

  runApp(MyApp());

}
class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child:
        MaterialApp(
          title: 'Unplugg Prototype',
          theme: ThemeData(
            primarySwatch: Colors.green,
            fontFamily: 'Barista'
          ),
          initialRoute: Router.initialRoute,
          onGenerateRoute: Router.generateRoute,
        ),
    );
  }
}

