
const String columnId = "id";

const String tableSession = "session";
const String columnDuration = "duration";
const String columnStart = "start";
const String columnInterruptCount = "interrupts";
const String columnResult = "result";
const String columnReason = "reason";

const String createSessionTableSQL = '''
CREATE TABLE $tableSession (
    $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
    $columnDuration INTEGER NOT NULL,
    $columnStart INTEGER,
    $columnInterruptCount INTEGER DEFAULT(0),
    $columnResult TEXT,
    $columnReason TEXT
);
''';

const String tableInterrupts = "interrupts";
const String columnSessionFK = "session_fk";
const String columnTimeout = "timeout";
const String columnCancelled = "cancelled";

const String createInterruptsTableSQL = '''
CREATE TABLE $tableInterrupts (
    $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
    $columnSessionFK INTEGER NOT NULL,
    $columnTimeout INTEGER,
    $columnCancelled INTEGER NOT NULL DEFAULT(0),
    FOREIGN KEY($columnSessionFK)
    REFERENCES $tableSession($columnId)
);
''';

const String tableLogs = 'logs';
const String columnLevel = 'level';
const String columnTimestamp = 'time';
const String columnMessage = 'msg';
const String columnError = 'error';

const String createLogsTableSQL = '''
CREATE TABLE $tableLogs (
    $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
    $columnLevel INTEGER NOT NULL,
    $columnTimestamp INTEGER NOT NULL,
    $columnMessage TEXT NOT NULL,
    $columnError TEXT
);
''';