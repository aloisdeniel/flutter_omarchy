import 'package:flutter/material.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';

/// A tooltip widget that displays helpful information on hover.
///
/// This tooltip provides contextual information when users hover over
/// the child widget. It's styled to match the Omarchy design system
/// with dark backgrounds and themed text colors.
///
/// {@tool snippet}
/// ```dart
/// OmarchyTooltip(
///   message: 'This button saves your work',
///   child: IconButton(
///     icon: Icon(Icons.save),
///     onPressed: () => save(),
///   ),
/// )
/// ```
/// {@end-tool}
class OmarchyTooltip extends StatelessWidget {
  /// Creates a tooltip with the specified [child] and [message].
  const OmarchyTooltip({
    super.key,
    required this.child,
    this.richMessage,
    this.message,
  });

  /// The plain text message to display in the tooltip.
  final String? message;
  
  /// A rich text message to display in the tooltip.
  ///
  /// If both [message] and [richMessage] are provided, [richMessage] takes precedence.
  final InlineSpan? richMessage;
  
  /// The widget that triggers the tooltip when hovered.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return Tooltip(
      message: message,
      decoration: BoxDecoration(color: theme.colors.normal.black),
      textStyle: theme.text.normal.copyWith(color: theme.colors.bright.white),
      richMessage: richMessage,
      child: child,
    );
  }
}
