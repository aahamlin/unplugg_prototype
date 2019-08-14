import 'package:flutter/material.dart';
import 'package:unplugg_prototype/ui/screens/home.dart';
import 'package:unplugg_prototype/ui/screens/session.dart';
import 'package:unplugg_prototype/ui/screens/complete.dart';
import 'package:unplugg_prototype/ui/screens/incomplete.dart';

import 'package:unplugg_prototype/ui/screens/not_found.dart';

class RouteNames {
  static const HOME = '/';
  static const SESSION = '/session';
  static const COMPLETE = '/complete';
  static const INCOMPLETE = '/incomplete';
}

class Router {

  static String _initialRoute = RouteNames.HOME;

  static String get initialRoute => _initialRoute;

  static void set initialRoute(String routeName) {
    _initialRoute = routeName;
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    var vm = settings.arguments;
    switch(settings.name) {
      case RouteNames.HOME:
        return MaterialPageRoute(builder: (context) => HomeScreen());
      case RouteNames.SESSION:
        return MaterialPageRoute(builder: (context) => SessionScreen(vm: vm));
      case RouteNames.COMPLETE:
        return MaterialPageRoute(builder: (context) => CompleteScreen(vm: vm));
      case RouteNames.INCOMPLETE:
        return MaterialPageRoute(builder: (context) => IncompleteScreen(vm: vm));
      default:
        String unknownRoute = settings.name;
        return new MaterialPageRoute(builder: (context) => NotFoundPage(name: unknownRoute));
    }
  }
}