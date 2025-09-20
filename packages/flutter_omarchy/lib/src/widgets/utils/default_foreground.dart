import 'package:flutter/widgets.dart';

class DefaultForeground extends StatelessWidget {
  const DefaultForeground({
    super.key,
    required this.foreground,
    required this.child,
    this.textStyle,
    this.iconSize,
  });

  final Widget child;
  final Color? foreground;
  final TextStyle? textStyle;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final textStyle = this.textStyle ?? DefaultTextStyle.of(context).style;
    final iconSize = this.iconSize ?? ((textStyle.fontSize ?? 12) * 1.1);
    return DefaultTextStyle.merge(
      style: textStyle.copyWith(color: foreground),
      child: IconTheme(
        data: IconThemeData(color: foreground, size: iconSize),
        child: child,
      ),
    );
  }
}
