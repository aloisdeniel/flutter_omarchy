import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/colors.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/utils/default_foreground.dart';
import 'package:flutter_omarchy/src/widgets/utils/grouping.dart';
import 'package:flutter_omarchy/src/widgets/utils/pointer_area.dart';
import 'package:flutter_omarchy/src/widgets/utils/side_positioning.dart';

/// A bottom status bar widget for displaying application status information.
///
/// This status bar provides leading and trailing areas for status indicators,
/// progress bars, notifications, and other status-related widgets. It features
/// horizontal scrolling and gradient effects to handle overflow gracefully.
///
/// {@tool snippet}
/// ```dart
/// OmarchyStatusBar(
///   leading: [
///     OmarchyStatus(child: Text('Ready'), accent: AnsiColor.green),
///     OmarchyStatus(child: Text('Line 42'), accent: AnsiColor.blue),
///   ],
///   trailing: [
///     OmarchyStatus(child: Text('UTF-8')),
///     OmarchyStatus(child: Text('100%')),
///   ],
/// )
/// ```
/// {@end-tool}
class OmarchyStatusBar extends StatelessWidget {
  /// Creates a status bar with optional [leading] and [trailing] widgets.
  const OmarchyStatusBar({super.key, this.leading, this.trailing});

  /// The leading status widgets displayed on the left side.
  ///
  /// These widgets scroll horizontally if they overflow the available space.
  final List<Widget>? leading;
  
  /// The trailing status widgets displayed on the right side.
  ///
  /// These widgets are displayed in reverse order to align right.
  final List<Widget>? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final height = theme.text.normal.fontSize! * 1.8;
    return Container(
      color: theme.colors.normal.black,
      height: height,
      child: DefaultTextStyle(
        style: DefaultTextStyle.of(context).style,
        maxLines: 1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (leading case final leading?)
              Expanded(
                child: SidePositioning(
                  position: SidePosition.leading,
                  child: Stack(
                    children: [
                      ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...leading.group(),
                          const SizedBox(width: 14),
                        ],
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colors.normal.black.withValues(alpha: 0),
                                theme.colors.normal.black,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(child: SizedBox()),
            if (trailing case final trailing?)
              Flexible(
                flex: 0,

                fit: FlexFit.tight,
                child: SidePositioning(
                  position: SidePosition.leading,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: trailing.group().toList().reversed.toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Deprecated enum for status colors. Use [AnsiColor] instead.
@Deprecated('Use AnsiColor instead')
enum OmarchyStatusColor { black, blue }

/// A status indicator widget for use within [OmarchyStatusBar].
///
/// This widget displays status information with colored backgrounds
/// and supports tap interactions. It's commonly used for showing
/// application state, cursor position, file encoding, and other
/// contextual information.
///
/// {@tool snippet}
/// ```dart
/// OmarchyStatus(
///   child: Text('Connected'),
///   accent: AnsiColor.green,
///   onTap: () => showConnectionDetails(),
/// )
/// ```
/// {@end-tool}
class OmarchyStatus extends StatelessWidget {
  /// Creates a status indicator with the specified [child] and styling.
  const OmarchyStatus({
    super.key,
    required this.child,
    this.accent = AnsiColor.white,
    this.onTap,
  });

  /// The content displayed within the status indicator.
  final Widget child;
  
  /// The accent color used for the background and text styling.
  final AnsiColor accent;
  
  /// An optional callback for tap interactions.
  ///
  /// If null, the status indicator is not interactive.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final normal = theme.colors.normal[accent];
    final bright = theme.colors.bright[accent];
    if (onTap != null) {
      return PointerArea(
        onTap: onTap,
        builder: (context, state, child) {
          return AnimatedContainer(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: switch (state) {
                PointerState(isPressed: true) => normal.withValues(alpha: 0.4),
                PointerState(isHovering: true) => normal.withValues(alpha: 0.3),
                _ => normal.withValues(alpha: 0.2),
              },
            ),
            child: DefaultForeground(
              foreground: bright,
              child: Center(child: this.child),
            ),
          );
        },
      );
    }
    return Container(
      color: normal.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DefaultForeground(
        foreground: bright,
        child: Center(child: child),
      ),
    );
  }
}
