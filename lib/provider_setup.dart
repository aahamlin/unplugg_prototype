import 'package:provider/provider.dart';
import 'package:unplugg_prototype/core/data/database.dart';
import 'package:unplugg_prototype/core/bloc/session_state_bloc.dart';

List<SingleChildCloneableWidget> providers = [
  ..._independentServices,
  ..._dependentServices,
  ..._uiConsumableProviders,
];


List<SingleChildCloneableWidget> _independentServices = [
  Provider<SessionStateBloc>.value(value: SessionStateBloc()),
];

List<SingleChildCloneableWidget> _dependentServices = [];

List<SingleChildCloneableWidget> _uiConsumableProviders = [];

