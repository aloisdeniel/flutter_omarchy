import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/widgets/resize_divider.dart';
import 'package:flutter_omarchy/src/widgets/utils/panel_size.dart';

/// A resizable split panel layout widget.
///
/// This widget creates a layout with two areas separated by a draggable
/// divider. Users can resize the panels by dragging the divider, making
/// it ideal for implementing sidebars, inspector panels, and other
/// resizable layouts common in desktop applications.
///
/// {@tool snippet}
/// ```dart
/// OmarchySplitPanel(
///   panel: NavigationPanel(),
///   child: MainContent(),
///   panelInitialSize: PanelSize.ratio(0.25),
///   minPanelSize: PanelSize.absolute(200),
///   maxPanelSize: PanelSize.absolute(400),
/// )
/// ```
/// {@end-tool}
class OmarchySplitPanel extends StatefulWidget {
  /// Creates a split panel with the specified [panel] and [child].
  const OmarchySplitPanel({
    super.key,
    required this.panel,
    required this.child,
    this.panelInitialSize = const PanelSize.absolute(200),
    this.direction = TextDirection.ltr,
    this.orientation = Axis.horizontal,
    this.minPanelSize,
    this.maxPanelSize,
  });

  /// The text direction that determines panel positioning.
  ///
  /// When [TextDirection.ltr], the panel appears on the left (or top).
  /// When [TextDirection.rtl], the panel appears on the right (or bottom).
  final TextDirection direction;
  
  /// The orientation of the split layout.
  ///
  /// [Axis.horizontal] creates a vertical split with panels side by side.
  /// [Axis.vertical] creates a horizontal split with panels stacked.
  final Axis orientation;
  
  /// The panel widget (typically a sidebar or secondary content area).
  final Widget panel;
  
  /// The main content widget.
  final Widget child;
  
  /// The initial size of the panel.
  final PanelSize panelInitialSize;
  
  /// The minimum size the panel can be resized to.
  final PanelSize? minPanelSize;
  
  /// The maximum size the panel can be resized to.
  final PanelSize? maxPanelSize;

  @override
  State<OmarchySplitPanel> createState() => _OmarchySplitPanelState();
}

class _OmarchySplitPanelState extends State<OmarchySplitPanel> {
  final childKey = GlobalKey();
  final panelKey = GlobalKey();
  late var panelSize = widget.panelInitialSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, layout) {
        final maxSize =
            switch (widget.orientation) {
              Axis.horizontal => layout.maxWidth,
              Axis.vertical => layout.maxHeight,
            } -
            OmarchyResizeDivider.calculateSize(context);
        final panelMinSize = (widget.minPanelSize?.resolve(maxSize) ?? 0.0)
            .clamp(0.0, maxSize);
        final panelMaxSize = (widget.maxPanelSize?.resolve(maxSize) ?? maxSize)
            .clamp(panelMinSize, maxSize);
        final panelSizePoints = panelSize
            .resolve(maxSize)
            .clamp(panelMinSize, panelMaxSize);
        var children = [
          switch (widget.orientation) {
            Axis.horizontal => SizedBox(
              key: panelKey,
              width: panelSizePoints,
              child: widget.panel,
            ),
            Axis.vertical => SizedBox(
              key: panelKey,
              height: panelSizePoints,
              child: widget.panel,
            ),
          },
          OmarchyResizeDivider(
            key: Key('divider'),
            min: panelMinSize,
            max: panelMaxSize,
            size: panelSizePoints,
            orientation: widget.orientation,
            onSizeChanged: (v) {
              if (widget.direction == TextDirection.rtl) {
                v = -v;
              }
              final requested = (panelSizePoints + v).clamp(
                panelMinSize,
                panelMaxSize,
              );
              final newSize = panelSize.addDelta(
                maxSize,
                requested - panelSizePoints,
              );
              if (panelSize != newSize) {
                setState(() {
                  panelSize = newSize;
                });
              }
            },
          ),
          Expanded(key: childKey, child: widget.child),
        ];

        if (widget.direction == TextDirection.rtl) {
          children = children.reversed.toList();
        }

        return switch (widget.orientation) {
          Axis.horizontal => Row(
            textDirection: TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
          Axis.vertical => Column(
            verticalDirection: VerticalDirection.down,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        };
      },
    );
  }
}
