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
    this.leading,
    this.trailing,
    this.onTap,
  });

  /// The primary content displayed in the tile.
  final Widget title;

  /// Optional secondary content displayed below the title.
  final Widget? description;

  /// An optional widget displayed at the start of the tile, such as an icon.
  final Widget? leading;

  /// An optional widget displayed at the end of the tile, such as a badge
  /// or a keyboard shortcut hint.
  final Widget? trailing;

  /// The callback executed when the tile is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final isSelected = Selected.of(context);
    return SizedBox(
      height: theme.text.normal.fontSize! * 4,
      child: PointerArea(
        onTap: onTap,
        builder: (context, state, child) {
          Widget child = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              title,
              if (description case final description?)
                DefaultForeground(
                  textStyle: switch (isSelected) {
                    true => theme.text.italic,
                    false => theme.text.normal,
                  }.copyWith(fontSize: 12),
                  foreground: switch (state) {
                    _ when isSelected => theme.colors.selectedText,
                    PointerState(isPressed: true) => theme.colors.selectedText,
                    PointerState(isHovering: true) => theme.colors.selectedText,
                    _ => theme.colors.bright.black,
                  },
                  child: description,
                ),
            ],
          );
          if (leading != null || trailing != null) {
            child = Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                if (leading case final leading?)
                  IconTheme(
                    data: IconThemeData(
                      color: switch (state) {
                        _ when isSelected => theme.colors.selectedText,
                        PointerState(isPressed: true) =>
                          theme.colors.selectedText,
                        PointerState(isHovering: true) =>
                          theme.colors.selectedText,
                        _ => theme.colors.bright.black,
                      },
                      size: 22,
                    ),
                    child: leading,
                  ),
                Expanded(child: child),
                if (trailing case final trailing?)
                  DefaultForeground(
                    foreground: theme.colors.bright.black,
                    child: trailing,
                  ),
              ],
            );
          }
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
              child: child,
            ),
          );
        },
      ),
    );
  }
}
