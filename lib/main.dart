import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:unplugg_prototype/provider_setup.dart';
import 'package:unplugg_prototype/router.dart';

void main() => runApp(MyApp());

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
          onGenerateRoute: Router.generateRoute,
        ),
    );
  }
}

