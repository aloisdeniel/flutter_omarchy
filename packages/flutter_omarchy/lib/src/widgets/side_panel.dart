import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/utils/panel_size.dart';

class OmarchySidePanelController extends ChangeNotifier {
  OmarchySidePanelController();

  final _overlay = OverlayPortalController();

  var _isVisible = false;

  bool get isVisible => _isVisible;
  set isVisible(bool v) {
    if (_isVisible != v) {
      _isVisible = v;
      _updateOverlay();
      notifyListeners();
    }
  }

  void _updateOverlay() {
    if (_isVisible && !_overlay.isShowing) {
      _overlay.show();
    } else if (!_isVisible && _overlay.isShowing) {
      _overlay.hide();
    }
  }
}

class OmarchySidePanel extends StatefulWidget {
  const OmarchySidePanel({
    super.key,
    required this.panel,
    required this.child,
    this.controller,
    this.panelSize = const PanelSize.ratio(0.3),
    this.minPanelSize = const PanelSize.absolute(300),
    this.direction = TextDirection.ltr,
    this.orientation = Axis.horizontal,
    this.minPanelMargin = 64.0,
  });

  static OmarchySidePanelController controllerOf(BuildContext context) {
    final state = context.findAncestorStateOfType<_OmarchySplitPanelState>();
    if (state == null) {
      throw Exception(
        'No OmarchySplitPanel found in context. Make sure to wrap your widget with OmarchySplitPanel.',
      );
    }
    return state._controller;
  }

  final OmarchySidePanelController? controller;

  /// The panel is at the start.
  final TextDirection direction;
  final Axis orientation;
  final Widget panel;
  final Widget child;
  final PanelSize panelSize;
  final PanelSize? minPanelSize;
  final double minPanelMargin;

  @override
  State<OmarchySidePanel> createState() => _OmarchySplitPanelState();
}

class _OmarchySplitPanelState extends State<OmarchySidePanel> {
  final childKey = GlobalKey();
  final panelKey = GlobalKey();
  late var _controller = widget.controller ?? OmarchySidePanelController();

  @override
  void initState() {
    super.initState();
    if (_controller.isVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller._overlay.show();
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant OmarchySidePanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      _controller.dispose();
      setState(() {
        _controller = widget.controller ?? OmarchySidePanelController();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);

    return OverlayPortal(
      controller: _controller._overlay,
      overlayChildBuilder: (context) {
        return Positioned.fill(
          child: LayoutBuilder(
            builder: (context, layout) {
              final maxSize =
                  layout.maxWidth -
                  (layout.maxWidth < widget.minPanelMargin
                      ? 0.0
                      : widget.minPanelMargin);
              final minSize = widget.minPanelSize?.resolve(maxSize) ?? 0.0;
              final panelSize = max(minSize, widget.panelSize.resolve(maxSize));
              return Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: const Color(0x33000000),
                      child: GestureDetector(
                        onTap: () {
                          _controller.isVisible = false;
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: panelSize,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colors.background,
                        border: Border(
                          right: BorderSide(
                            color: theme.colors.border,
                            width: 2,
                          ),
                        ),
                      ),
                      child: widget.panel,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
      child: KeyedSubtree(key: childKey, child: widget.child),
    );
  }
}
