import 'package:provider/provider.dart';
import 'package:unplugg_prototype/data/database.dart';
import 'package:unplugg_prototype/blocs/session_bloc.dart';

List<SingleChildCloneableWidget> providers = [
  ..._independentServices,
  ..._dependentServices,
  ..._uiConsumableProviders,
];


List<SingleChildCloneableWidget> _independentServices = [
  Provider<DBProvider>(
    builder: (context) => DBProvider(),
    dispose: (context, db) => db.close(),
  )
];

List<SingleChildCloneableWidget> _dependentServices = [
  ProxyProvider<DBProvider, SessionBloc>(
    builder: (context, db, _) => SessionBloc(db),
    dispose: (context, bloc) => bloc.dispose(),
  )
];

List<SingleChildCloneableWidget> _uiConsumableProviders = [];

