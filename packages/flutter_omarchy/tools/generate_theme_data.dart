// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_omarchy/src/config/alacritty.dart';
import 'package:flutter_omarchy/src/config/walker.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

void main() {
  /// Read all subdirectories in ./themes
  final themeDirs = Directory(
    './themes',
  ).listSync().whereType<Directory>().toList();

  final result = StringBuffer();
  result.writeln('import \'package:flutter/widgets.dart\';');
  result.writeln('import \'package:flutter_omarchy/src/theme/colors.dart\';');
  result.writeln();
  result.writeln('abstract class OmarchyColorThemes {');
  final allThemes = <String, String>{};
  for (var i = 0; i < themeDirs.length; i++) {
    final dir = themeDirs[i];
    final dirName = dir.path.split(Platform.pathSeparator).last;
    final themeName = ReCase(dirName).camelCase;
    allThemes[dirName] = themeName;

    final alacritty = AlacrittyConfig.read(
      File(path.join(dir.path, 'alacritty.toml')),
    );

    if (alacritty == null) {
      print('Warning: No alacritty.toml found in ${dir.path}, skipping...');
      continue;
    }
    final walker = WalkerConfig.read(File(path.join(dir.path, 'walker.css')));
    final theme = OmarchyColorThemeData.fromConfig(alacritty, walker);
    String c(int value) =>
        'Color(0x${value.toRadixString(16).padLeft(8, '0')})';

    if (i != 0) {
      result.writeln();
    }

    result.writeln('''  static const $themeName = OmarchyColorThemeData(
    background: ${c(theme.background)},
    foreground: ${c(theme.foreground)},
    border: ${c(theme.border)},
    selectedText: ${c(theme.selectedText)},
    normal: OmarchyAnsiColorThemeData(
      black: ${c(theme.normal.black)},
      white: ${c(theme.normal.white)},
      red: ${c(theme.normal.red)},
      green: ${c(theme.normal.green)},
      yellow: ${c(theme.normal.yellow)},
      blue: ${c(theme.normal.blue)},
      magenta: ${c(theme.normal.magenta)},
      cyan: ${c(theme.normal.cyan)},
    ),
    bright: OmarchyAnsiColorThemeData(
      black: ${c(theme.bright.black)},
      white: ${c(theme.bright.white)},
      red: ${c(theme.bright.red)},
      green: ${c(theme.bright.green)},
      yellow: ${c(theme.bright.yellow)},
      blue: ${c(theme.bright.blue)},
      magenta: ${c(theme.bright.magenta)},
      cyan: ${c(theme.bright.cyan)},
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

class OmarchyColorThemeData {
  const OmarchyColorThemeData({
    required this.background,
    required this.foreground,
    required this.border,
    required this.selectedText,
    required this.normal,
    required this.bright,
  });

  factory OmarchyColorThemeData.fromConfig(
    AlacrittyConfig alacritty,
    WalkerConfig? walker,
  ) {
    final primary = alacritty.values['colors']['primary'];
    final bright = OmarchyAnsiColorThemeData.fromAlacritty(
      alacritty.values['colors']['bright'],
    );
    return OmarchyColorThemeData(
      foreground: _color(primary['foreground']),
      background: _color(primary['background']),
      border: _color(walker?.colors['border'], bright.blue),
      selectedText: _color(walker?.colors['selected-text'], bright.blue),
      normal: OmarchyAnsiColorThemeData.fromAlacritty(
        alacritty.values['colors']['normal'],
      ),
      bright: bright,
    );
  }

  final int background;
  final int foreground;
  final int border;
  final int selectedText;
  final OmarchyAnsiColorThemeData normal;
  final OmarchyAnsiColorThemeData bright;
}

enum AnsiColor { black, white, red, green, blue, yellow, magenta, cyan }

class OmarchyAnsiColorThemeData {
  const OmarchyAnsiColorThemeData({
    required this.black,
    required this.white,
    required this.red,
    required this.green,
    required this.yellow,
    required this.blue,
    required this.magenta,
    required this.cyan,
  });

  factory OmarchyAnsiColorThemeData.fromAlacritty(Map<String, dynamic> config) {
    return OmarchyAnsiColorThemeData(
      black: _color(config['black']),
      white: _color(config['white']),
      red: _color(config['red']),
      yellow: _color(config['yellow']),
      blue: _color(config['blue']),
      magenta: _color(config['magenta']),
      cyan: _color(config['cyan']),
      green: _color(config['green']),
    );
  }

  final int black;
  final int white;
  final int red;
  final int green;
  final int yellow;
  final int blue;
  final int magenta;
  final int cyan;
}

int _color(String? hex, [int fallback = 0xFF000000]) {
  if (hex == null) return fallback;
  try {
    final value = hex.replaceFirst('#', '').replaceFirst('0x', '');
    return 0xFF000000 | int.parse(value, radix: 16);
  } catch (_) {
    return fallback;
  }
}
