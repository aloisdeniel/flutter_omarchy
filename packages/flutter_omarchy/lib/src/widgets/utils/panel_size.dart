/// Constraints for panel sizing, defining minimum and maximum sizes.
typedef PanelSizeConstraints = ({double minSize, double maxSize});

/// Abstract base class for defining panel sizes in flexible layouts.
///
/// This sealed class provides two concrete implementations:
/// - [PanelSize.absolute] for fixed pixel sizes
/// - [PanelSize.ratio] for proportional sizes based on available space
sealed class PanelSize {
  /// Creates a panel size.
  const PanelSize();
  
  /// Creates a panel size with a fixed pixel dimension.
  const factory PanelSize.absolute(double size) = _PanelSizeAbsolute;
  
  /// Creates a panel size as a ratio of the available space (0.0 to 1.0).
  const factory PanelSize.ratio(double ratio) = _PanelSizeRatio;
  
  /// Resolves this panel size to a concrete pixel value given the available [size].
  double resolve(double size);
  
  /// Creates a new panel size by adding [delta] to the current size.
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
    return this.size.clamp(0, size);
  }

  @override
  PanelSize addDelta(double size, double delta) {
    return PanelSize.absolute((this.size + delta).clamp(0, size));
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
