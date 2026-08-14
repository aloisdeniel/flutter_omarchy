import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/utils/panel_size.dart';

/// Controller for managing the visibility state of an [OmarchySidePanel].
///
/// This controller provides programmatic control over side panel visibility
/// and notifies listeners when the state changes.
class OmarchySidePanelController extends ChangeNotifier {
  /// Creates a side panel controller.
  OmarchySidePanelController();

  final _overlay = OverlayPortalController();

  var _isVisible = false;

  /// Whether the side panel is currently visible.
  bool get isVisible => _isVisible;
  
  /// Sets the visibility of the side panel.
  ///
  /// Setting this property will show or hide the panel and notify listeners.
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

/// A side panel that can be shown or hidden with an overlay presentation.
///
/// This widget creates a side panel that slides in from the side of the screen
/// with an overlay barrier. It's ideal for navigation drawers, inspector panels,
/// and other temporary content that needs to overlay the main interface.
///
/// {@tool snippet}
/// ```dart
/// OmarchySidePanel(
///   controller: sidePanelController,
///   panel: NavigationDrawer(),
///   child: MainContent(),
///   panelSize: PanelSize.absolute(300),
/// )
/// ```
/// {@end-tool}
class OmarchySidePanel extends StatefulWidget {
  /// Creates a side panel with the specified [panel] and [child].
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
    this.barrierColor,
  });

  /// Returns the controller from the closest [OmarchySidePanel] ancestor.
  ///
  /// Throws an exception if no [OmarchySidePanel] is found in the widget tree.
  static OmarchySidePanelController controllerOf(BuildContext context) {
    final state = context.findAncestorStateOfType<_OmarchySidePanelState>();
    if (state == null) {
      throw Exception(
        'No OmarchySidePanel found in context. Make sure to wrap your widget with OmarchySidePanel.',
      );
    }
    return state._controller;
  }

  /// The controller for managing panel visibility.
  ///
  /// If null, an internal controller is created.
  final OmarchySidePanelController? controller;

  /// The text direction that determines which side the panel appears from.
  final TextDirection direction;
  
  /// The orientation of the panel layout.
  final Axis orientation;
  
  /// The panel widget to display when visible.
  final Widget panel;
  
  /// The main content widget.
  final Widget child;
  
  /// The size of the panel when displayed.
  final PanelSize panelSize;
  
  /// The minimum size the panel can have.
  final PanelSize? minPanelSize;
  
  /// The minimum margin to maintain around the panel.
  final double minPanelMargin;
  
  /// The color of the barrier overlay.
  ///
  /// If null, uses a default semi-transparent dark color.
  final Color? barrierColor;

  @override
  State<OmarchySidePanel> createState() => _OmarchySidePanelState();
}

class _OmarchySidePanelState extends State<OmarchySidePanel> {
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
      // Only dispose the controller if it was created internally.
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
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
                      color: widget.barrierColor ?? const Color(0x33000000),
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
