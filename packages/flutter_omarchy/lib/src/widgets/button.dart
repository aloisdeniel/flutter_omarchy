import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/colors.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/utils/default_foreground.dart';
import 'package:flutter_omarchy/src/widgets/utils/pointer_area.dart';

/// Defines the styling data for [OmarchyButton] across different interaction states.
///
/// This class contains all the visual properties needed to style a button
/// in different states (normal, focused, pressed, disabled, hovering).
class OmarchyButtonStyleData {
  /// Creates button style data with state-specific styling.
  const OmarchyButtonStyleData({
    required this.normal,
    required this.focused,
    required this.pressed,
    required this.disabled,
    required this.hovering,
    required this.padding,
    required this.borderWidth,
    this.transitionDuration = const Duration(milliseconds: 120),
  });

  /// The duration for transitions between states.
  final Duration transitionDuration;

  /// The padding inside the button.
  final EdgeInsetsGeometry padding;

  /// The width of the button's border.
  final double borderWidth;

  /// Styling for the normal (default) state.
  final OmarchyButtonStyleStateData normal;

  /// Styling for the focused state.
  final OmarchyButtonStyleStateData focused;

  /// Styling for the pressed state.
  final OmarchyButtonStyleStateData pressed;

  /// Styling for the disabled state.
  final OmarchyButtonStyleStateData disabled;

  /// Styling for the hovering state.
  final OmarchyButtonStyleStateData hovering;

  /// Returns the appropriate style state data based on the current [state].
  OmarchyButtonStyleStateData fromPointer(PointerState state) =>
      switch (state) {
        PointerState(isEnabled: false) => disabled,
        PointerState(isPressed: true) => pressed,
        PointerState(isHovering: true) => hovering,
        PointerState(hasFocus: true) => focused,
        _ => normal,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OmarchyButtonStyleData) return false;
    return normal == other.normal &&
        focused == other.focused &&
        pressed == other.pressed &&
        disabled == other.disabled &&
        hovering == other.hovering &&
        padding == other.padding &&
        borderWidth == other.borderWidth &&
        transitionDuration == other.transitionDuration;
  }

  @override
  int get hashCode {
    return Object.hash(
      normal.hashCode,
      focused.hashCode,
      pressed.hashCode,
      disabled.hashCode,
      hovering.hashCode,
      padding.hashCode,
      borderWidth.hashCode,
      transitionDuration.hashCode,
    );
  }
}

/// Defines the colors for a button in a specific interaction state.
///
/// This record type contains the three primary colors that define
/// the appearance of a button: border, foreground (text/icon), and background.
typedef OmarchyButtonStyleStateData = ({
  /// The border color for this state.
  Color border,

  /// The foreground (text/icon) color for this state.
  Color foreground,

  /// The background color for this state.
  Color background,
});

/// An [InheritedWidget] that provides [OmarchyButtonStyle] to its descendants.
///
/// This widget makes button styling available to all descendant [OmarchyButton]
/// widgets in the widget tree, allowing for consistent button theming.
class OmarchyButtonTheme extends InheritedWidget {
  /// Creates a button theme that provides [data] to its descendants.
  const OmarchyButtonTheme({
    super.key,
    required super.child,
    required this.data,
  });

  /// The button style to be provided to descendants.
  final OmarchyButtonStyle data;

  /// Returns the [OmarchyButtonStyle] from the closest [OmarchyButtonTheme] ancestor,
  /// or null if no such ancestor exists.
  static OmarchyButtonStyle? maybeOf(BuildContext context) {
    final theme = context
        .dependOnInheritedWidgetOfExactType<OmarchyButtonTheme>();
    return theme?.data;
  }

  /// Returns the [OmarchyButtonStyle] from the closest [OmarchyButtonTheme] ancestor.
  ///
  /// Throws a [FlutterError] if no [OmarchyButtonTheme] is found in the widget tree.
  static OmarchyButtonStyle of(BuildContext context) {
    final theme = context
        .dependOnInheritedWidgetOfExactType<OmarchyButtonTheme>();
    if (theme == null) {
      throw FlutterError('OmarchyButtonTheme not found in context');
    }
    return theme.data;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return oldWidget is OmarchyButtonTheme && data != oldWidget.data;
  }
}

