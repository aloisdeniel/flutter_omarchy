import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/utils/default_foreground.dart';
import 'package:flutter_omarchy/src/widgets/utils/pointer_area.dart';
import 'package:flutter_omarchy/src/widgets/utils/selected.dart';

/// A list item widget that displays a title and optional description.
///
/// This tile provides consistent styling for list items with support for
/// interaction feedback and selection states. It's commonly used in
/// navigation panels, file explorers, and settings screens.
///
/// {@tool snippet}
/// ```dart
/// OmarchyTile(
///   title: Text('Settings'),
///   description: Text('Configure application preferences'),
///   onTap: () => Navigator.push(context, SettingsPage()),
/// )
/// ```
/// {@end-tool}
class OmarchyTile extends StatelessWidget {
  /// Creates a tile with the specified [title] and optional [description].
  const OmarchyTile({
    super.key,
    required this.title,
    this.description,
    this.onTap,
  });

  /// The primary content displayed in the tile.
  final Widget title;
  
  /// Optional secondary content displayed below the title.
  final Widget? description;
  
  /// The callback executed when the tile is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    var child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [title, if (description case final description?) description],
    );
    final isSelected = Selected.of(context);
    return SizedBox(
      height: theme.text.normal.fontSize! * 4,
      child: PointerArea(
        onTap: onTap,
        child: child,
        builder: (context, state, child) {
          final background = theme.colors.normal.black;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: switch (state) {
                PointerState(isPressed: true) => background,
                PointerState(isHovering: true) => background.withValues(
                  alpha: 0.5,
                ),
                _ => background.withValues(alpha: 0),
              },
            ),
            padding: const EdgeInsets.all(16),
            child: DefaultForeground(
              textStyle: switch (isSelected) {
                true => theme.text.italic,
                false => theme.text.normal,
              },
              foreground: switch (state) {
                _ when isSelected => theme.colors.selectedText,
                PointerState(isPressed: true) => theme.colors.selectedText,
                PointerState(isHovering: true) => theme.colors.selectedText,
                _ => theme.colors.foreground,
              },
              child: child!,
            ),
          );
        },
      ),
    );
  }
}
