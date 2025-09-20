import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';
import 'package:flutter_omarchy/src/theme/colors.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/icon_data.g.dart';

enum CheckboxState { checked, unchecked, multiple }

class OmarchyCheckbox extends StatelessWidget {
  const OmarchyCheckbox({
    super.key,
    CheckboxState? state,
    bool isChecked = false,
    this.accent,
    this.size,
    this.onPressed,
  }) : state =
           state ??
           (isChecked ? CheckboxState.checked : CheckboxState.unchecked);

  final CheckboxState state;
  final AnsiColor? accent;
  final double? size;
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
      builder: (context, state, child) {
        final border = switch (state) {
          PointerState(isHovering: true) when isSelected =>
            foreground.withValues(alpha: foreground.a * 0.9),
          PointerState(isHovering: true) => foreground.withValues(
            alpha: foreground.a * 0.6,
          ),
          _ when isSelected => foreground,
          _ => theme.colors.normal.white,
        };
        final fill = switch (state) {
          PointerState(isHovering: true) when isSelected =>
            background.withValues(alpha: background.a * 0.6),
          PointerState(isHovering: true) => background.withValues(
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
