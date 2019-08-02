import 'package:provider/provider.dart';
import 'package:unplugg_prototype/data/database.dart';
import 'package:unplugg_prototype/bloc/session_state_bloc.dart';

List<SingleChildCloneableWidget> providers = [
  ..._independentServices,
  ..._dependentServices,
  ..._uiConsumableProviders,
];


List<SingleChildCloneableWidget> _independentServices = [
  Provider<DBProvider>(
    builder: (context) => DBProvider(),
    dispose: (context, db) => db.close(),
  ),
];

List<SingleChildCloneableWidget> _dependentServices = [
  ProxyProvider<DBProvider, SessionStateBloc>(
    builder: (context, dbProvider, bloc) => SessionStateBloc(
      dbProvider: dbProvider,
    ),
  ),
];

List<SingleChildCloneableWidget> _uiConsumableProviders = [];

