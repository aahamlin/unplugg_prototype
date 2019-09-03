import 'package:logger/logger.dart';

// todo rewrite logger implementation using static Logger.addOutputListener for DB calls
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
  NamedPrinter(this.name);

  @override
  void log(LogEvent event) {
    var timeStamp = DateTime.now();
    var msg = '$name|${event.message}';
    var time = '${timeStamp.hour}:${timeStamp.minute}:${timeStamp.second}.${timeStamp.millisecond}';
    println('$time [${_logLevelStr[event.level]}] $msg');
  }

}
