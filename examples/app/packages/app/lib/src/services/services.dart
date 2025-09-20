import 'dart:io';

import 'package:app/src/services/config/service.dart';
import 'package:app/src/services/database/service.dart';
import 'package:flutter/foundation.dart';

class Services {
  const Services({required this.config, required this.database});

  factory Services.demo() {
    return Services(
      config: ConfigService.demo(),
      database: DatabaseService.demo(),
    );
  }

  static Future<Services> fromPlatform() async {
    if (kIsWeb) {
      return Services.demo();
    }
    if (Platform.isLinux) {
      return Services(
        config: ConfigService.linux(),
        database: await DatabaseService.sql(),
      );
    }

    return Services(
      config: ConfigService.local(),
      database: await DatabaseService.sql(),
    );
  }

  final ConfigService config;
  final DatabaseService database;
}
