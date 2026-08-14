import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/colors.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/utils/pointer_area.dart';

/// A horizontal slider for selecting a value in a range.
///
/// The slider follows the sharp, terminal-inspired Omarchy aesthetic: a thin
/// track with a square thumb. It supports mouse dragging, clicking on the
/// track, and keyboard interaction (arrow keys, Home/End) when focused.
///
/// {@tool snippet}
/// ```dart
/// OmarchySlider(
///   value: volume,
///   accent: AnsiColor.green,
///   onChanged: (v) => setState(() => volume = v),
/// )
/// ```
/// {@end-tool}
class OmarchySlider extends StatefulWidget {
  /// Creates a slider with the given [value].
  const OmarchySlider({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.accent,
    this.focusNode,
  }) : assert(min < max, 'min must be less than max');

  /// The currently selected value, clamped to `[min, max]`.
  final double value;

  /// Called with the new value while the user interacts with the slider.
  ///
  /// If null, the slider is disabled.
  final ValueChanged<double>? onChanged;

  /// The minimum value of the range.
  final double min;

  /// The maximum value of the range.
  final double max;

  /// The number of discrete divisions.
  ///
  /// If null, the slider is continuous.
  final int? divisions;

  /// The accent color for the filled portion of the track and the thumb.
  ///
  /// If null, uses the theme's border color.
  final AnsiColor? accent;

  /// The focus node for keyboard navigation.
  final FocusNode? focusNode;

  @override
  State<OmarchySlider> createState() => _OmarchySliderState();
}

class _OmarchySliderState extends State<OmarchySlider> {
  static const _thumbSize = 12.0;
  static const _trackHeight = 4.0;

  bool get enabled => widget.onChanged != null;

  double get _range => widget.max - widget.min;

  double get _ratio =>
      ((widget.value - widget.min) / _range).clamp(0.0, 1.0).toDouble();

  double _snap(double value) {
    if (widget.divisions case final divisions?) {
      final step = _range / divisions;
      value = widget.min + ((value - widget.min) / step).round() * step;
    }
    return value.clamp(widget.min, widget.max).toDouble();
  }

  void _updateFromPosition(double dx, double width) {
    final ratio = ((dx - _thumbSize / 2) / (width - _thumbSize)).clamp(
      0.0,
      1.0,
    );
    _emit(widget.min + ratio * _range);
  }

  void _emit(double value) {
    value = _snap(value);
    if (value != widget.value) {
      widget.onChanged?.call(value);
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (!enabled || (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }
    final step = switch (widget.divisions) {
      final divisions? => _range / divisions,
      null => _range / 100,
    };
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _emit(widget.value - step);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _emit(widget.value + step);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.home) {
      _emit(widget.min);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.end) {
      _emit(widget.max);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final accent = switch (widget.accent) {
      AnsiColor color => theme.colors.bright[color],
      null => theme.colors.border,
    };
    return Focus(
      focusNode: widget.focusNode,
      canRequestFocus: enabled,
      onKeyEvent: _onKeyEvent,
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : 200.0;
              return PointerArea(
                hoverCursor: enabled
                    ? SystemMouseCursors.click
                    : MouseCursor.defer,
                onTapDown: enabled
                    ? (details) {
                        Focus.of(context).requestFocus();
                        _updateFromPosition(details.localPosition.dx, width);
                      }
                    : null,
                onPanUpdate: enabled
                    ? (details) =>
                          _updateFromPosition(details.localPosition.dx, width)
                    : null,
                builder: (context, state, _) {
                  final thumbColor = switch (state) {
                    _ when !enabled => theme.colors.bright.black,
                    PointerState(isPressed: true) => theme.colors.bright.white,
                    _ when state.isHovering || hasFocus => accent,
                    _ => accent.withValues(alpha: 0.9),
                  };
                  return SizedBox(
                    width: width,
                    height: _thumbSize * 2,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Track background.
                        Positioned(
                          left: 0,
                          right: 0,
                          top: _thumbSize - _trackHeight / 2,
                          height: _trackHeight,
                          child: ColoredBox(color: theme.colors.normal.black),
                        ),
                        // Filled track.
                        Positioned(
                          left: 0,
                          width: _thumbSize / 2 + (width - _thumbSize) * _ratio,
                          top: _thumbSize - _trackHeight / 2,
                          height: _trackHeight,
                          child: ColoredBox(
                            color: enabled
                                ? accent.withValues(alpha: 0.6)
                                : theme.colors.bright.black,
                          ),
                        ),
                        // Thumb.
                        Positioned(
                          left: (width - _thumbSize) * _ratio,
                          top: _thumbSize / 2,
                          width: _thumbSize,
                          height: _thumbSize,
                          child: ColoredBox(color: thumbColor),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
