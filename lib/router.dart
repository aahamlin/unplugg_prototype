import 'package:flutter/material.dart';
import 'package:unplugg_prototype/screens/home.dart';
import 'package:unplugg_prototype/screens/session.dart';
import 'package:unplugg_prototype/screens/not_found.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch(settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => HomePage());
      case '/session':
        return MaterialPageRoute(builder: (context) => SessionPage());
      default:
        String unknownRoute = settings.name;
        return new MaterialPageRoute(builder: (context) => NotFoundPage(name: unknownRoute));
    }
  }
}