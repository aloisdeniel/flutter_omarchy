import 'package:flutter/widgets.dart';

class DefaultPadding extends InheritedWidget {
  const DefaultPadding({
    super.key,
    required super.child,
    required this.padding,
  });

  final EdgeInsetsGeometry padding;

  static EdgeInsetsGeometry? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DefaultPadding>()
        ?.padding;
  }

  static EdgeInsetsGeometry of(BuildContext context) {
    return maybeOf(context) ?? EdgeInsets.zero;
  }

  @override
  bool updateShouldNotify(covariant DefaultPadding oldWidget) {
    return padding != oldWidget.padding;
  }
}
