
import 'package:app/src/services/database/service.dart';

class DemoDatabaseService extends DatabaseService {
  DemoDatabaseService();

  @override
  final DemoAnalyticsTable analytics = DemoAnalyticsTable();
}

class DemoAnalyticsTable extends AnalyticsTable {
  DemoAnalyticsTable();

  final List<AnalyticsEntry> _entries = [];
  int _lastId = 0;

  @override
  Future<FetchResult<AnalyticsEntry>> getAll({int? skip, int? take}) async {
    final total = _entries.length;
    final offset = skip ?? 0;
    final items = _entries.skip(offset).take(take ?? total).toList();
    return FetchResult(offset, items, total);
  }

  @override
  Future<AnalyticsEntry> insert({
    required String name,
    Map<String, String> arguments = const {},
  }) {
    final result = AnalyticsEntry(
      id: _lastId++,
      name: name,
      timestamp: DateTime.now(),
      arguments: arguments,
    );
    _entries.add(result);
    return Future.value(result);
  }

  @override
  Future<int> count(String name) {
    final count = _entries.where((entry) => entry.name == name).length;
    return Future.value(count);
  }
}
