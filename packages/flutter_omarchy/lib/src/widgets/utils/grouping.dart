import 'package:flutter/material.dart';

/// A record type representing the position of an item within a group.
///
/// The first element is the zero-based index, and the second is the total count.
typedef GroupingPosition = (int index, int total);

/// Extension methods for working with grouping positions.
extension GroupingPositionExtension on GroupingPosition? {
  /// Whether this is the last item in the group.
  bool get isLast {
    final self = this;
    return self == null || self.$2 - 1 == self.$1;
  }

  /// Whether this is the first item in the group.
  bool get isFirst {
    final self = this;
    return self == null || self.$1 == 0;
  }

  /// Whether this is a middle item (not first or last).
  bool get isMiddle => !isFirst && !isLast;
  
  /// Whether this is the only item in the group.
  bool get isOnly => isFirst && isLast;

  /// Converts the position to a [BorderRadius] for visual grouping.
  ///
  /// Applies the specified [radius] only to the top of the first item
  /// and the bottom of the last item, creating a visually grouped appearance.
  BorderRadius asBorderRadius(Radius radius) {
    return BorderRadius.vertical(
      top: isFirst ? radius : Radius.zero,
      bottom: isLast ? radius : Radius.zero,
    );
  }
}

/// Extension methods for adding grouping information to widget lists.
extension GroupingListExtension on List<Widget> {
  /// Wraps each widget in the list with grouping position information.
  ///
  /// This method is useful for creating visually grouped lists where items
  /// need to know their position within the group for styling purposes.
  Iterable<Widget> group() sync* {
    final total = length;
    for (var i = 0; i < total; i++) {
      final position = (i, total);
      yield Grouping(position: position, child: this[i]);
    }
  }
}

/// An inherited widget that provides grouping position information to descendants.
///
/// This widget is typically used with [GroupingListExtension.group] to provide
/// positional context that can be used for styling grouped items.
class Grouping extends InheritedWidget {
  /// Creates a grouping context with the specified [position].
  const Grouping({super.key, required this.position, required super.child});
  
  /// The position of this item within its group.
  final GroupingPosition position;

  /// Returns the grouping position from the closest [Grouping] ancestor,
  /// or null if no such ancestor exists.
  static GroupingPosition? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Grouping>()?.position;
  }

  /// Returns the grouping position from the closest [Grouping] ancestor.
  ///
  /// Throws an exception if no [Grouping] ancestor is found.
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
