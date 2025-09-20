import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter_omarchy/flutter_omarchy.dart';

class Display extends StatelessWidget {
  const Display({
    super.key,
    required this.history,
    required this.display,
    required this.isCondensed,
    this.isConfirmed = false,
    this.isIntermediateValue = false,
  });
  final String? history;
  final String display;
  final bool isConfirmed;
  final bool isIntermediateValue;
  final bool isCondensed;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return LayoutBuilder(
      builder: (context, layout) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (history case final history?)
              Text(
                history,
                style: theme.text.italic.copyWith(
                  fontSize: isCondensed ? 14 : 22,
                  color: theme.colors.bright.black,
                ),
                maxLines: 1,
                textAlign: TextAlign.right,
              ),
            FittedBox(
              child: SelectableText(
                display,
                style: TextStyle(
                  fontSize: isCondensed ? 48 : 88,
                  color: isIntermediateValue ? theme.colors.bright.black : null,
                ),
                maxLines: 1,
                cursorColor: theme.colors.normal.white,
                selectionColor: theme.colors.normal.white,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        );
      },
    );
  }
}
