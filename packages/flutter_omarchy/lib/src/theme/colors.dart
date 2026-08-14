import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/config/config.dart';
import 'package:flutter_omarchy/src/config/theme_config.dart';
import 'package:flutter_omarchy/src/theme/fallback.g.dart';

/// Defines the color scheme for Omarchy components.
///
/// This class contains all the colors used throughout the Omarchy design system,
/// including background, foreground, and ANSI colors for terminal-like components.
class OmarchyColorThemeData {
  /// Creates a color theme with the specified colors.
  ///
  /// The [accent], [selection] and [muted] colors were introduced with the
  /// Omarchy `colors.toml` theme format; when omitted they fall back to
  /// values derived from the other colors so that legacy themes keep working.
  const OmarchyColorThemeData({
    required this.background,
    required this.foreground,
    required this.border,
    required this.selectedText,
    required this.normal,
    required this.bright,
    this.brightness = Brightness.dark,
    Color? accent,
    Color? selection,
    Color? muted,
  }) : accent = accent ?? selectedText,
       selection = selection ?? border,
       muted = muted ?? foreground;

  /// Creates a color theme from the provided [config].
  ///
  /// On recent Omarchy versions, colors are loaded from the current theme's
  /// canonical `colors.toml` palette. On older versions it falls back to the
  /// Alacritty terminal colors, and to the Tokyo Night theme when no
  /// configuration is available at all.
  factory OmarchyColorThemeData.fromConfig(OmarchyConfigData config) {
    final theme = config.theme;
    if (theme != null) {
      return OmarchyColorThemeData.fromThemeConfig(theme);
    }

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
      border: bright.blue,
      selectedText: bright.blue,
      normal: OmarchyAnsiColorThemeData.fromAlacritty(
        alacritty.values['colors']['normal'],
      ),
      bright: bright,
    );
  }

  /// Creates a color theme from an Omarchy `colors.toml` palette.
  ///
  /// The mapping mirrors the one Omarchy itself uses when generating
  /// application configs from the theme templates, with one exception:
  /// ANSI black maps to `lighter_background` instead of the background,
  /// since the widgets use it as a secondary surface and border color
  /// (dividers, tab bars, status bar) that must stay distinguishable from
  /// the background. Bright black maps to the muted color.
  factory OmarchyColorThemeData.fromThemeConfig(OmarchyThemeConfig theme) {
    Color token(String name, Color fallback) =>
        _color(theme.color(name), fallback);

    final background = token('background', const Color(0xFF1A1B26));
    final foreground = token('foreground', const Color(0xFFA9B1D6));
    final accent = token('accent', token('blue', foreground));
    final muted = token('muted', foreground);
    final normal = OmarchyAnsiColorThemeData(
      black: token('lighter_background', background),
      white: foreground,
      red: token('red', foreground),
      green: token('green', foreground),
      yellow: token('yellow', foreground),
      blue: token('blue', foreground),
      magenta: token('magenta', foreground),
      cyan: token('cyan', foreground),
    );
    return OmarchyColorThemeData(
      brightness: theme.isLight ? Brightness.light : Brightness.dark,
      background: background,
      foreground: foreground,
      border: accent,
      selectedText: accent,
      accent: accent,
      selection: token('selection', accent),
      muted: muted,
      normal: normal,
      bright: OmarchyAnsiColorThemeData(
        black: muted,
        white: token('bright_foreground', foreground),
        red: token('bright_red', normal.red),
        green: token('bright_green', normal.green),
        yellow: token('bright_yellow', normal.yellow),
        blue: token('bright_blue', normal.blue),
        magenta: token('bright_magenta', normal.magenta),
        cyan: token('bright_cyan', normal.cyan),
      ),
    );
  }

  /// Whether this is a dark or light theme (`mode` in `colors.toml`).
  final Brightness brightness;

  /// The primary background color used for containers and surfaces.
  final Color background;

  /// The primary foreground color used for text and icons.
  final Color foreground;

  /// The theme's accent color, used for active borders and highlights.
  final Color accent;

  /// The background color used for text selections.
  final Color selection;

  /// The color used for de-emphasized text and icons.
  final Color muted;

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
