import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/widgets/resize_divider.dart';
import 'package:flutter_omarchy/src/widgets/utils/panel_size.dart';

class OmarchySplitPanel extends StatefulWidget {
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

  /// The panel is at the start.
  final TextDirection direction;
  final Axis orientation;
  final Widget panel;
  final Widget child;
  final PanelSize panelInitialSize;
  final PanelSize? minPanelSize;
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
            .clamp(0.0, maxSize);
        final panelSizePoints = panelSize.resolve(panelMaxSize);
        var children = [
          SizedBox(key: panelKey, width: panelSizePoints, child: widget.panel),
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
              final newSize = panelSize.addDelta(maxSize, v);
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
