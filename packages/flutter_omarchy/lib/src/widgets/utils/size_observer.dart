import 'package:flutter/rendering.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';

typedef SizeChange = ({Size? oldSize, Size newSize});

class SizeChanged extends SingleChildRenderObjectWidget {
  /// Creates a [SizeChangedLayoutNotifier] that dispatches layout changed
  /// notifications when [child] changes layout size.
  const SizeChanged({super.key, required this.onSizeChanged, super.child});

  final ValueChanged<SizeChange> onSizeChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSizeChangedWithCallback(onSizeChanged: onSizeChanged);
  }
}

class _RenderSizeChangedWithCallback extends RenderProxyBox {
  _RenderSizeChangedWithCallback({
    RenderBox? child,
    required this.onSizeChanged,
  }) : super(child);

  final ValueChanged<SizeChange> onSizeChanged;

  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    if (size != _oldSize) {
      onSizeChanged((oldSize: _oldSize, newSize: size));
    }
    _oldSize = size;
  }
}
