import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/colors.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/utils/default_foreground.dart';
import 'package:flutter_omarchy/src/widgets/utils/pointer_area.dart';

class OmarchyButtonStyleData {
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
  final Duration transitionDuration;
  final EdgeInsetsGeometry padding;
  final double borderWidth;
  final OmarchyButtonStyleStateData normal;
  final OmarchyButtonStyleStateData focused;
  final OmarchyButtonStyleStateData pressed;
  final OmarchyButtonStyleStateData disabled;
  final OmarchyButtonStyleStateData hovering;

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

typedef OmarchyButtonStyleStateData = ({
  Color border,
  Color foreground,
  Color background,
});

class OmarchyButtonTheme extends InheritedWidget {
  const OmarchyButtonTheme({
    super.key,
    required super.child,
    required this.data,
  });

  final OmarchyButtonStyle data;

  static OmarchyButtonStyle? maybeOf(BuildContext context) {
    final theme = context
        .dependOnInheritedWidgetOfExactType<OmarchyButtonTheme>();
    return theme?.data;
  }

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

abstract class OmarchyButtonStyle {
  const OmarchyButtonStyle();
  const factory OmarchyButtonStyle.outline(
    AnsiColor accent, {
    EdgeInsetsGeometry padding,
    double borderWidth,
  }) = OutlineOmarchyButtonStyle;

  const factory OmarchyButtonStyle.filled(
    AnsiColor accent, {
    EdgeInsetsGeometry padding,
  }) = FilledOmarchyButtonStyle;

  const factory OmarchyButtonStyle.bar([AnsiColor accent]) =
      BarOmarchyButtonStyle;

  const factory OmarchyButtonStyle.custom(OmarchyButtonStyleData data) =
      CustomOmarchyButtonStyle;

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

class OmarchyButton extends StatelessWidget {
  const OmarchyButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding = const EdgeInsets.all(16),
    this.style,
    this.focusNode,
    this.borderWidth,
  });

  final Widget child;
  final OmarchyButtonStyle? style;
  final EdgeInsets padding;
  final VoidCallback? onPressed;
  final FocusNode? focusNode;
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
