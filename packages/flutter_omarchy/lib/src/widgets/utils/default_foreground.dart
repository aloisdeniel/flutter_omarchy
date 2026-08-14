import 'package:flutter/widgets.dart';

/// A utility widget that applies default foreground colors to text and icons.
///
/// This widget ensures consistent foreground styling by applying the specified
/// color to both text and icon themes for its descendants. It's commonly used
/// in themed components to maintain color consistency.
///
/// {@tool snippet}
/// ```dart
/// DefaultForeground(
///   foreground: Colors.white,
///   child: Row(
///     children: [
///       Icon(Icons.star), // Will be white
///       Text('Rating'), // Will be white
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
class DefaultForeground extends StatelessWidget {
  /// Creates a default foreground widget with the specified color and child.
  const DefaultForeground({
    super.key,
    required this.foreground,
    required this.child,
    this.textStyle,
    this.iconSize,
  });

  /// The child widget to apply foreground styling to.
  final Widget child;
  
  /// The foreground color to apply to text and icons.
  final Color? foreground;
  
  /// Optional text style to merge with the color.
  final TextStyle? textStyle;
  
  /// Optional icon size. If null, calculated based on text style.
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
