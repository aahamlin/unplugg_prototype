import 'package:flutter/material.dart';
import 'package:unplugg_prototype/screens/home.dart';
import 'package:unplugg_prototype/screens/session.dart';
import 'package:unplugg_prototype/screens/not_found.dart';

class RouteNames {
  static const HOME = '/';
  static const SESSION = '/session';
}

class Router {

  static String _initialRoute = RouteNames.HOME;

  static String get initialRoute => _initialRoute;

  static void set initialRoute(String routeName) {
    _initialRoute = routeName;
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch(settings.name) {
      case RouteNames.HOME:
        return MaterialPageRoute(builder: (context) => HomePage());
      case RouteNames.SESSION:
        var duration = settings.arguments as Duration;
        return MaterialPageRoute(builder: (context) => SessionPage(duration: duration));
      default:
        String unknownRoute = settings.name;
        return new MaterialPageRoute(builder: (context) => NotFoundPage(name: unknownRoute));
    }
  }
}