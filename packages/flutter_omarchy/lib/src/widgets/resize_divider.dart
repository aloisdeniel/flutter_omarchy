import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/utils/pointer_area.dart';

/// A draggable divider widget for resizing adjacent panels.
///
/// This widget provides a visual divider that users can drag to resize
/// adjacent content areas. It's commonly used in split panel layouts
/// to allow dynamic resizing of sidebars, inspector panels, and other
/// resizable content areas.
///
/// {@tool snippet}
/// ```dart
/// OmarchyResizeDivider(
///   size: currentPanelSize,
///   min: 200,
///   max: 600,
///   onSizeChanged: (delta) => updatePanelSize(delta),
///   orientation: Axis.horizontal,
/// )
/// ```
/// {@end-tool}
class OmarchyResizeDivider extends StatefulWidget {
  /// Creates a resize divider with the specified constraints and callback.
  const OmarchyResizeDivider({
    super.key,
    required this.size,
    required this.min,
    required this.max,
    required this.onSizeChanged,
    this.orientation = Axis.horizontal,
  });

  /// Calculates the size of the divider based on the current context.
  ///
  /// Currently returns a fixed size of 5 pixels.
  static double calculateSize(BuildContext context) {
    // TODO mobile responsive
    return 5;
  }

  /// The orientation of the divider.
  ///
  /// [Axis.horizontal] creates a vertical divider for horizontal resizing.
  /// [Axis.vertical] creates a horizontal divider for vertical resizing.
  final Axis orientation;
  
  /// The current size of the panel being resized.
  final double size;
  
  /// The minimum allowed size for the panel.
  final double min;
  
  /// The maximum allowed size for the panel.
  final double max;

  /// Callback that receives the delta change when the divider is dragged.
  ///
  /// The delta represents the amount of change to be added to the current size.
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
