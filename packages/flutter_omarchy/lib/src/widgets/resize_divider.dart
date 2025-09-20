import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/utils/pointer_area.dart';

class OmarchyResizeDivider extends StatefulWidget {
  const OmarchyResizeDivider({
    super.key,

    required this.size,
    required this.min,
    required this.max,
    required this.onSizeChanged,
    this.orientation = Axis.horizontal,
  });

  static double calculateSize(BuildContext context) {
    // TODO mobile responsive
    return 5;
  }

  final Axis orientation;
  final double size;
  final double min;
  final double max;

  /// The delta that must be added to the current size.
  final ValueChanged<double> onSizeChanged;

  @override
  State<OmarchyResizeDivider> createState() => _OmarchyResizeDividerState();
}

class _OmarchyResizeDividerState extends State<OmarchyResizeDivider> {
  late double current;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return PointerArea(
      hoverCursor: SystemMouseCursors.resizeLeftRight,
      onPanStart: (_) {
        current = widget.size;
      },
      onPanUpdate: (details) {
        final delta = switch (widget.orientation) {
          Axis.horizontal => details.delta.dx,
          Axis.vertical => details.delta.dy,
        };
        widget.onSizeChanged(delta);
      },
      builder: (context, pointer, _) => Container(
        margin: switch (widget.orientation) {
          Axis.horizontal => EdgeInsets.symmetric(horizontal: 2.0),
          Axis.vertical => EdgeInsets.symmetric(vertical: 2.0),
        },
        // TODO mobile responsive
        width: switch (widget.orientation) {
          Axis.horizontal => 1,
          Axis.vertical => double.infinity,
        },
        height: switch (widget.orientation) {
          Axis.vertical => 1,
          Axis.horizontal => double.infinity,
        },
        color: switch (pointer) {
          PointerState(isPressed: true) => theme.colors.bright.white,
          PointerState(isHovering: true) => theme.colors.bright.black,
          _ => theme.colors.normal.black,
        },
      ),
    );
  }
}
