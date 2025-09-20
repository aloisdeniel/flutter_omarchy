import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/colors.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';

class OmarchyLoader extends StatefulWidget {
  const OmarchyLoader({
    super.key,
    this.color,
    this.size,
    this.period = const Duration(seconds: 2),
    this.accent,
  });

  final Color? color;
  final double? size;
  final Duration period;
  final AnsiColor? accent;

  @override
  State<OmarchyLoader> createState() => _OmarchyLoaderState();
}

class _OmarchyLoaderState extends State<OmarchyLoader>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(vsync: this);
  @override
  void initState() {
    super.initState();
    controller.repeat(period: widget.period);
  }

  @override
  void didUpdateWidget(covariant OmarchyLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.period != oldWidget.period) {
      controller.repeat(period: widget.period);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final color =
        widget.color ??
        switch (widget.accent) {
          AnsiColor accent => theme.colors.bright[accent],
          null => theme.colors.foreground,
        };
    final size = widget.size ?? (theme.text.normal.fontSize ?? 12) * 1.2;
    return CustomPaint(
      size: Size(size, size),
      foregroundPainter: _Painter(color: color, anim: controller),
    );
  }
}

class _Painter extends CustomPainter {
  const _Painter({required this.color, required this.anim})
    : super(repaint: anim);
  final Animation<double> anim;
  final Color color;
  double get time => anim.value;
  @override
  void paint(Canvas canvas, Size size) {
    final borderTime = Curves.easeIn.transform(
      time > 0.5 ? 1 - (time - 0.5) * 2 : time * 2,
    );
    const margin = 4.0;
    var paint = Paint()
      ..strokeWidth = size.width / 10
      ..style = PaintingStyle.stroke
      ..color = color.withValues(alpha: 0.1 + 0.2 * borderTime);

    canvas.drawRect(Offset.zero & size, paint);

    final centerTime = Curves.easeIn.transform((time % 0.2) * 5);

    paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        radius: 0.7,
        center: Alignment(
          math.sin(centerTime * 2 * math.pi),
          math.cos(centerTime * 2 * math.pi),
        ),
        colors: [
          color,
          color.withValues(alpha: 0.1),
          color.withValues(alpha: 0.1),
        ],
        stops: [0.0, 0.7, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(
      Offset(margin, margin) &
          Size(size.height - margin * 2, size.height - margin * 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _Painter oldDelegate) {
    return oldDelegate.color != color;
  }
}
