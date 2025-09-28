import 'dart:math' as math;

import 'package:flutter/widgets.dart';

enum _LayoutId { leading, title, trailing }

/// A title bar layout widget with leading, title, and trailing areas.
///
/// This widget provides a three-section layout commonly used in navigation bars,
/// dialog headers, and application title bars. The title is centered while
/// leading and trailing widgets are positioned on the sides with intelligent
/// overflow handling.
///
/// {@tool snippet}
/// ```dart
/// TitleBar(
///   leading: IconButton(icon: Icon(Icons.menu), onPressed: () {}),
///   title: Text('My Application'),
///   trailing: IconButton(icon: Icon(Icons.settings), onPressed: () {}),
/// )
/// ```
/// {@end-tool}
class TitleBar extends StatelessWidget {
  /// Creates a title bar with the specified widgets.
  const TitleBar({
    super.key,
    required this.title,
    this.leading = const SizedBox.shrink(),
    this.trailing = const SizedBox.shrink(),
  });

  /// The central title widget.
  final Widget title;
  
  /// The widget displayed on the leading side (typically left).
  final Widget leading;
  
  /// The widget displayed on the trailing side (typically right).
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
