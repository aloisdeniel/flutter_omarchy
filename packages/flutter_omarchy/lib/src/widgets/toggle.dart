import 'package:flutter_omarchy/flutter_omarchy.dart';

class OmarchyToggle extends StatelessWidget {
  const OmarchyToggle({
    super.key,
    this.value = false,
    this.accent,
    this.onPressed,
  });
  final bool value;

  /// The accent color to use for the checkbox when selected.
  ///
  /// If null, uses the theme's default foreground color.
  final AnsiColor? accent;

  /// The callback executed when the checkbox is pressed.
  final VoidCallback? onPressed;

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
      builder: (context, state, child) {
        final fill = switch (state) {
          PointerState(isHovering: true) when value =>
            theme.colors.bright.white,
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
                  : (state.isHovering ? foreground : theme.colors.normal.white),
              borderRadius: BorderRadius.circular(1),
            ),
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 120),
            height: size.height - 4,
            width: (state.isHovering ? 2 : 0) + size.height - 4,
          ),
        );
      },
    );
  }
}
