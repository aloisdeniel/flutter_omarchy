import 'package:flutter/material.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';

class OmarchyTooltip extends StatelessWidget {
  const OmarchyTooltip({
    super.key,
    required this.child,
    this.richMessage,
    this.message,
  });

  final String? message;
  final InlineSpan? richMessage;
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
