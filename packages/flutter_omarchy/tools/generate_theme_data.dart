// ignore_for_file: avoid_print

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';
import 'package:toml/toml.dart';

/// Generates `lib/src/theme/fallback.g.dart` from the stock Omarchy themes
/// in `./themes`, each of which is a directory containing a `colors.toml`
/// palette (copied from `/usr/share/omarchy/themes`).
///
/// The color mapping mirrors `OmarchyColorThemeData.fromThemeConfig`.
void main() {
  final themeDirs = Directory('./themes').listSync().whereType<Directory>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final result = StringBuffer();
  result.writeln('import \'package:flutter/widgets.dart\';');
  result.writeln('import \'package:flutter_omarchy/src/theme/colors.dart\';');
  result.writeln();
  result.writeln('abstract class OmarchyColorThemes {');
  final allThemes = <String, String>{};
  var isFirst = true;
  for (final dir in themeDirs) {
    final dirName = dir.path.split(Platform.pathSeparator).last;
    final colorsFile = File(path.join(dir.path, 'colors.toml'));
    if (!colorsFile.existsSync()) {
      print('Warning: No colors.toml found in ${dir.path}, skipping...');
      continue;
    }
    final themeName = ReCase(dirName).camelCase;
    allThemes[dirName] = themeName;

    final values = TomlDocument.parse(colorsFile.readAsStringSync()).toMap();
    int? token(String name) {
      final value = values[name];
      if (value is! String) return null;
      try {
        final hex = value.replaceFirst('#', '').replaceFirst('0x', '');
        return 0xFF000000 | int.parse(hex, radix: 16);
      } catch (_) {
        return null;
      }
    }

    final background = token('background') ?? 0xFF000000;
    final black = token('lighter_background') ?? background;
    final foreground = token('foreground') ?? 0xFFFFFFFF;
    final accent = token('accent') ?? token('blue') ?? foreground;
    final muted = token('muted') ?? foreground;
    final red = token('red') ?? foreground;
    final green = token('green') ?? foreground;
    final yellow = token('yellow') ?? foreground;
    final blue = token('blue') ?? foreground;
    final magenta = token('magenta') ?? foreground;
    final cyan = token('cyan') ?? foreground;
    final brightness = values['mode'] == 'light' ? 'light' : 'dark';
    String c(int value) =>
        'Color(0x${value.toRadixString(16).padLeft(8, '0').toUpperCase()})';

    if (!isFirst) {
      result.writeln();
    }
    isFirst = false;

    result.writeln('''  static const $themeName = OmarchyColorThemeData(
    brightness: Brightness.$brightness,
    background: ${c(background)},
    foreground: ${c(foreground)},
    border: ${c(accent)},
    selectedText: ${c(accent)},
    accent: ${c(accent)},
    selection: ${c(token('selection') ?? accent)},
    muted: ${c(muted)},
    normal: OmarchyAnsiColorThemeData(
      black: ${c(black)},
      white: ${c(foreground)},
      red: ${c(red)},
      green: ${c(green)},
      yellow: ${c(yellow)},
      blue: ${c(blue)},
      magenta: ${c(magenta)},
      cyan: ${c(cyan)},
    ),
    bright: OmarchyAnsiColorThemeData(
      black: ${c(muted)},
      white: ${c(token('bright_foreground') ?? foreground)},
      red: ${c(token('bright_red') ?? red)},
      green: ${c(token('bright_green') ?? green)},
      yellow: ${c(token('bright_yellow') ?? yellow)},
      blue: ${c(token('bright_blue') ?? blue)},
      magenta: ${c(token('bright_magenta') ?? magenta)},
      cyan: ${c(token('bright_cyan') ?? cyan)},
    ),
  );''');
  }

  result.writeln('  static Map<String, OmarchyColorThemeData> get all => {');
  allThemes.forEach((dirName, themeName) {
    result.writeln('    \'$dirName\': $themeName,');
  });
  result.writeln('  };');

  result.writeln('}');

  final outputFile = File('../lib/src/theme/fallback.g.dart');
  outputFile.writeAsStringSync(result.toString());
}
