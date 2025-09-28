import 'dart:io';

import 'package:toml/toml.dart';

/// Configuration loader for Alacritty terminal settings.
///
/// This class reads and parses Alacritty's TOML configuration files,
/// including support for imports and deep merging of configuration values.
class AlacrittyConfig {
  /// Creates an Alacritty configuration with the parsed [values].
  const AlacrittyConfig(this.values);
  
  /// The parsed configuration values from the TOML file.
  final Map<String, dynamic> values;

  /// Reads and parses an Alacritty configuration file.
  ///
  /// If [file] is not provided, uses the default Alacritty configuration location.
  /// Returns null if the configuration file doesn't exist.
  ///
  /// This method supports Alacritty's import system, automatically loading
  /// and merging imported configuration files.
  static AlacrittyConfig? read([File? file]) {
    file ??= AlacrittyConfig.defaultFile;
    if (!file.existsSync()) return null;
    final config = file.readAsStringSync();
    final toml = TomlDocument.parse(config);
    final map = toml.toMap();
    var result = {...map};

    final imports = map['general']?['import'];
    if (imports is List<dynamic>) {
      final home = Platform.environment['HOME'];
      for (final imp in imports) {
        final path = imp.toString().replaceAll('~', home ?? '');
        final toml = TomlDocument.loadSync(path);
        final importMap = toml.toMap();
        result = _deepMerge(result, importMap);
      }
    }
    return AlacrittyConfig(result);
  }

  /// Returns the default Alacritty configuration file location.
  static File get defaultFile {
    final home = Platform.environment['HOME'];
    return File('$home/.config/alacritty/alacritty.toml');
  }
}

/// Recursively merges two configuration maps, with [v2] taking precedence.
Map<String, dynamic> _deepMerge(
  Map<String, dynamic> v1,
  Map<String, dynamic> v2,
) {
  return <String, dynamic>{
    ...v1,
    for (final e2 in v2.entries)
      if (v1[e2.key] is Map<String, dynamic> &&
          e2.value is Map<String, dynamic>)
        e2.key: _deepMerge(v1[e2.key], e2.value)
      else
        e2.key: e2.value,
  };
}
