import 'dart:io';

/// Configuration loader for Walker application launcher settings.
///
/// This class reads and parses Walker's CSS theme files to extract
/// color definitions that can be used for theming UI components.
class WalkerConfig {
  /// Creates a Walker configuration with the parsed [colors].
  const WalkerConfig(this.colors);
  
  /// The color definitions extracted from the Walker CSS theme file.
  final Map<String, String> colors;

  /// Reads and parses a Walker configuration file.
  ///
  /// If [file] is not provided, uses the default Walker theme location.
  /// Returns null if the configuration file doesn't exist.
  ///
  /// This method parses CSS @define-color declarations to extract
  /// color values for theming.
  static WalkerConfig? read([File? file]) {
    file ??= WalkerConfig.defaultFile;
    if (!file.existsSync()) return null;
    final config = file.readAsStringSync();

    final colors = <String, String>{};
    final regex = RegExp(
      r'\@define-color\s+([a-zA-Z0-9-_+]+)\s+\#([a-fA-F0-9]+)',
    );

    for (final match in regex.allMatches(config)) {
      colors[match[1]!] = match[2]!;
    }

    return WalkerConfig(colors);
  }

  /// Returns the default Walker theme file location.
  static File get defaultFile {
    final home = Platform.environment['HOME'];
    return File('$home/.config/omarchy/current/theme/walker.css');
  }

  /// Watches for changes to the Walker configuration file.
  ///
  /// Yields updated configuration data when the file changes.
  /// Only watches if the file exists.
  static Stream<WalkerConfig?> watch() async* {
    if (!defaultFile.existsSync()) {
      await for (final _ in defaultFile.watch()) {
        yield read()!;
      }
    }
  }
}
