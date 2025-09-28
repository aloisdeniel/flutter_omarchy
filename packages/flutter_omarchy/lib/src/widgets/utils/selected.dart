import 'package:flutter/widgets.dart';

/// An inherited widget that provides selection state to its descendants.
///
/// This widget allows you to mark a widget subtree as selected or unselected,
/// which can be used by descendant widgets to modify their appearance or
/// behavior based on the selection state.
///
/// {@tool snippet}
/// ```dart
/// Selected(
///   isSelected: true,
///   child: Container(
///     color: Selected.of(context) ? Colors.blue : Colors.grey,
///     child: Text('Selectable Item'),
///   ),
/// )
/// ```
/// {@end-tool}
class Selected extends InheritedWidget {
  /// Creates a selection state provider.
  const Selected({super.key, required super.child, this.isSelected = false});

  /// Whether the content is currently selected.
  final bool isSelected;

  /// Returns the selection state from the closest [Selected] ancestor.
  ///
  /// Returns false if no [Selected] ancestor is found.
  static bool of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Selected>()?.isSelected ??
        false;
  }

  @override
  bool updateShouldNotify(covariant Selected oldWidget) {
    return isSelected != oldWidget.isSelected;
  }
}
