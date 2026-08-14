import 'dart:io';
import 'dart:ui';

import 'package:flutter_omarchy/src/config/config.dart';
import 'package:flutter_omarchy/src/config/theme_config.dart';
import 'package:flutter_omarchy/src/theme/colors.dart';
import 'package:flutter_test/flutter_test.dart';

const _colorsToml = '''
mode = "dark"

accent = "#f38d70"
selection = "#403e41"
muted = "#72696a"

background = "#2c2525"
lighter_background = "#3d2f2a"
foreground = "#e6d9db"
bright_foreground = "#e6d9db"

red = "#fd6883"
yellow = "#f9cc6c"
green = "#adda78"
cyan = "#85dacc"
blue = "#f38d70"
magenta = "#a8a9eb"

bright_red = "#ff8297"
bright_yellow = "#fcd675"
bright_green = "#c8e292"
bright_cyan = "#9bf1e1"
bright_blue = "#f8a788"
bright_magenta = "#bebffd"
''';

void main() {
  late Directory root;

  Directory writeTheme(String colorsToml, {String? name}) {
    final theme = Directory('${root.path}/theme')..createSync(recursive: true);
    File('${theme.path}/colors.toml').writeAsStringSync(colorsToml);
    if (name != null) {
      File('${root.path}/theme.name').writeAsStringSync('$name\n');
    }
    return theme;
  }

  setUp(() {
    root = Directory.systemTemp.createTempSync('omarchy_config_test');
  });

  tearDown(() {
    root.deleteSync(recursive: true);
  });

  group('OmarchyThemeConfig', () {
    test('reads colors.toml and theme.name', () {
      final dir = writeTheme(_colorsToml, name: 'ristretto');
      final theme = OmarchyThemeConfig.read(dir);

      expect(theme, isNotNull);
      expect(theme!.name, 'ristretto');
      expect(theme.isLight, isFalse);
      expect(theme.color('background'), '#2c2525');
      expect(theme.color('accent'), '#f38d70');
      expect(theme.color('bright_red'), '#ff8297');
    });

    test('returns null when colors.toml is missing', () {
      final dir = Directory('${root.path}/theme')..createSync(recursive: true);
      expect(OmarchyThemeConfig.read(dir), isNull);
    });
  });

  group('OmarchyColorThemeData.fromThemeConfig', () {
    test('maps the palette like the Omarchy templates', () {
      final dir = writeTheme(_colorsToml);
      final colors = OmarchyColorThemeData.fromThemeConfig(
        OmarchyThemeConfig.read(dir)!,
      );

      expect(colors.background, const Color(0xFF2C2525));
      expect(colors.foreground, const Color(0xFFE6D9DB));
      expect(colors.accent, const Color(0xFFF38D70));
      expect(colors.border, colors.accent);
      expect(colors.selectedText, colors.accent);
      expect(colors.selection, const Color(0xFF403E41));
      expect(colors.muted, const Color(0xFF72696A));
      // ANSI black maps to the lighter background so that it stays visible
      // as a secondary surface/border color, white to the foreground, and
      // bright black to muted.
      expect(colors.normal.black, const Color(0xFF3D2F2A));
      expect(colors.normal.white, colors.foreground);
      expect(colors.bright.black, colors.muted);
      expect(colors.normal.red, const Color(0xFFFD6883));
      expect(colors.bright.red, const Color(0xFFFF8297));
    });

    test('detects light mode', () {
      final dir = writeTheme(
        _colorsToml.replaceFirst('mode = "dark"', 'mode = "light"'),
      );
      final colors = OmarchyColorThemeData.fromThemeConfig(
        OmarchyThemeConfig.read(dir)!,
      );
      expect(colors.brightness, Brightness.light);
    });
  });

  group('OmarchyConfigData.watch', () {
    test('emits when the theme directory is atomically swapped', () async {
      writeTheme(_colorsToml, name: 'ristretto');
      final events = <OmarchyConfigData>[];
      final subscription = OmarchyConfigData.watch(
        directories: [root],
      ).listen(events.add);
      // Give the watcher time to attach.
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Mimic omarchy-theme-set: build next-theme, swap it in, write name.
      final next = Directory('${root.path}/next-theme')..createSync();
      File(
        '${next.path}/colors.toml',
      ).writeAsStringSync(_colorsToml.replaceFirst('#f38d70', '#89b4fa'));
      Directory('${root.path}/theme').deleteSync(recursive: true);
      next.renameSync('${root.path}/theme');
      File('${root.path}/theme.name').writeAsStringSync('catppuccin\n');

      await Future<void>.delayed(const Duration(milliseconds: 500));
      await subscription.cancel();

      expect(events, isNotEmpty);
    });
  });
}
