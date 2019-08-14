
const String columnId = "id";

const String tableSession = "session";
const String columnDuration = "duration";
const String columnStart = "start";
const String columnResult = "result";
const String columnReason = "reason";

const String createSessionTableSQL = '''
CREATE TABLE $tableSession (
    $columnId integer primary key autoincrement,
    $columnDuration integer not null,
    $columnStart integer,
    $columnResult text,
    $columnReason text);
''';

const String tableRunExpiry = "runexpiry";
const String columnSessionFK = "session_fk";
const String columnExpiry = "expiry";
const String columnCancelled = "cancelled";

const String createRunTableSQL = '''
CREATE TABLE $tableRunExpiry (
    $columnId integer primary key autoincrement,
    $columnSessionFK integer not null,
    $columnExpiry integer,
    $columnCancelled integer not null default(0),
    FOREIGN KEY($columnSessionFK)
    REFERENCES $tableSession($columnId));
''';
