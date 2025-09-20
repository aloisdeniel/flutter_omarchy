import 'package:{{project_name.snakeCase()}}/src/services/database/service.dart';
import 'package:flutter/cupertino.dart';

class HomeNotifier extends ChangeNotifier {
  HomeNotifier({required this.db});

  final DatabaseService db;

  int? _appLaunchCount;
  int? get appLaunchCount => _appLaunchCount;

  void refresh() async {
    try {
      _appLaunchCount = await db.analytics.count('app_launch');
      notifyListeners();
    } catch (e) {
      // Something went wrong
      print(e);
    }
  }
}
