import 'package:example/calculator/engine/command.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';

class ButtonGrid extends StatelessWidget {
  const ButtonGrid({
    super.key,
    required this.onPressed,
    required this.simulated,
    this.spacing = 4.0,
  });

  final ValueChanged<Command> onPressed;
  final Map<Command, SimulatedPressController> simulated;
  final double spacing;

  static const rows = <List<Command>>[
    [
      MemoryClear(),
      OpenParenthesis(),
      CloseParenthesis(),
      ClearEntry(),
      Backspace(),
      ClearAll(),
      Operator.divide(),
    ],
    [
      MemoryRecall(),
      Sine(),
      Power(),
      Digit(7),
      Digit(8),
      Digit(9),
      Operator.multiply(),
    ],

    [
      MemoryAdd(),
      Cosine(),
      Square(),
      Digit(4),
      Digit(5),
      Digit(6),
      Operator.minus(),
    ],
    [
      MemorySubtract(),
      Tangent(),
      Percent(),
      Digit(1),
      Digit(2),
      Digit(3),
      Operator.plus(),
    ],
    [
      Pi(),
      Euler(),
      SquareRoot(),
      ToggleSign(),
      Digit(0),
      DecimalPoint(),
      Equals(),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, layout) {
        final startCol = (layout.maxWidth > 800) ? 0 : 3;
        return Column(
          spacing: spacing,
          children: [
            for (final row in rows)
              Expanded(
                child: Row(
                  spacing: spacing,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: row.skip(startCol).map((action) {
                    return SimulatedPress(
                      key: ValueKey(action),
                      controller: simulated[action],
                      child: CalculatorButton(
                        action,
                        onPressed: () => onPressed(action),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class CalculatorButton extends StatelessWidget {
  const CalculatorButton(this.action, {super.key, required this.onPressed});

  final Command action;
  final VoidCallback onPressed;
  AnsiColor get color => switch (action) {
    ClearAll() => AnsiColor.red,
    ClearEntry() => AnsiColor.red,
    Backspace() => AnsiColor.red,
    ToggleSign() => AnsiColor.blue,
    Percent() => AnsiColor.cyan,
    SquareRoot() => AnsiColor.cyan,
    Square() => AnsiColor.cyan,
    Power() => AnsiColor.cyan,
    Pi() => AnsiColor.cyan,
    Euler() => AnsiColor.cyan,
    OpenParenthesis() => AnsiColor.blue,
    CloseParenthesis() => AnsiColor.blue,
    Trigonometric() => AnsiColor.cyan,
    Equals() => AnsiColor.green,
    Digit() => AnsiColor.white,
    DecimalPoint() => AnsiColor.white,
    Operator() => AnsiColor.yellow,
    Memory() => AnsiColor.magenta,
  };

  Widget symbol(bool isSmall) => switch (action) {
    Backspace() => Icon(
      OmarchyIcons.mdBackspaceOutline,
      size: isSmall ? 30 : 48,
    ),
    final other => Text(
      other.toString(),
      style: TextStyle(fontSize: isSmall ? 20 : 32),
    ),
  };
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FadeIn(
        child: LayoutBuilder(
          builder: (context, layout) {
            final isSmall = layout.maxHeight < 75 || layout.maxWidth < 80;
            return OmarchyButton(
              style: OmarchyButtonStyle.filled(color, padding: EdgeInsets.zero),
              onPressed: onPressed,
              child: Center(child: symbol(isSmall)),
            );
          },
        ),
      ),
    );
  }
}
