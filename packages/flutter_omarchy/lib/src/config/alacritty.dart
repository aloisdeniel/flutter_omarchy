import 'dart:io';

import 'package:toml/toml.dart';

class AlacrittyConfig {
  const AlacrittyConfig(this.values);
  final Map<String, dynamic> values;

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

  static File get defaultFile {
    final home = Platform.environment['HOME'];
    return File('$home/.config/alacritty/alacritty.toml');
  }
}

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
