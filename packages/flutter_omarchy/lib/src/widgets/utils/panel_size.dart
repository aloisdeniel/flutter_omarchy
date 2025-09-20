typedef PanelSizeConstraints = ({double minSize, double maxSize});

sealed class PanelSize {
  const PanelSize();
  const factory PanelSize.absolute(double size) = _PanelSizeAbsolute;
  const factory PanelSize.ratio(double ratio) = _PanelSizeRatio;
  double resolve(double size);
  PanelSize addDelta(double size, double delta);
}

class _PanelSizeAbsolute extends PanelSize {
  const _PanelSizeAbsolute(this.size);
  final double size;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _PanelSizeAbsolute) return false;
    return size == other.size;
  }

  @override
  int get hashCode => size.hashCode;

  @override
  double resolve(double size) {
    return size.clamp(0, size);
  }

  @override
  PanelSize addDelta(double size, double delta) {
    return PanelSize.absolute((size + delta).clamp(0, size));
  }
}

class _PanelSizeRatio extends PanelSize {
  const _PanelSizeRatio(this.ratio);
  final double ratio;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _PanelSizeRatio) return false;
    return ratio == other.ratio;
  }

  @override
  int get hashCode => ratio.hashCode;

  @override
  double resolve(double size) {
    assert(size.isFinite, 'Can only be used with finite maxWidth constraints');
    final ratioSize = size * ratio;
    return ratioSize.clamp(0, size);
  }

  @override
  PanelSize addDelta(double size, double delta) {
    assert(size.isFinite, 'Can only be used with finite maxWidth constraints');
    final ratioSize = resolve(size) + delta;
    final newSize = ratioSize.clamp(0.0, size);
    return PanelSize.ratio(newSize / size);
  }
}
