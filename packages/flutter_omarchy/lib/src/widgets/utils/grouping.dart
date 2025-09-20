import 'package:flutter/material.dart';

typedef GroupingPosition = (int index, int total);

extension GroupingPositionExtension on GroupingPosition? {
  bool get isLast {
    final self = this;
    return self == null || self.$2 - 1 == self.$1;
  }

  bool get isFirst {
    final self = this;
    return self == null || self.$1 == 0;
  }

  bool get isMiddle => !isFirst && !isLast;
  bool get isOnly => isFirst && isLast;

  BorderRadius asBorderRadius(Radius radius) {
    return BorderRadius.vertical(
      top: isFirst ? radius : Radius.zero,
      bottom: isLast ? radius : Radius.zero,
    );
  }
}

extension GroupingListExtension on List<Widget> {
  Iterable<Widget> group() sync* {
    final total = length;
    for (var i = 0; i < total; i++) {
      final position = (i, total);
      yield Grouping(position: position, child: this[i]);
    }
  }
}

class Grouping extends InheritedWidget {
  const Grouping({super.key, required this.position, required super.child});
  final GroupingPosition position;

  static GroupingPosition? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Grouping>()?.position;
  }

  static GroupingPosition of(BuildContext context) {
    final position = maybeOf(context);
    if (position == null) {
      throw Exception('Grouping not found in context');
    }
    return position;
  }

  @override
  bool updateShouldNotify(Grouping oldWidget) {
    return position != oldWidget.position;
  }
}
