import 'dart:async';
import 'package:provider/provider.dart';

import 'package:unplugg_prototype/data/database.dart';
import 'package:unplugg_prototype/blocs/event_bloc.dart';
import 'package:unplugg_prototype/blocs/session_bloc.dart';

List<SingleChildCloneableWidget> providers = [
  ..._independentServices,
  ..._dependentServices,
  ..._uiConsumableProviders,
];


List<SingleChildCloneableWidget> _independentServices = [
  Provider.value(value: DBProvider.db),
];

List<SingleChildCloneableWidget> _dependentServices = [
  ProxyProvider<DBProvider, EventBloc>(
    builder: (context, db, _) => EventBloc(db),
  ),
  ProxyProvider<DBProvider, SessionBloc>(
    builder: (context, db, _) => SessionBloc(db),
  )
];

List<SingleChildCloneableWidget> _uiConsumableProviders = [];

