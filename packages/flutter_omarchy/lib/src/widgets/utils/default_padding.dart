import 'package:flutter/widgets.dart';

/// An inherited widget that provides default padding values to descendants.
///
/// This widget allows you to establish consistent padding throughout a widget
/// subtree. Descendant widgets can access the padding using the static methods.
///
/// {@tool snippet}
/// ```dart
/// DefaultPadding(
///   padding: EdgeInsets.all(16),
///   child: Column(
///     children: [
///       SomeWidget(), // Can access the padding via DefaultPadding.of(context)
///       AnotherWidget(),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
class DefaultPadding extends InheritedWidget {
  /// Creates a default padding provider with the specified [padding].
  const DefaultPadding({
    super.key,
    required super.child,
    required this.padding,
  });

  /// The padding value to provide to descendants.
  final EdgeInsetsGeometry padding;

  /// Returns the padding from the closest [DefaultPadding] ancestor,
  /// or null if no such ancestor exists.
  static EdgeInsetsGeometry? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DefaultPadding>()
        ?.padding;
  }

  /// Returns the padding from the closest [DefaultPadding] ancestor,
  /// or [EdgeInsets.zero] if no such ancestor exists.
  static EdgeInsetsGeometry of(BuildContext context) {
    return maybeOf(context) ?? EdgeInsets.zero;
  }

  @override
  bool updateShouldNotify(covariant DefaultPadding oldWidget) {
    return padding != oldWidget.padding;
  }
}
