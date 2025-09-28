import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/config/config.dart';
import 'package:flutter_omarchy/src/theme/colors.dart';
import 'package:flutter_omarchy/src/theme/text.dart';

/// A utility class for accessing [OmarchyThemeData] from a [BuildContext].
///
/// This class provides static methods to retrieve theme data from the widget
/// tree, similar to how [Theme.of] works in Material Design.
abstract class OmarchyTheme {
  /// Returns the [OmarchyThemeData] from the closest [OmarchyThemeProvider] ancestor.
  ///
  /// If no [OmarchyThemeProvider] is found in the widget tree, this method
  /// will throw an exception. Use [maybeOf] if you need to handle the case
  /// where no theme provider is available.
  ///
  /// {@tool snippet}
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   final theme = OmarchyTheme.of(context);
  ///   return Container(
  ///     color: theme.colors.background,
  ///     child: Text('Hello', style: theme.text.normal),
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  static OmarchyThemeData of(BuildContext context) {
    return OmarchyThemeProvider.maybeOf(context)!;
  }

  /// Returns the [OmarchyThemeData] from the closest [OmarchyThemeProvider] ancestor,
  /// or null if no such ancestor exists.
  ///
  /// This method is useful when you need to conditionally apply theming based
  /// on whether an Omarchy theme is available.
  static OmarchyThemeData? maybeOf(BuildContext context) {
    return OmarchyThemeProvider.maybeOf(context);
  }
}

/// An [InheritedWidget] that provides [OmarchyThemeData] to its descendants.
///
/// This widget makes theme data available to all descendant widgets in the
/// widget tree. It's typically used by the [Omarchy] widget to provide
/// theme data throughout the application.
class OmarchyThemeProvider extends InheritedWidget {
  /// Creates a theme provider that makes [data] available to its descendants.
  const OmarchyThemeProvider({
    super.key,
    required this.data,
    required super.child,
  });

  /// The theme data to be provided to descendants.
  final OmarchyThemeData data;

  /// Returns the [OmarchyThemeData] from the closest [OmarchyThemeProvider] ancestor,
  /// or null if no such ancestor exists.
  static OmarchyThemeData? maybeOf(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<OmarchyThemeProvider>();
    return inherited?.data;
  }

  @override
  bool updateShouldNotify(covariant OmarchyThemeProvider oldWidget) {
    return oldWidget.data != data;
  }
}

/// Defines the overall visual theme for Omarchy components.
///
/// This class contains all the theming information needed to style Omarchy
/// widgets, including colors and text styles. It can be created from
/// configuration data or constructed manually.
class OmarchyThemeData {
  /// Creates theme data with the specified [colors] and [text] styling.
  const OmarchyThemeData({required this.colors, required this.text});

  /// The color scheme used throughout the application.
  final OmarchyColorThemeData colors;
  
  /// The text styles used for different types of text content.
  final OmarchyTextStyleData text;

  /// Creates theme data from the provided [config].
  ///
  /// This factory constructor loads color and text styling information
  /// from the configuration and ensures that text colors are properly
  /// set to match the foreground color from the color scheme.
  static OmarchyThemeData fromConfig(OmarchyConfigData config) {
    final colors = OmarchyColorThemeData.fromConfig(config);
    final text = OmarchyTextStyleData.fromConfig(config);
    return OmarchyThemeData(
      colors: colors,
      text: OmarchyTextStyleData(
        bold: text.bold.copyWith(color: colors.foreground),
        normal: text.normal.copyWith(color: colors.foreground),
        italic: text.italic.copyWith(color: colors.foreground),
      ),
    );
  }
}
