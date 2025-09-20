import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/config/config.dart';

class OmarchyTextStyleData {
  const OmarchyTextStyleData({
    required this.bold,
    required this.normal,
    required this.italic,
  });
  final TextStyle normal;
  final TextStyle bold;
  final TextStyle italic;

  factory OmarchyTextStyleData.fromConfig(OmarchyConfigData config) {
    final alacritty = config.alacritty;
    if (alacritty == null) {
      return OmarchyTextStyleData.fallback();
    }
    final font = alacritty.values['font'];
    final normal = _textStyle(font['normal']);
    return OmarchyTextStyleData(
      normal: normal,
      italic: _textStyle(font['italic']).copyWith(fontStyle: FontStyle.italic),
      bold: _textStyle(font['bold']).copyWith(fontWeight: FontWeight.bold),
    );
  }

  const OmarchyTextStyleData.fallback()
    : normal = const TextStyle(
        fontSize: 14,
        fontFamily: 'CaskaydiaMono Nerd Font Mono',
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.none,
        package: 'flutter_omarchy',
      ),
      bold = const TextStyle(
        fontSize: 14,
        fontFamily: 'CaskaydiaMono Nerd Font Mono',
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none,
        package: 'flutter_omarchy',
      ),
      italic = const TextStyle(
        fontSize: 14,
        fontFamily: 'CaskaydiaMono Nerd Font Mono',
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.normal,
        decoration: TextDecoration.none,
        package: 'flutter_omarchy',
      );

  Future<void> loadFonts() {
    if (kIsWeb || !Platform.isLinux) return Future.value();
    return OmarchyFonts.instance.load({normal.fontFamily!});
  }
}

TextStyle _textStyle(Map<String, dynamic> map) {
  return TextStyle(
    fontSize: 14,
    fontFamily: map['family'],
    fontWeight: switch (map['style']) {
      'Bold' => FontWeight.bold,
      _ => FontWeight.normal,
    },
    fontFamilyFallback: ['CaskaydiaMono Nerd Font'],
    decoration: TextDecoration.none,
  );
}

class OmarchyFonts {
  static OmarchyFonts instance = OmarchyFonts();

  final Map<String, OmarchyFont> systemFonts = {};

  bool _initialized = false;

  Future<void> _initialize() async {
    if (!_initialized) {
      final list = await Process.run('fc-list', [
        "--format=%{file}:%{family}:%{style}\\n",
      ]);
      final lines = const LineSplitter().convert(list.stdout);

      for (var line in lines) {
        final parts = line.split(':');
        if (parts.length > 2) {
          final file = parts[0];
          final family = parts[1].split(',').first;
          final style = parts[2];
          final systemFont = systemFonts.putIfAbsent(
            family,
            () => OmarchyFont(name: family, styles: []),
          );
          systemFonts[family] = OmarchyFont(
            name: family,
            styles: [
              ...systemFont.styles,
              OmarchyFontStyle(file: file, style: style),
            ],
          );
        }
      }
      _initialized = true;
    }
  }

  Future<void> load(Set<String> families) async {
    await _initialize();
    for (var family in families) {
      final systemFont = systemFonts[family];
      if (systemFont != null && !systemFont.isLoaded) {
        await systemFont.load();
      }
    }
  }
}

class OmarchyFont {
  const OmarchyFont({
    required this.name,
    required this.styles,
    this.isLoaded = false,
  });
  final String name;
  final List<OmarchyFontStyle> styles;
  final bool isLoaded;

  Future<OmarchyFont> load() async {
    final loader = FontLoader(name);
    for (var style in styles) {
      final file = File(style.file);
      if (file.existsSync()) {
        loader.addFont(
          file.readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
        );
      }
    }
    await loader.load();
    return OmarchyFont(name: name, styles: styles, isLoaded: true);
  }
}

class OmarchyFontStyle {
  const OmarchyFontStyle({required this.style, required this.file});
  final String? style;
  final String file;
}
