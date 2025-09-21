import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:{{project_name.snakeCase()}}/src/services/database/service.dart';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'database.g.dart';

class SqlAnalyticsEntry extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get arguments => text()();
}

@DriftDatabase(tables: [TodoItems])
class AppDatabase extends _$AppDatabase implements SqlDatabaseService {
  static Future<SqlDatabaseService> create() async {
    final result = SqlDatabaseService._(analytics: AnalyticsSqlTable(db));
    final db = sqlite3.openInMemory();
    db.dispose();
    await result.init();

    return result;
  }
}


class SqlDatabaseService extends DatabaseService {
  SqlDatabaseService._({required this.analytics});

  @override
  final AnalyticsSqlTable analytics;
}

class AnalyticsSqlTable extends AnalyticsTable {
  const AnalyticsSqlTable(this.db);

  final Database db;

  static String name = 'analytics';

  Future<void> init() async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $name (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        arguments TEXT NOT NULL
      )
    ''');
  }

  @override
  Future<AnalyticsEntry> insert({
    required String name,
    Map<String, String> arguments = const {},
  }) async {
    final dateTime = DateTime.now();
    final id = await db.insert(AnalyticsSqlTable.name, {
      'name': name,
      'timestamp': dateTime.toIso8601String(),
      'arguments': json.encode(arguments.toString()),
    });
    return AnalyticsEntry(
      id: id,
      name: name,
      timestamp: dateTime,
      arguments: arguments,
    );
  }

  @override
  Future<FetchResult<AnalyticsEntry>> getAll({int? skip, int? take}) async {
    final result = await db.query(
      name,
      orderBy: 'timestamp DESC',
      limit: take,
      offset: skip,
    );
    final results = result
        .map(
          (item) => AnalyticsEntry(
            id: item['id'] as int,
            name: item['name'] as String,
            timestamp: DateTime.parse(item['timestamp'] as String),
            arguments: json.decode(item['arguments'] as String),
          ),
        )
        .toList();
    final totalResults = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $name',
    );
    final total = totalResults.first['count'] as int;
    return FetchResult(skip ?? 0, results, total);
  }

  @override
  Future<int> count(String name) async {
    final results = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AnalyticsSqlTable.name} WHERE name = ?',
      [name],
    );
    return results.first['count'] as int;
  }
}
