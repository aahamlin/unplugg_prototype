import 'package:flutter/material.dart';
import 'package:unplugg_prototype/pages/home.dart';
import 'package:unplugg_prototype/pages/session.dart';
import 'package:unplugg_prototype/pages/not_found.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch(settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => HomePage());
      case '/session':
        var session = settings.arguments;
        return MaterialPageRoute(builder: (context) => SessionPage(session: session));
      default:
        String unknownRoute = settings.name;
        return new MaterialPageRoute(builder: (context) => NotFoundPage(name: unknownRoute));
    }
  }
}