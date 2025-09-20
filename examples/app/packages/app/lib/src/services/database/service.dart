
import 'package:app/src/services/database/demo.dart';
import 'package:app/src/services/database/sql.dart';

abstract class DatabaseService {
  const DatabaseService();

  factory DatabaseService.demo() => DemoDatabaseService();

  static Future<DatabaseService> sql() => SqlDatabaseService.create();

  AnalyticsTable get analytics;
}

class FetchResult<T> {
  const FetchResult(this.offset, this.items, this.total);
  final int offset;
  final List<T> items;
  final int total;
}

class AnalyticsEntry {
  const AnalyticsEntry({
    required this.id,
    required this.name,
    required this.timestamp,
    this.arguments = const {},
  });

  final int id;
  final String name;
  final DateTime timestamp;
  final Map<String, String> arguments;
}

// An example table interface to store analytics entries.
abstract class AnalyticsTable {
  const AnalyticsTable();

  Future<AnalyticsEntry> insert({
    required String name,
    Map<String, String> arguments = const {},
  });

  Future<FetchResult<AnalyticsEntry>> getAll({int? skip, int? take});

  Future<int> count(String name);
}
