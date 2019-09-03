import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger_flutter/logger_flutter.dart';
import 'package:unplugg_prototype/core/shared/log_manager.dart';
import 'package:unplugg_prototype/core/data/database.dart';
import 'package:unplugg_prototype/provider_setup.dart';
import 'package:unplugg_prototype/router.dart';
import 'package:unplugg_prototype/core/services/notifications.dart';

void main() async {

  // todo initialize log output to DB
  var databaseProvider = DBProvider();
  LogConsole.init();

  var logger = LogManager.getLogger('main');

  var notificationManager = NotificationManager();
  notificationManager.configureLocalNotifications();
//  var notificationAppLaunchDetails =
//    await notificationManager.getNotificationAppLaunchDetails();

  logger.i('app starting');
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
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

