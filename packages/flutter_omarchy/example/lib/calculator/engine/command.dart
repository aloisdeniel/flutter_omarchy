/// Base class for calculator actions.
sealed class Command {
  const Command();
}

/// 0–9 digit input
class Digit extends Command {
  final int value; // must be 0..9
  const Digit(this.value) : assert(value >= 0 && value <= 9);

  @override
  String toString() {
    return value.toString();
  }
}

/// Decimal point input (".")
class DecimalPoint extends Command {
  const DecimalPoint();

  @override
  String toString() {
    return '.';
  }
}

/// Binary operators: +, -, ×, ÷
class Operator extends Command {
  final OperatorType type;
  const Operator(this.type);

  const Operator.plus() : type = OperatorType.plus;
  const Operator.minus() : type = OperatorType.minus;
  const Operator.multiply() : type = OperatorType.multiply;
  const Operator.divide() : type = OperatorType.divide;
  const Operator.power() : type = OperatorType.power;

  @override
  String toString() {
    return type.toSymbol();
  }
}

enum OperatorType {
  plus,
  minus,
  multiply,
  divide,
  power;

  String toSymbol() {
    switch (this) {
      case OperatorType.plus:
        return '+';
      case OperatorType.minus:
        return '-';
      case OperatorType.multiply:
        return '×';
      case OperatorType.divide:
        return '÷';
      case OperatorType.power:
        return '^';
    }
  }
}

/// Evaluate the current expression
class Equals extends Command {
  const Equals();
  @override
  String toString() {
    return '=';
  }
}

/// Clear everything (AC)
class ClearAll extends Command {
  const ClearAll();
  @override
  String toString() {
    return 'AC';
  }
}

/// Clear only the current entry (CE)
class ClearEntry extends Command {
  const ClearEntry();
  @override
  String toString() {
    return 'CE';
  }
}

/// Delete last character of the current entry
class Backspace extends Command {
  const Backspace();

  @override
  String toString() {
    return 'CE';
  }
}

/// Toggle sign of the current entry (±)
class ToggleSign extends Command {
  const ToggleSign();

  @override
  String toString() {
    return '±';
  }
}

/// Convert current entry to a percentage (divide by 100)
class Percent extends Command {
  const Percent();

  @override
  String toString() {
    return '%';
  }
}

/// Calculate square root of the current entry
class SquareRoot extends Command {
  const SquareRoot();

  @override
  String toString() {
    return '√';
  }
}

/// Calculate square of the current entry
class Square extends Command {
  const Square();

  @override
  String toString() {
    return 'x²';
  }
}

/// Memory operations
sealed class Memory extends Command {
  const Memory();
}

/// Memory store (M+)
class MemoryAdd extends Memory {
  const MemoryAdd();

  @override
  String toString() {
    return 'M+';
  }
}

/// Memory subtract (M-)
class MemorySubtract extends Memory {
  const MemorySubtract();

  @override
  String toString() {
    return 'M-';
  }
}

/// Memory recall (MR)
class MemoryRecall extends Memory {
  const MemoryRecall();

  @override
  String toString() {
    return 'MR';
  }
}

/// Memory clear (MC)
class MemoryClear extends Memory {
  const MemoryClear();

  @override
  String toString() {
    return 'MC';
  }
}

/// Power operation (x^y)
class Power extends Command {
  const Power();

  @override
  String toString() {
    return 'x^y';
  }
}

/// Open parenthesis
class OpenParenthesis extends Command {
  const OpenParenthesis();

  @override
  String toString() {
    return '(';
  }
}

/// Close parenthesis
class CloseParenthesis extends Command {
  const CloseParenthesis();

  @override
  String toString() {
    return ')';
  }
}

/// Trigonometric operations
sealed class Trigonometric extends Command {
  const Trigonometric();
}

/// Sine function
class Sine extends Trigonometric {
  const Sine();

  @override
  String toString() {
    return 'sin';
  }
}

/// Cosine function
class Cosine extends Trigonometric {
  const Cosine();

  @override
  String toString() {
    return 'cos';
  }
}

/// Tangent function
class Tangent extends Trigonometric {
  const Tangent();

  @override
  String toString() {
    return 'tan';
  }
}

/// Pi constant (π)
class Pi extends Command {
  const Pi();

  @override
  String toString() {
    return 'π';
  }
}

/// Euler's number (e)
class Euler extends Command {
  const Euler();

  @override
  String toString() {
    return 'e';
  }
}
