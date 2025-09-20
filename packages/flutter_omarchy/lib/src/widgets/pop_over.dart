import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';

typedef OmarchyPopOverChildWidgetBuilder =
    Widget Function(BuildContext context, VoidCallback show);
typedef OmarchyPopOverWidgetBuilder =
    Widget Function(BuildContext context, Size? size, VoidCallback hide);

enum OmarchyPopOverDirection {
  up,
  upLeft,
  upRight,
  right,
  down,
  downLeft,
  downRight,
  left,
}

class OmarchyPopOver extends StatefulWidget {
  const OmarchyPopOver({
    super.key,
    required this.builder,
    required this.popOverBuilder,
    this.showWhenUnlinked = false,
    this.offset = Offset.zero,
    this.popOverDirection = OmarchyPopOverDirection.downRight,
  });

  final OmarchyPopOverChildWidgetBuilder builder;
  final OmarchyPopOverWidgetBuilder popOverBuilder;
  final bool showWhenUnlinked;
  final Offset offset;
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
