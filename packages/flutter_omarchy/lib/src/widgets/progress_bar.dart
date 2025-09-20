import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/colors.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';

class OmarchyProgressBar extends StatelessWidget {
  const OmarchyProgressBar({super.key, required this.progress, this.accent});

  final double progress;
  final AnsiColor? accent;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final accent = switch (this.accent) {
      AnsiColor color => theme.colors.bright[color],
      null => theme.colors.border,
    };
    return Container(
      width: double.infinity,
      color: theme.colors.normal.black,
      height: 4,
      padding: const EdgeInsets.all(1),
      child: FractionallySizedBox(
        heightFactor: 1,
        widthFactor: progress.clamp(0, 1),
        alignment: Alignment.centerLeft,
        child: Container(color: accent),
      ),
    );
  }
}
