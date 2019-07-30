import 'package:provider/provider.dart';
import 'package:unplugg_prototype/data/database.dart';

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

];

List<SingleChildCloneableWidget> _uiConsumableProviders = [];

