import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/colors.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/utils/default_foreground.dart';

/// A small label used to highlight a status or a count.
///
/// Badges use the terminal color palette: a subtle tinted background with a
/// bright foreground.
///
/// {@tool snippet}
/// ```dart
/// Row(
///   children: [
///     OmarchyBadge(accent: AnsiColor.green, child: Text('STABLE')),
///     OmarchyBadge.count(3, accent: AnsiColor.red),
///   ],
/// )
/// ```
/// {@end-tool}
class OmarchyBadge extends StatelessWidget {
  /// Creates a badge with the specified [child].
  const OmarchyBadge({
    super.key,
    required this.child,
    this.accent = AnsiColor.white,
    this.outlined = false,
  });

  /// Creates a badge displaying [count].
  ///
  /// When [max] is provided and [count] exceeds it, displays `max+`
  /// (e.g. `99+`).
  OmarchyBadge.count(
    int count, {
    super.key,
    this.accent = AnsiColor.white,
    this.outlined = false,
    int? max,
  }) : child = Text(max != null && count > max ? '$max+' : '$count');

  /// The content of the badge, typically a short [Text].
  final Widget child;

  /// The accent color of the badge.
  final AnsiColor accent;

  /// Whether to display a border instead of a filled background.
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final normal = theme.colors.normal[accent];
    final bright = theme.colors.bright[accent];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: outlined ? null : normal.withValues(alpha: 0.25),
        border: outlined ? Border.all(color: normal, width: 1) : null,
      ),
      child: DefaultForeground(
        foreground: bright,
        textStyle: theme.text.bold.copyWith(
          fontSize: (theme.text.normal.fontSize ?? 14) - 2,
        ),
        child: child,
      ),
    );
  }
}
