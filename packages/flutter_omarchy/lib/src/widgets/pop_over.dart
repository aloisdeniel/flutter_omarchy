import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';

/// A function that builds the child widget with access to a show callback.
typedef OmarchyPopOverChildWidgetBuilder =
    Widget Function(BuildContext context, VoidCallback show);

/// A function that builds the popup content with access to size and hide callback.
typedef OmarchyPopOverWidgetBuilder =
    Widget Function(BuildContext context, Size? size, VoidCallback hide);

/// Defines the direction in which a popup should appear relative to its anchor.
enum OmarchyPopOverDirection {
  /// Popup appears above the anchor.
  up,
  /// Popup appears above and to the left of the anchor.
  upLeft,
  /// Popup appears above and to the right of the anchor.
  upRight,
  /// Popup appears to the right of the anchor.
  right,
  /// Popup appears below the anchor.
  down,
  /// Popup appears below and to the left of the anchor.
  downLeft,
  /// Popup appears below and to the right of the anchor.
  downRight,
  /// Popup appears to the left of the anchor.
  left,
}

/// A widget that displays a popup overlay positioned relative to its child.
///
/// This widget provides a flexible popup system for dropdowns, context menus,
/// tooltips, and other overlay content. The popup is positioned using Flutter's
/// overlay system and can be configured to appear in various directions.
///
/// {@tool snippet}
/// ```dart
/// OmarchyPopOver(
///   popOverDirection: OmarchyPopOverDirection.down,
///   builder: (context, show) => ElevatedButton(
///     onPressed: show,
///     child: Text('Show Menu'),
///   ),
///   popOverBuilder: (context, size, hide) => Material(
///     child: Column(
///       children: [
///         ListTile(title: Text('Option 1'), onTap: hide),
///         ListTile(title: Text('Option 2'), onTap: hide),
///       ],
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
class OmarchyPopOver extends StatefulWidget {
  /// Creates a popup overlay widget.
  const OmarchyPopOver({
    super.key,
    required this.builder,
    required this.popOverBuilder,
    this.showWhenUnlinked = false,
    this.offset = Offset.zero,
    this.popOverDirection = OmarchyPopOverDirection.downRight,
  });

  /// Builder for the child widget that triggers the popup.
  final OmarchyPopOverChildWidgetBuilder builder;
  
  /// Builder for the popup content.
  final OmarchyPopOverWidgetBuilder popOverBuilder;
  
  /// Whether to show the popup even when not linked to the overlay.
  final bool showWhenUnlinked;
  
  /// Additional offset to apply to the popup position.
  final Offset offset;
  
  /// The direction in which the popup should appear.
  final OmarchyPopOverDirection popOverDirection;

  @override
  State<OmarchyPopOver> createState() => _OmarchyPopOverState();
}

class _OmarchyPopOverState extends State<OmarchyPopOver> {
  final _link = LayerLink();
  final _controller = OverlayPortalController();

  @override
  void didUpdateWidget(covariant OmarchyPopOver oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final anchor = switch (widget.popOverDirection) {
      OmarchyPopOverDirection.upLeft => (
        childAnchor: Alignment.topRight,
        popOverAnchor: Alignment.bottomRight,
      ),
      OmarchyPopOverDirection.upRight => (
        childAnchor: Alignment.topLeft,
        popOverAnchor: Alignment.bottomLeft,
      ),
      OmarchyPopOverDirection.downLeft => (
        childAnchor: Alignment.bottomRight,
        popOverAnchor: Alignment.topRight,
      ),
      OmarchyPopOverDirection.downRight => (
        childAnchor: Alignment.bottomLeft,
        popOverAnchor: Alignment.topLeft,
      ),
      OmarchyPopOverDirection.up => (
        childAnchor: Alignment.topCenter,
        popOverAnchor: Alignment.bottomCenter,
      ),
      OmarchyPopOverDirection.down => (
        childAnchor: Alignment.bottomCenter,
        popOverAnchor: Alignment.topCenter,
      ),
      OmarchyPopOverDirection.left => (
        childAnchor: Alignment.centerLeft,
        popOverAnchor: Alignment.centerRight,
      ),
      OmarchyPopOverDirection.right => (
        childAnchor: Alignment.centerRight,
        popOverAnchor: Alignment.centerLeft,
      ),
    };
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (BuildContext context) {
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    _controller.hide();
                  },
                  child: Container(color: Color(0x01000000)),
                ),
              ),
              CompositedTransformFollower(
                link: _link,
                showWhenUnlinked: widget.showWhenUnlinked,
                offset: widget.offset,
                targetAnchor: anchor.childAnchor,
                followerAnchor: anchor.popOverAnchor,
                child: IntrinsicHeight(
                  child: IntrinsicWidth(
                    child: widget.popOverBuilder(
                      context,
                      _link.leaderSize,
                      _controller.hide,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        child: widget.builder(context, _controller.show),
      ),
    );
  }
}

class OmarchyPopOverContainer extends StatelessWidget {
  const OmarchyPopOverContainer({
    super.key,
    required this.child,
    this.alignment,
  });

  final Widget child;
  final Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border.all(color: theme.colors.border, width: 2),
      ),
      child: child,
    );
  }
}
