import 'package:flutter/widgets.dart';

class Selected extends InheritedWidget {
  const Selected({super.key, required super.child, this.isSelected = false});

  final bool isSelected;

  static bool of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Selected>()?.isSelected ??
        false;
  }

  @override
  bool updateShouldNotify(covariant Selected oldWidget) {
    return isSelected != oldWidget.isSelected;
  }
}
