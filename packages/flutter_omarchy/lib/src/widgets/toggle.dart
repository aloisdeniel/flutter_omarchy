import 'package:flutter_omarchy/flutter_omarchy.dart';

/// A toggle switch widget following the Omarchy design system.
///
/// This toggle represents an on/off state with a sliding knob. It provides
/// visual feedback for hover and focus interactions and can be styled with
/// different accent colors.
///
/// {@tool snippet}
/// ```dart
/// OmarchyToggle(
///   value: isEnabled,
///   accent: AnsiColor.green,
///   onPressed: () => setState(() => isEnabled = !isEnabled),
/// )
/// ```
/// {@end-tool}
class OmarchyToggle extends StatelessWidget {
  /// Creates an Omarchy toggle with the specified [value] and styling.
  const OmarchyToggle({
    super.key,
    this.value = false,
    this.accent,
    this.onPressed,
    this.focusNode,
  });

  /// Whether the toggle is on.
  final bool value;

  /// The accent color to use for the toggle when on.
  ///
  /// If null, uses the theme's default foreground color.
  final AnsiColor? accent;

  /// The callback executed when the toggle is pressed.
  final VoidCallback? onPressed;

  /// The focus node for keyboard navigation.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final foreground = accent != null
        ? theme.colors.normal[accent!]
        : theme.colors.foreground;
    final background = accent != null
        ? theme.colors.bright[accent!]
        : theme.colors.bright.white;
    const size = Size(28, 14);
    return PointerArea(
      onTap: onPressed,
      focusNode: focusNode,
      builder: (context, state, child) {
        final highlighted = state.isHovering || state.hasFocus;
        final fill = switch (state) {
          _ when highlighted && value => theme.colors.bright.white,
          _ when value => background,
          _ => theme.colors.normal.black,
        };
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeInOut,
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          padding: const EdgeInsets.all(2),
          child: AnimatedContainer(
            decoration: BoxDecoration(
              color: value
                  ? theme.colors.normal.black
                  : (highlighted ? foreground : theme.colors.normal.white),
              borderRadius: BorderRadius.circular(1),
            ),
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 120),
            height: size.height - 4,
            width: (highlighted ? 2 : 0) + size.height - 4,
          ),
        );
      },
    );
  }
}
