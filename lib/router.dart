import 'package:flutter/material.dart';
import 'package:unplugg_prototype/pages/home.dart';
import 'package:unplugg_prototype/pages/session.dart';
import 'package:unplugg_prototype/pages/success.dart';
import 'package:unplugg_prototype/pages/not_found.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch(settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => HomePage());
      case '/session':
        Map<String, dynamic> config = settings.arguments;
        return MaterialPageRoute(builder: (context) => SessionPage(config: config));
//      case '/success':
//        return MaterialPageRoute(builder: (context) => SuccessPage());
      default:
        String unknownRoute = settings.name;
        return new MaterialPageRoute(builder: (context) => NotFoundPage(name: unknownRoute));
    }
  }
}