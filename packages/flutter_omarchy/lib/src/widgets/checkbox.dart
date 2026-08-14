import 'package:flutter_omarchy/flutter_omarchy.dart';

/// Represents the visual state of a checkbox.
enum CheckboxState {
  /// The checkbox is checked (shows a checkmark).
  checked,

  /// The checkbox is unchecked (empty).
  unchecked,

  /// The checkbox represents multiple selections (shows a filled square).
  multiple,
}

/// A customizable checkbox widget following the Omarchy design system.
///
/// This checkbox supports three states: checked, unchecked, and multiple.
/// It provides visual feedback for hover and press interactions and can be
/// styled with different accent colors.
///
/// {@tool snippet}
/// ```dart
/// OmarchyCheckbox(
///   state: CheckboxState.checked,
///   accent: AnsiColor.blue,
///   onPressed: () => setState(() => isChecked = !isChecked),
/// )
/// ```
/// {@end-tool}
class OmarchyCheckbox extends StatelessWidget {
  /// Creates an Omarchy checkbox with the specified state and styling.
  const OmarchyCheckbox({
    super.key,
    CheckboxState? state,
    bool isChecked = false,
    this.accent,
    this.size,
    this.onPressed,
    this.focusNode,
  }) : state =
           state ??
           (isChecked ? CheckboxState.checked : CheckboxState.unchecked);

  /// The current state of the checkbox.
  final CheckboxState state;

  /// The focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// The accent color to use for the checkbox when selected.
  ///
  /// If null, uses the theme's default foreground color.
  final AnsiColor? accent;

  /// The size of the checkbox.
  ///
  /// If null, calculates the size based on the current text style.
  final double? size;

  /// The callback executed when the checkbox is pressed.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final foreground = accent != null
        ? theme.colors.bright[accent!]
        : theme.colors.foreground;
    final background = accent != null
        ? theme.colors.normal[accent!].withValues(alpha: 0.4)
        : theme.colors.bright.black;
    final isSelected = switch (state) {
      CheckboxState.unchecked => false,
      CheckboxState.checked || CheckboxState.multiple => true,
    };
    final size = this.size ?? (theme.text.normal.fontSize ?? 12) * 1.2;
    return PointerArea(
      onTap: onPressed,
      focusNode: focusNode,
      builder: (context, state, child) {
        final highlighted = state.isHovering || state.hasFocus;
        final border = switch (state) {
          _ when highlighted && isSelected => foreground.withValues(
            alpha: foreground.a * 0.9,
          ),
          _ when highlighted => foreground.withValues(
            alpha: foreground.a * 0.6,
          ),
          _ when isSelected => foreground,
          _ => theme.colors.normal.white,
        };
        final fill = switch (state) {
          _ when highlighted => background.withValues(
            alpha: background.a * 0.6,
          ),
          _ when isSelected => background,
          _ => theme.colors.normal.black,
        };
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: fill,
            border: Border.all(color: border, width: 2),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 120),
            child: IconTheme(
              data: IconThemeData(color: foreground, size: size * 0.6),
              child: switch (this.state) {
                CheckboxState.checked => const Icon(OmarchyIcons.codCheck),
                CheckboxState.unchecked => const SizedBox.shrink(),
                CheckboxState.multiple => Container(
                  color: foreground,
                  margin: const EdgeInsets.all(4.0),
                ),
              },
            ),
          ),
        );
      },
    );
  }
}
