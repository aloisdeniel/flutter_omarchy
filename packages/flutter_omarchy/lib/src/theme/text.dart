import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/config/config.dart';

/// Defines text styles used throughout the Omarchy design system.
///
/// This class provides three main text styles: normal, bold, and italic,
/// typically derived from terminal font configurations to maintain
/// consistency with the desktop environment.
class OmarchyTextStyleData {
  /// Creates text style data with the specified styles.
  const OmarchyTextStyleData({
    required this.bold,
    required this.normal,
    required this.italic,
  });
  
  /// The standard text style used for body text.
  final TextStyle normal;
  
  /// The bold text style used for emphasis and headers.
  final TextStyle bold;
  
  /// The italic text style used for subtle emphasis.
  final TextStyle italic;

  /// Creates text style data from the provided [config].
  ///
  /// This factory constructor loads font information from Alacritty terminal
  /// configuration. If no configuration is available, it falls back to
  /// default styles using the bundled CaskaydiaMono font.
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

  /// Creates fallback text style data using the bundled CaskaydiaMono font.
  ///
  /// This constructor provides default text styles when no configuration
  /// is available, ensuring the application always has usable text styling.
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

  /// Loads the fonts specified in this text style data.
  ///
  /// This method is responsible for loading system fonts on Linux platforms.
  /// On web and non-Linux platforms, this method completes immediately
  /// without doing anything.
  Future<void> loadFonts() {
    if (kIsWeb || !Platform.isLinux) return Future.value();
    return OmarchyFonts.instance.load({normal.fontFamily!});
  }
}

/// Creates a [TextStyle] from Alacritty font configuration data.
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

/// Manages system font loading and caching for Omarchy components.
///
/// This class provides functionality to discover and load system fonts
/// on Linux platforms using fontconfig (fc-list command).
class OmarchyFonts {
  /// The singleton instance of the font manager.
  static OmarchyFonts instance = OmarchyFonts();

  /// Cache of discovered system fonts.
  final Map<String, OmarchyFont> systemFonts = {};

  /// Whether the font discovery has been initialized.
  bool _initialized = false;

  /// Initializes font discovery by querying the system using fc-list.
  ///
  /// This method runs the fc-list command to discover all available system
  /// fonts and their styles, caching the results for future use.
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

  /// Loads the specified font [families] into Flutter's font system.
  ///
  /// This method discovers system fonts if not already done, then loads
  /// each of the requested font families for use in Flutter widgets.
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

/// Represents a system font with its available styles.
class OmarchyFont {
  /// Creates a font descriptor with the specified [name] and [styles].
  const OmarchyFont({
    required this.name,
    required this.styles,
    this.isLoaded = false,
  });
  
  /// The font family name.
  final String name;
  
  /// Available styles for this font family.
  final List<OmarchyFontStyle> styles;
  
  /// Whether this font has been loaded into Flutter's font system.
  final bool isLoaded;

  /// Loads this font and all its styles into Flutter's font system.
  ///
  /// Returns a new [OmarchyFont] instance with [isLoaded] set to true.
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

/// Represents a specific style variant of a font family.
class OmarchyFontStyle {
  /// Creates a font style with the specified [style] name and [file] path.
  const OmarchyFontStyle({required this.style, required this.file});
  
  /// The style name (e.g., 'Bold', 'Italic', 'Regular').
  final String? style;
  
  /// The file system path to the font file.
  final String file;
}
