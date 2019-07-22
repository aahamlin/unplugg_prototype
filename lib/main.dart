import 'dart:async';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:unplugg_prototype/provider_setup.dart';
import 'package:unplugg_prototype/router.dart';

//import 'package:unplugg_prototype/data/blocs/bloc_provider.dart';
//import 'package:unplugg_prototype/data/blocs/event_bloc.dart';

import 'package:unplugg_prototype/data/models/event.dart';

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
          ),
          onGenerateRoute: Router.generateRoute,
        ),
    );
  }
}