/// Abstract base class for defining button styles in the Omarchy design system.
///
/// This class provides factory constructors for common button styles and defines
/// the interface for resolving style data based on the current theme context.
abstract class OmarchyButtonStyle {
  /// Creates a button style.
  const OmarchyButtonStyle();

  /// Creates an outline button style with the specified [accent] color.
  ///
  /// Outline buttons have a transparent background with a colored border
  /// and text that matches the accent color.
  const factory OmarchyButtonStyle.outline(
    AnsiColor accent, {
    EdgeInsetsGeometry padding,
    double borderWidth,
  }) = OutlineOmarchyButtonStyle;

  /// Creates a filled button style with the specified [accent] color.
  ///
  /// Filled buttons have a colored background with the accent color
  /// and contrasting text color.
  const factory OmarchyButtonStyle.filled(
    AnsiColor accent, {
    EdgeInsetsGeometry padding,
  }) = FilledOmarchyButtonStyle;

  /// Creates a bar-style button with minimal styling.
  ///
  /// Bar buttons have no border and only show background color on interaction.
  /// Commonly used in navigation bars and toolbars.
  const factory OmarchyButtonStyle.bar([AnsiColor accent]) =
      BarOmarchyButtonStyle;

  /// Creates a custom button style with the provided [data].
  ///
  /// This allows for complete customization of button appearance
  /// beyond the built-in style variants.
  const factory OmarchyButtonStyle.custom(OmarchyButtonStyleData data) =
      CustomOmarchyButtonStyle;

  /// Resolves this button style to concrete styling data based on the [context].
  OmarchyButtonStyleData resolve(BuildContext context);
}

class CustomOmarchyButtonStyle extends OmarchyButtonStyle {
  const CustomOmarchyButtonStyle(this.data);
  final OmarchyButtonStyleData data;

  @override
  OmarchyButtonStyleData resolve(BuildContext context) {
    return data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomOmarchyButtonStyle) return false;
    return data == other.data;
  }

  @override
  int get hashCode {
    return data.hashCode;
  }
}

class FilledOmarchyButtonStyle extends OmarchyButtonStyle {
  const FilledOmarchyButtonStyle(
    this.accent, {
    this.padding = const EdgeInsets.all(8),
  });
  final AnsiColor accent;
  final EdgeInsetsGeometry padding;

  @override
  OmarchyButtonStyleData resolve(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final bright = theme.colors.bright[accent];
    final normal = theme.colors.normal[accent];
    return switch (accent) {
      // TODO
      _ => OmarchyButtonStyleData(
        padding: padding,
        borderWidth: 2,
        normal: (
          border: bright.withValues(alpha: 0),
          background: normal.withValues(alpha: 0.15),
          foreground: bright,
        ),
        pressed: (
          border: bright.withValues(alpha: 0),
          background: normal.withValues(alpha: 0.35),
          foreground: bright,
        ),
        focused: (
          border: bright.withValues(alpha: 0.5),
          background: normal.withValues(alpha: 0.15),
          foreground: bright,
        ),
        hovering: (
          border: bright.withValues(alpha: 0),
          background: normal.withValues(alpha: 0.25),
          foreground: bright,
        ),
        disabled: (
          border: normal.withValues(alpha: 0),
          background: normal.withValues(alpha: 0.02),
          foreground: normal.withValues(alpha: 0.3),
        ),
      ),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OutlineOmarchyButtonStyle) return false;
    return accent == other.accent && padding == other.padding;
  }

  @override
  int get hashCode {
    return Object.hash(accent, padding);
  }
}

class OutlineOmarchyButtonStyle extends OmarchyButtonStyle {
  const OutlineOmarchyButtonStyle(
    this.accent, {
    this.padding = const EdgeInsets.all(8),
    this.borderWidth = 2,
  });
  final AnsiColor accent;
  final EdgeInsetsGeometry padding;
  final double borderWidth;

