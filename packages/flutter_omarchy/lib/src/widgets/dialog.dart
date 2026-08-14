import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/colors.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/button.dart';
import 'package:flutter_omarchy/src/widgets/divider.dart';

/// A modal dialog container following the Omarchy design system.
///
/// The dialog displays an optional [title], a [content] area, and a row of
/// [actions] (typically [OmarchyButton]s). It is usually presented with
/// [showOmarchyDialog].
///
/// {@tool snippet}
/// ```dart
/// showOmarchyDialog<void>(
///   context: context,
///   builder: (context) => OmarchyDialog(
///     title: Text('Delete file'),
///     content: Text('This action cannot be undone.'),
///     actions: [
///       OmarchyButton(
///         child: Text('Cancel'),
///         onPressed: () => Navigator.of(context).pop(),
///       ),
///       OmarchyButton(
///         style: OmarchyButtonStyle.filled(AnsiColor.red),
///         child: Text('Delete'),
///         onPressed: () => Navigator.of(context).pop(),
///       ),
///     ],
///   ),
/// );
/// ```
/// {@end-tool}
class OmarchyDialog extends StatelessWidget {
  /// Creates an Omarchy dialog with the specified [content].
  const OmarchyDialog({
    super.key,
    required this.content,
    this.title,
    this.actions = const [],
    this.accent,
    this.maxWidth = 480,
    this.padding = const EdgeInsets.all(16),
  });

  /// The optional title displayed at the top of the dialog.
  final Widget? title;

  /// The main content of the dialog.
  final Widget content;

  /// The action buttons displayed at the bottom of the dialog.
  final List<Widget> actions;

  /// The accent color used for the dialog border and title.
  ///
  /// If null, uses the theme's border color.
  final AnsiColor? accent;

  /// The maximum width of the dialog.
  final double maxWidth;

  /// The padding applied around the title, content and actions.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final border = switch (accent) {
      AnsiColor accent => theme.colors.bright[accent],
      null => theme.colors.border,
    };
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: DefaultTextStyle(
          style: theme.text.normal.copyWith(color: theme.colors.foreground),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colors.background,
              border: Border.all(color: border, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title case final title?) ...[
                  Padding(
                    padding: padding,
                    child: DefaultTextStyle(
                      style: theme.text.bold.copyWith(
                        color: theme.colors.foreground,
                      ),
                      child: title,
                    ),
                  ),
                  const OmarchyDivider.horizontal(),
                ],
                Flexible(
                  child: SingleChildScrollView(
                    padding: padding,
                    child: content,
                  ),
                ),
                if (actions.isNotEmpty)
                  Padding(
                    padding: padding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 8,
                      children: actions,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows an Omarchy styled modal dialog.
///
/// The [builder] typically returns an [OmarchyDialog]. The returned future
/// completes with the value passed to [Navigator.pop] when the dialog is
/// closed, or null if it is dismissed.
///
/// When [barrierDismissible] is true (the default), tapping outside the
/// dialog or pressing Escape closes it.
Future<T?> showOmarchyDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color barrierColor = const Color(0x66000000),
  bool useRootNavigator = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: 'Dismiss',
    useRootNavigator: useRootNavigator,
    transitionDuration: const Duration(milliseconds: 120),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
  );
}

/// Shows a confirmation dialog with a message and two actions.
///
/// Returns true when the user confirms, false when they cancel, and null
/// when the dialog is dismissed.
Future<bool?> showOmarchyConfirmDialog({
  required BuildContext context,
  required Widget title,
  required Widget message,
  Widget confirmLabel = const Text('Confirm'),
  Widget cancelLabel = const Text('Cancel'),
  AnsiColor accent = AnsiColor.blue,
}) {
  return showOmarchyDialog<bool>(
    context: context,
    builder: (context) => OmarchyDialog(
      title: title,
      content: message,
      accent: accent,
      actions: [
        OmarchyButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: cancelLabel,
        ),
        OmarchyButton(
          style: OmarchyButtonStyle.filled(accent),
          autofocus: true,
          onPressed: () => Navigator.of(context).pop(true),
          child: confirmLabel,
        ),
      ],
    ),
  );
}
