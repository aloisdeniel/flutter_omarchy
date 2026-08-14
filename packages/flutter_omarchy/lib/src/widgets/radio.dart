import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/colors.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/utils/pointer_area.dart';

/// A radio button for selecting a single value out of a group.
///
/// The radio is selected when [value] equals [groupValue]. Selecting a radio
/// calls [onChanged] with its [value].
///
/// {@tool snippet}
/// ```dart
/// Column(
///   children: [
///     for (final option in ['small', 'medium', 'large'])
///       Row(
///         children: [
///           OmarchyRadio<String>(
///             value: option,
///             groupValue: size,
///             onChanged: (v) => setState(() => size = v),
///           ),
///           Text(option),
///         ],
///       ),
///   ],
/// )
/// ```
/// {@end-tool}
class OmarchyRadio<T> extends StatelessWidget {
  /// Creates a radio button representing [value].
  const OmarchyRadio({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.accent,
    this.size,
    this.focusNode,
  });

  /// The value represented by this radio button.
  final T value;

  /// The currently selected value of the group.
  final T? groupValue;

  /// Called with [value] when this radio is selected.
  ///
  /// If null, the radio is disabled.
  final ValueChanged<T>? onChanged;

  /// The accent color to use when selected.
  ///
  /// If null, uses the theme's default foreground color.
  final AnsiColor? accent;

  /// The size of the radio button.
  ///
  /// If null, calculates the size based on the current text style.
  final double? size;

  /// The focus node for keyboard navigation.
  final FocusNode? focusNode;

  bool get _isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final foreground = accent != null
        ? theme.colors.bright[accent!]
        : theme.colors.foreground;
    final background = accent != null
        ? theme.colors.normal[accent!].withValues(alpha: 0.4)
        : theme.colors.bright.black;
    final size = this.size ?? (theme.text.normal.fontSize ?? 12) * 1.2;
    final isSelected = _isSelected;
    return PointerArea(
      onTap: onChanged != null && !isSelected
          ? () => onChanged!(value)
          : null,
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
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            border: Border.all(color: border, width: 2),
            borderRadius: BorderRadius.circular(size),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: isSelected ? size * 0.35 : 0,
            height: isSelected ? size * 0.35 : 0,
            decoration: BoxDecoration(
              color: foreground,
              borderRadius: BorderRadius.circular(size),
            ),
          ),
        );
      },
    );
  }
}
