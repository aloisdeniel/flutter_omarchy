import 'package:flutter/widgets.dart';

enum SidePosition { leading, trailing }

class SidePositioning extends InheritedWidget {
  const SidePositioning({
    super.key,
    required this.position,
    required super.child,
  });
  final SidePosition position;

  static SidePosition? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SidePositioning>()
        ?.position;
  }

  static SidePosition of(BuildContext context) {
    final position = maybeOf(context);
    if (position == null) {
      throw Exception('SidePositioning not found in context');
    }
    return position;
  }

  @override
  bool updateShouldNotify(SidePositioning oldWidget) {
    return position != oldWidget.position;
  }
}
