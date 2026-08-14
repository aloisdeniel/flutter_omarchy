import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'config.dart';

abstract class ConfigService {
  const ConfigService();

  factory ConfigService.linux() => LinuxConfigService();

  factory ConfigService.demo() => DemoConfigService();

  factory ConfigService.local() => LocalConfigService();

  /// Saves the given YAML string to the configuration file.
  Future<void> save(String yaml);

  /// Loads the configuration from the configuration file.
  ///
  /// If the file does not exist, it creates one with default settings.
  Future<Config> load();

  /// Observes following changes to the configuration file and yields updated Config objects.
  Stream<Config?> watch();
}

class LinuxConfigService extends ConfigService {
  @override
  Future<void> save(String yaml) async {
    final file = _defaultFile;
    await file.writeAsString(yaml);
  }

  @override
  Future<Config> load() async {
    final file = _defaultFile;

    // Create the config file with default settings if it does not exist.
    if (!file.existsSync()) {
      await file.create(recursive: true);
      await file.writeAsString(defaultConfig.trim());
    }

    try {
      final content = await file.readAsString();
      return Config.fromYaml(content);
    } catch (e) {
      return Config.fromYaml(defaultConfig);
    }
  }

  @override
  Stream<Config> watch() async* {
    final file = _defaultFile;
    await for (final event in file.watch()) {
      switch (event) {
        case FileSystemModifyEvent(contentChanged: true):
          try {
            final content = await file.readAsString();
            yield Config.fromYaml(content);
          } catch (e) {
            // TODO: show feedback to user
            // Failed loaded are ignore for now
          }
          yield await load();
          break;
        default:
      }
    }
  }

  /// Returns the default configuration file path.
  static final File _defaultFile = () {
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    return File(
      '$home/.config/app/config.yaml'
    );
  }();
}

class DemoConfigService extends ConfigService {
  DemoConfigService();

  Config _config = Config(demo: true);

  @override
  Future<void> save(String yaml) {
    _config = Config.fromYaml(yaml);
    return Future.value();
  }

  @override
  Future<Config> load() {
    return Future.value(_config);
  }

  @override
  Stream<Config> watch() {
    return Stream.empty();
  }
}

class LocalConfigService extends ConfigService {
  const LocalConfigService();

  @override
  Future<void> save(String yaml) async {
    final file = await _defaultFile;
    await file.writeAsString(yaml);
  }

  @override
  Future<Config> load() async {
    final file = await _defaultFile;

    // Create the config file with default settings if it does not exist.
    if (!file.existsSync()) {
      await file.create(recursive: true);
      await file.writeAsString(defaultConfig.trim());
    }

    try {
      final content = await file.readAsString();
      return Config.fromYaml(content);
    } catch (e) {
      return Config.fromYaml(defaultConfig);
    }
  }

  @override
  Stream<Config> watch() async* {
    final file = await _defaultFile;
    await for (final event in file.watch()) {
      switch (event) {
        case FileSystemModifyEvent(contentChanged: true):
          try {
            final content = await file.readAsString();
            yield Config.fromYaml(content);
          } catch (e) {
            // TODO: show feedback to user
            // Failed loaded are ignore for now
          }
          yield await load();
          break;
        default:
      }
    }
  }

  /// Returns the default configuration file path.
  static final Future<File> _defaultFile = () async {
    final doc = await getApplicationDocumentsDirectory();
    return File('${doc.path}/config.yaml');
  }();
}
