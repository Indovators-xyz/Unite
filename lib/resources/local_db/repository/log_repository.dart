import 'package:meta/meta.dart';
import 'package:adios_unite/models/log.dart';
import 'package:adios_unite/resources/local_db/db/hive_methods.dart';

class LogRepository {
  static var dbObject;
  static init({@required String dbName}) {
    dbObject = HiveMethods();
    dbObject.openDb(dbName);
    dbObject.init();
  }

  static addLogs(Log log) => dbObject.addLogs(log);

  static deleteLogs(int logId) => dbObject.deleteLogs(logId);

  static getLogs() => dbObject.getLogs();

  static close() => dbObject.close();
}