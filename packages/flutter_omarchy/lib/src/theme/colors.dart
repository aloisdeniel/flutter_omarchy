import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/config/config.dart';
import 'package:flutter_omarchy/src/theme/fallback.g.dart';

/// Defines the color scheme for Omarchy components.
///
/// This class contains all the colors used throughout the Omarchy design system,
/// including background, foreground, and ANSI colors for terminal-like components.
class OmarchyColorThemeData {
  /// Creates a color theme with the specified colors.
  const OmarchyColorThemeData({
    required this.background,
    required this.foreground,
    required this.border,
    required this.selectedText,
    required this.normal,
    required this.bright,
  });

  /// Creates a color theme from the provided [config].
  ///
  /// This factory constructor loads color information from Alacritty terminal
  /// configuration and Walker application launcher settings. If no Alacritty
  /// configuration is available, it falls back to the Tokyo Night theme.
  factory OmarchyColorThemeData.fromConfig(OmarchyConfigData config) {
    final alacritty = config.alacritty;
    if (alacritty == null) {
      return OmarchyColorThemes.tokyoNight;
    }

    final primary = alacritty.values['colors']['primary'];
    final bright = OmarchyAnsiColorThemeData.fromAlacritty(
      alacritty.values['colors']['bright'],
    );
    return OmarchyColorThemeData(
      foreground: _color(primary['foreground']),
      background: _color(primary['background']),
      border: _color(config.walker?.colors['border'], bright.blue),
      selectedText: _color(config.walker?.colors['selected-text'], bright.blue),
      normal: OmarchyAnsiColorThemeData.fromAlacritty(
        alacritty.values['colors']['normal'],
      ),
      bright: bright,
    );
  }

  /// The primary background color used for containers and surfaces.
  final Color background;

  /// The primary foreground color used for text and icons.
  final Color foreground;

  /// The color used for borders and dividers.
  final Color border;

  /// The color used for selected text and highlighted elements.
  final Color selectedText;

  /// The normal ANSI color palette.
  final OmarchyAnsiColorThemeData normal;

  /// The bright ANSI color palette.
  final OmarchyAnsiColorThemeData bright;
}

/// Standard ANSI color names used in terminal applications.
enum AnsiColor { black, white, red, green, blue, yellow, magenta, cyan }

/// Contains the standard ANSI color palette.
///
/// This class provides access to the 8 standard ANSI colors used in
/// terminal applications and can be used to create terminal-like UI components.
class OmarchyAnsiColorThemeData {
  /// Creates an ANSI color palette with the specified colors.
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

  /// Creates an ANSI color palette from Alacritty configuration data.
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

  /// ANSI black color.
  final Color black;

  /// ANSI white color.
  final Color white;

  /// ANSI red color.
  final Color red;

  /// ANSI green color.
  final Color green;

  /// ANSI yellow color.
  final Color yellow;

  /// ANSI blue color.
  final Color blue;

  /// ANSI magenta color.
  final Color magenta;

  /// ANSI cyan color.
  final Color cyan;

  /// Returns the color for the specified [color] enum value.
  ///
  /// {@tool snippet}
  /// ```dart
  /// final colors = OmarchyAnsiColorThemeData(...);
  /// final redColor = colors[AnsiColor.red];
  /// ```
  /// {@end-tool}
  Color operator [](AnsiColor color) {
    return switch (color) {
      AnsiColor.black => black,
      AnsiColor.white => white,
      AnsiColor.red => red,
      AnsiColor.blue => blue,
      AnsiColor.green => green,
      AnsiColor.yellow => yellow,
      AnsiColor.magenta => magenta,
      AnsiColor.cyan => cyan,
    };
  }
}

/// Converts a hex color string to a [Color] object.
///
/// Supports both '#RRGGBB' and '0xRRGGBB' formats. If parsing fails
/// or [hex] is null, returns the provided [fallback] color.
Color _color(String? hex, [Color fallback = const Color(0xFF000000)]) {
  if (hex == null) return fallback;
  try {
    final value = hex.replaceFirst('#', '').replaceFirst('0x', '');
    return Color(0xFF000000 | int.parse(value, radix: 16));
  } catch (_) {
    return fallback;
  }
}
