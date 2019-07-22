import 'dart:async';
import 'package:provider/provider.dart';

import 'package:unplugg_prototype/data/database.dart';

import 'package:unplugg_prototype/data/models/event.dart';
import 'package:unplugg_prototype/data/blocs/event_bloc.dart';

List<SingleChildCloneableWidget> providers = [
  ..._independentServices,
  ..._dependentServices,
  ..._uiConsumableProviders,
];


List<SingleChildCloneableWidget> _independentServices = [

  Provider.value(value: DBProvider.db),

  //StreamProvider<List<Event>>.controller(builder: (_) => StreamController<List<Event>>()),


];

List<SingleChildCloneableWidget> _dependentServices = [
  ProxyProvider<DBProvider, EventBloc>(
    builder: (context, db, _) => EventBloc(db),
  )
];

List<SingleChildCloneableWidget> _uiConsumableProviders = [];

