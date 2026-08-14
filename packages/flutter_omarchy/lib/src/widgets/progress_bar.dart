import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/colors.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';

/// A horizontal progress bar that shows completion status.
///
/// This progress bar displays a filled portion representing completion
/// progress from 0.0 to 1.0. The bar has a dark background with a
/// colored fill that can be customized with accent colors.
///
/// {@tool snippet}
/// ```dart
/// OmarchyProgressBar(
///   progress: 0.7, // 70% complete
///   accent: AnsiColor.green,
/// )
/// ```
/// {@end-tool}
class OmarchyProgressBar extends StatelessWidget {
  /// Creates a progress bar with the specified [progress] value.
  const OmarchyProgressBar({super.key, required this.progress, this.accent});

  /// The progress value from 0.0 (empty) to 1.0 (complete).
  ///
  /// Values outside this range will be clamped.
  final double progress;
  
  /// The accent color for the progress fill.
  ///
  /// If null, uses the theme's border color.
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
