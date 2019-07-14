import 'package:flutter/material.dart';

import 'package:unplugg_prototype/pages/home.dart';
import 'package:unplugg_prototype/pages/session.dart';
import 'package:unplugg_prototype/pages/not_found.dart';

import 'package:unplugg_prototype/data/blocs/bloc_provider.dart';
import 'package:unplugg_prototype/data/blocs/event_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Unplugg Prototype',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: HomePage(title: 'Unplugg'),
        onGenerateRoute: (RouteSettings settings) {
          switch(settings.name) {
            case '/':
              return MaterialPageRoute(builder: (context) => HomePage(title: 'Unplugg'));
            case '/session':
              return MaterialPageRoute(builder: (context) => SessionPage());
          }
        },
        onUnknownRoute: (RouteSettings settings) {
          String unknownRoute = settings.name;
          return new MaterialPageRoute(builder: (context) => NotFoundPage(name: unknownRoute));
      },
    );
  }
}

