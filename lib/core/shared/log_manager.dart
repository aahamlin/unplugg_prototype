import 'package:logger/logger.dart';

import 'package:unplugg_prototype/core/data/database.dart';
import 'package:unplugg_prototype/core/data/models/log_entry.dart';


export 'package:logger/logger.dart';

class LogManager {

  static final Map<String, Logger> _cache = {};

  static Logger getLogger(String name) {

    if (_cache.containsKey(name)) {
      return _cache[name];
    }
    else {
      final logger = Logger(
        printer: NamedPrinter(name),
      );
      _cache[name] = logger;
      return logger;
    }

  }
}

final _logLevelStr = {
  Level.verbose: 'VERBOSE',
  Level.debug: 'DEBUG',
  Level.info: 'INFO',
  Level.warning: 'WARN',
  Level.error: 'ERROR',
  Level.wtf: 'WTF',
};

class NamedPrinter extends LogPrinter {
  final String name;
//  final _dbMgr = DBProvider();

  NamedPrinter(this.name);

  @override
  void log(LogEvent event) {
    var timeStamp = DateTime.now();
    var msg = '$name ${event.message}';
    println('${timeStamp.toLocal().toIso8601String()} [${_logLevelStr[event.level]}] $msg');
    /*_dbMgr.addLogEntry(LogEntry(
      level: event.level,
      message: msg,
      timeStamp: timeStamp,
      error: event.error
    ));*/
  }

}
