import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:logger_flutter/logger_flutter.dart';
//import 'package:unplugg_prototype/blocs/session_state_bloc.dart';
import 'package:unplugg_prototype/core/data/database.dart';
import 'package:unplugg_prototype/core/data/models/log_entry.dart';

class LogsTab extends StatelessWidget {

  LogsTab({Key key}) : super(key: key) {
    LogConsole.init();
  }

  @override
  Widget build(BuildContext context) {
    return LogConsole();
  }
}
