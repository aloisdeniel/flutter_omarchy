import 'dart:io';

import 'package:toml/toml.dart';

/// The currently applied Omarchy theme, read from Omarchy's state directory.
///
/// Since Omarchy moved to a template based theming system, the active theme
/// lives in `~/.local/state/omarchy/current/theme` and defines its whole
/// palette in a canonical `colors.toml` file, from which all application
/// configs are generated. This class reads that palette directly.
class OmarchyThemeConfig {
  /// Creates a theme configuration with the given [name] and parsed [values].
  const OmarchyThemeConfig({this.name, required this.values});

  /// The active theme slug (e.g. `tokyo-night`), read from the `theme.name`
  /// file next to the theme directory. May be null on older Omarchy versions.
  final String? name;

  /// The raw values parsed from the theme's `colors.toml`.
  ///
  /// Contains color tokens such as `background`, `foreground`, `accent`,
  /// `selection`, `muted`, `red`, `bright_red`, ... as hex strings, and
  /// a `mode` key that is either `dark` or `light`.
  final Map<String, dynamic> values;

  /// Whether the theme declares itself as a light theme (`mode = "light"`).
  bool get isLight => values['mode'] == 'light';

  /// Returns the color token with the given [name] as a hex string, or null
  /// if the theme doesn't define it.
  String? color(String name) {
    final value = values[name];
    return value is String ? value : null;
  }

  /// The directory containing the currently applied theme, or null if no
  /// Omarchy theme is available.
  static Directory? get currentDir {
    final home = Platform.environment['HOME'];
    for (final path in [
      // Omarchy >= 3.0
      '$home/.local/state/omarchy/current/theme',
      // Older versions
      '$home/.config/omarchy/current/theme',
    ]) {
      final dir = Directory(path);
      if (dir.existsSync()) return dir;
    }
    return null;
  }

  /// Reads the theme configuration from [dir], or from [currentDir] when
  /// omitted.
  ///
  /// Returns null if no theme directory or `colors.toml` is found, which is
  /// the case on Omarchy versions predating the `colors.toml` format.
  static OmarchyThemeConfig? read([Directory? dir]) {
    dir ??= currentDir;
    if (dir == null) return null;
    final colorsFile = File('${dir.path}/colors.toml');
    if (!colorsFile.existsSync()) return null;
    try {
      final values = TomlDocument.parse(colorsFile.readAsStringSync()).toMap();
      String? name;
      final nameFile = File('${dir.parent.path}/theme.name');
      if (nameFile.existsSync()) {
        name = nameFile.readAsStringSync().trim();
      }
      return OmarchyThemeConfig(name: name, values: values);
    } catch (_) {
      return null;
    }
  }
}
