import 'dart:math' as math;

import 'package:flutter/widgets.dart';

enum _LayoutId { leading, title, trailing }

class TitleBar extends StatelessWidget {
  const TitleBar({
    super.key,
    required this.title,
    this.leading = const SizedBox.shrink(),
    this.trailing = const SizedBox.shrink(),
  });

  final Widget title;
  final Widget leading;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _LayoutDelegate(),
      children: [
        LayoutId(id: _LayoutId.trailing, child: trailing),
        LayoutId(id: _LayoutId.title, child: title),
        LayoutId(id: _LayoutId.leading, child: leading),
      ],
    );
  }
}

class _LayoutDelegate extends MultiChildLayoutDelegate {
  _LayoutDelegate();

  @override
  void performLayout(Size size) {
    final leadingSize = layoutChild(
      _LayoutId.leading,
      BoxConstraints(maxHeight: size.height, maxWidth: size.width),
    );
    final trailingSize = layoutChild(
      _LayoutId.trailing,
      BoxConstraints(
        maxHeight: size.height,
        maxWidth: size.width - leadingSize.width,
      ),
    );
    final titleSize = layoutChild(
      _LayoutId.title,
      BoxConstraints(
        maxHeight: size.height,
        maxWidth: size.width - leadingSize.width - trailingSize.width,
      ),
    );
    final center = size.center(Offset.zero);
    positionChild(
      _LayoutId.leading,
      Offset(0, center.dy - leadingSize.height / 2),
    );
    positionChild(
      _LayoutId.trailing,
      Offset(
        size.width - trailingSize.width,
        center.dy - trailingSize.height / 2,
      ),
    );
    final leadingOverlapping =
        leadingSize
            .width // leading end
            -
        (center.dx - titleSize.width / 2); // title start
    final trailingOverlapping =
        (size.width - trailingSize.width) // trailing start
        -
        (center.dx + titleSize.width / 2); // title end

    positionChild(
      _LayoutId.title,
      Offset(
        math.max(0, leadingOverlapping) +
            math.min(0, trailingOverlapping) +
            center.dx -
            titleSize.width / 2,
        center.dy - titleSize.height / 2,
      ),
    );
  }

  @override
  bool shouldRelayout(covariant _LayoutDelegate oldDelegate) {
    return false;
  }
}
