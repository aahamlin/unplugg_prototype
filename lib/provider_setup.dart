import 'package:provider/provider.dart';
import 'package:unplugg_prototype/core/data/database.dart';
import 'package:unplugg_prototype/core/bloc/session_state_bloc.dart';

List<SingleChildCloneableWidget> providers = [
  ..._independentServices,
  ..._dependentServices,
  ..._uiConsumableProviders,
];


List<SingleChildCloneableWidget> _independentServices = [
  Provider<DBManager>(
    builder: (context) => DBManager(),
    dispose: (context, db) => db.close(),
  ),
];

List<SingleChildCloneableWidget> _dependentServices = [
  ProxyProvider<DBManager, SessionStateBloc>(
    builder: (context, dbProvider, bloc) => SessionStateBloc(dbProvider: dbProvider),
  )
];

List<SingleChildCloneableWidget> _uiConsumableProviders = [];