  @override
  OmarchyButtonStyleData resolve(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final bright = theme.colors.bright[accent];
    final normal = theme.colors.normal[accent];
    return switch (accent) {
      // TODO
      _ => OmarchyButtonStyleData(
        padding: padding,
        borderWidth: borderWidth,
        normal: (
          border: normal,
          background: normal.withValues(alpha: 0),
          foreground: bright,
        ),
        pressed: (
          border: bright,
          background: normal.withValues(alpha: 0.25),
          foreground: bright,
        ),
        focused: (
          border: bright,
          background: normal.withValues(alpha: 0),
          foreground: bright,
        ),
        hovering: (
          border: normal,
          background: normal.withValues(alpha: 0.15),
          foreground: bright,
        ),
        disabled: (
          border: normal.withValues(alpha: 0.5),
          background: normal.withValues(alpha: 0),
          foreground: normal,
        ),
      ),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OutlineOmarchyButtonStyle) return false;
    return accent == other.accent &&
        padding == other.padding &&
        borderWidth == other.borderWidth;
  }

  @override
  int get hashCode {
    return Object.hash(accent, padding, borderWidth);
  }
}

class BarOmarchyButtonStyle extends OmarchyButtonStyle {
  const BarOmarchyButtonStyle([this.accent = AnsiColor.white]);
  final AnsiColor accent;

  @override
  OmarchyButtonStyleData resolve(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final bright = theme.colors.bright[accent];
    final normal = theme.colors.normal[accent];
    return switch (accent) {
      _ => OmarchyButtonStyleData(
        borderWidth: 0,
        padding: const EdgeInsets.all(12),
        normal: (
          border: const Color(0x00000000),
          background: normal.withValues(alpha: 0),
          foreground: bright,
        ),
        pressed: (
          border: const Color(0x00000000),
          background: normal.withValues(alpha: 0.25),
          foreground: bright,
        ),
        focused: (
          border: const Color(0x00000000),
          background: normal.withValues(alpha: 0),
          foreground: bright,
        ),
        hovering: (
          border: const Color(0x00000000),
          background: normal.withValues(alpha: 0.15),
          foreground: bright,
        ),
        disabled: (
          border: const Color(0x00000000),
          background: normal.withValues(alpha: 0),
          foreground: normal,
        ),
      ),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OutlineOmarchyButtonStyle) return false;
    return accent == other.accent;
  }

  @override
  int get hashCode {
    return accent.hashCode;
  }
}

/// A customizable button widget following the Omarchy design system.
///
/// This button provides consistent styling with support for different visual
/// styles (outline, filled, bar) and interaction states (normal, pressed,
/// focused, hovering, disabled).
///
/// {@tool snippet}
/// ```dart
/// OmarchyButton(
///   style: OmarchyButtonStyle.outline(AnsiColor.blue),
///   onPressed: () => print('Button pressed'),
///   child: Text('Click me'),
/// )
/// ```
/// {@end-tool}
class OmarchyButton extends StatelessWidget {
  /// Creates an Omarchy button with the given [child] and optional styling.
  const OmarchyButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding = const EdgeInsets.all(16),
    this.style,
    this.focusNode,
    this.borderWidth,
  });

  /// The widget to display inside the button.
  final Widget child;

  /// The style to apply to this button.
  ///
  /// If null, the style will be inherited from [OmarchyButtonTheme] or
  /// default to an outline style with white accent color.
  final OmarchyButtonStyle? style;

  /// The padding inside the button.
  final EdgeInsets padding;

  /// The callback executed when the button is pressed.
  ///
  /// If null, the button will be disabled.
  final VoidCallback? onPressed;

  /// The focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Override for the border width defined in the style.
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    final style =
        (this.style ??
                OmarchyButtonTheme.maybeOf(context) ??
                OmarchyButtonStyle.outline(AnsiColor.white))
            .resolve(context);
    return PointerArea(
      focusNode: focusNode,
      onTap: onPressed,
      child: child,
      builder: (context, state, child) {
        final stateStyle = style.fromPointer(state);
        return AnimatedContainer(
          duration: style.transitionDuration,
          decoration: BoxDecoration(
            color: stateStyle.background,
            border: BoxBorder.all(
              width: borderWidth ?? style.borderWidth,
              color: stateStyle.border,
            ),
          ),
          padding: style.padding,
          child: DefaultForeground(
            foreground: stateStyle.foreground,
            child: child!,
          ),
        );
      },
    );
  }
}
