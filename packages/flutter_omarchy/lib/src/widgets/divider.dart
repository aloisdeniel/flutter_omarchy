import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';

/// A divider widget that creates visual separation between content areas.
///
/// This widget renders a thin line that can be oriented horizontally or
/// vertically to separate content sections. The color is automatically
/// themed based on the current Omarchy theme.
///
/// {@tool snippet}
/// ```dart
/// Column(
///   children: [
///     Text('Section 1'),
///     OmarchyDivider.horizontal(),
///     Text('Section 2'),
///   ],
/// )
/// ```
/// {@end-tool}
class OmarchyDivider extends StatelessWidget {
  /// Creates a divider with the specified [direction].
  const OmarchyDivider({super.key, this.direction});

  /// Creates a horizontal divider: a full-width, one pixel tall line,
  /// typically used between the children of a [Column].
  const OmarchyDivider.horizontal({super.key}) : direction = Axis.horizontal;

  /// Creates a vertical divider: a full-height, one pixel wide line,
  /// typically used between the children of a [Row].
  const OmarchyDivider.vertical({super.key}) : direction = Axis.vertical;

  /// The axis along which the divider line extends.
  ///
  /// If null, defaults to [Axis.horizontal].
  final Axis? direction;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final direction = this.direction ?? Axis.horizontal;
    return Container(
      width: switch (direction) {
        Axis.horizontal => double.infinity,
        Axis.vertical => 1.0,
      },
      height: switch (direction) {
        Axis.horizontal => 1.0,
        Axis.vertical => double.infinity,
      },
      color: theme.colors.normal.black,
    );
  }
}
