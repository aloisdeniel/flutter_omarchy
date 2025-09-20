import 'dart:math' show sqrt, pow, sin, cos, tan, pi, e;

import 'package:example/calculator/engine/command.dart';
import 'package:flutter/widgets.dart';

/// A lightweight calculator engine that records every action and
/// derives the current result from that history.
class CalculatorNotifier extends ChangeNotifier {
  final List<Command> _history = <Command>[];

  // Internal state derived by replaying history
  String _currentEntry = ""; // textual buffer for the number being typed
  final List<_Token> _tokens = <_Token>[]; // committed numbers & operators
  bool _justEvaluated = false; // last action was Equals
  String? _error; // non-null if an error occurred during evaluation
  double _memoryValue = 0.0; // value stored in memory
  bool _hasMemory = false; // whether memory has a value
  int _parenthesisCount = 0; // count of open parentheses

  // --- Public API ---

  /// Append an action to the history and update the state by replaying it.
  void execute(Command action) {
    _apply(action, record: true);
    notifyListeners();
  }

  /// All actions so far (immutable copy)
  List<Command> get history => List.unmodifiable(_history);

  /// The text to show on the calculator main display.
  /// If an error occurred, this returns a message like "Error" or "Division by zero".
  /// Shows the current result of the calculation, ignoring the last operator if present.
  String get display {
    if (_error != null) return _error!;

    // If we're currently entering a number, show that
    if (_currentEntry.isNotEmpty) return _currentEntry;

    // Calculate the current result (this will ignore the last operator if present)
    final result = _evaluateTokens();

    // Format and return the result
    return _formatNumber(result);
  }

  /// A human-friendly one-line history like: "12 + 7 × 3 = 33".
  String get historyDisplay {
    if (_history.isEmpty) return "";
    final sb = StringBuffer();

    // Reconstruct by walking tokens and entry
    for (final t in _tokens) {
      if (t is _NumberTok) {
        sb.write(_trimTrailingZeros(t.value));
      } else if (t is _OpTok) {
        sb.write(" ${t.type.toSymbol()} ");
      } else if (t is _ParenTok) {
        sb.write(t.isOpen ? "(" : ")");
      } else if (t is _FuncTok) {
        sb.write("${t.name}(");
      }
    }
    if (_currentEntry.isNotEmpty) {
      if (sb.isNotEmpty) sb.write(" ");
      sb.write(_currentEntry);
    }

    // If last action was Equals, append "= result"
    if (_history.isNotEmpty && _history.last is Equals) {
      final res = _error ?? _formatNumber(_evaluateTokens());
      if (sb.isNotEmpty) sb.write(" ");
      sb.write("= $res");
    }

    return sb.toString();
  }

  /// True if the engine is currently in an error state.
  bool get hasError => _error != null;

  /// True if the last action was Equals (display is confirmed).
  bool get isDisplayConfirmed => _justEvaluated;

  /// True if the display is showing an intermediate value after an operator.
  bool get isIntermediateValue =>
      _tokens.isNotEmpty && _tokens.last is _OpTok && _currentEntry.isEmpty;

  /// Erases everything and clears history. Does not add a history entry.
  void reset() {
    _history.clear();
    _currentEntry = "";
    _tokens.clear();
    _justEvaluated = false;
    _error = null;
  }

  // --- Internals ---

  void _apply(Command action, {bool record = false}) {
    if (record) _history.add(action);

    if (action is ClearAll) {
      _currentEntry = "";
      _tokens.clear();
      _justEvaluated = false;
      _error = null;
      return;
    }

    if (action is ClearEntry) {
      _currentEntry = "";
      _error = null;
      return;
    }

    if (action is Backspace) {
      if (_currentEntry.isNotEmpty) {
        _currentEntry = _currentEntry.substring(0, _currentEntry.length - 1);
      }
      return;
    }

    if (action is Digit) {
      if (_justEvaluated) {
        // Start a new entry after equals if user types a digit
        _tokens.clear();
        _currentEntry = "";
        _justEvaluated = false;
      }
      // Prevent leading zeros like 00012 unless after decimal
      if (_currentEntry == "0") _currentEntry = "";
      _currentEntry += action.value.toString();
      return;
    }

    if (action is DecimalPoint) {
      if (_justEvaluated) {
        _tokens.clear();
        _currentEntry = "";
        _justEvaluated = false;
      }
      if (_currentEntry.isEmpty) {
        _currentEntry = "0.";
      } else if (!_currentEntry.contains('.')) {
        _currentEntry += ".";
      }
      return;
    }

    if (action is ToggleSign) {
      if (_currentEntry.isEmpty) {
        // Toggle last number token if no active entry
        for (int i = _tokens.length - 1; i >= 0; i--) {
          final t = _tokens[i];
          if (t is _NumberTok) {
            _tokens[i] = _NumberTok(-t.value);
            break;
          }
        }
      } else {
        if (_currentEntry.startsWith("-")) {
          _currentEntry = _currentEntry.substring(1);
        } else {
          _currentEntry = "-$_currentEntry";
        }
      }
      return;
    }

    if (action is Percent) {
      if (_currentEntry.isEmpty) return;
      final v = double.tryParse(_currentEntry);
      if (v != null) {
        _currentEntry = _trimTrailingZeros(v / 100.0);
      }
      return;
    }

    if (action is SquareRoot) {
      if (_currentEntry.isEmpty) return;
      final v = double.tryParse(_currentEntry);
      if (v != null) {
        if (v < 0) {
          _error = "Invalid input";
          return;
        }
        _currentEntry = _trimTrailingZeros(sqrt(v));
      }
      return;
    }

    if (action is Square) {
      if (_currentEntry.isEmpty) return;
      final v = double.tryParse(_currentEntry);
      if (v != null) {
        _currentEntry = _trimTrailingZeros(v * v);
      }
      return;
    }

    if (action is MemoryAdd) {
      if (_currentEntry.isEmpty) {
        // Use last result if no current entry
        final value = _evaluateTokens();
        _memoryValue += value;
      } else {
        final v = double.tryParse(_currentEntry);
        if (v != null) {
          _memoryValue += v;
        }
      }
      _hasMemory = true;
      return;
    }

    if (action is MemorySubtract) {
      if (_currentEntry.isEmpty) {
        // Use last result if no current entry
        final value = _evaluateTokens();
        _memoryValue -= value;
      } else {
        final v = double.tryParse(_currentEntry);
        if (v != null) {
          _memoryValue -= v;
        }
      }
      _hasMemory = true;
      return;
    }

    if (action is MemoryRecall) {
      if (!_hasMemory) return;
      if (_justEvaluated) {
        _tokens.clear();
        _justEvaluated = false;
      }
      _currentEntry = _trimTrailingZeros(_memoryValue);
      return;
    }

    if (action is MemoryClear) {
      _memoryValue = 0.0;
      _hasMemory = false;
      return;
    }

    if (action is Power) {
      _commitEntryIfAny();
      _tokens.add(_OpTok(OperatorType.power));
      return;
    }

    if (action is OpenParenthesis) {
      if (_currentEntry.isNotEmpty && double.tryParse(_currentEntry) != null) {
        // Implicit multiplication: 2(3+4) means 2*(3+4)
        _commitEntryIfAny();
        _tokens.add(_OpTok(OperatorType.multiply));
      }
      _tokens.add(_ParenTok(true));
      _parenthesisCount++;
      return;
    }

    if (action is CloseParenthesis) {
      if (_parenthesisCount <= 0) {
        return; // Ignore if no matching open parenthesis
      }
      _commitEntryIfAny();
      _tokens.add(_ParenTok(false));
      _parenthesisCount--;
      return;
    }

    if (action is Sine) {
      if (_currentEntry.isEmpty) return;
      final v = double.tryParse(_currentEntry);
      if (v != null) {
        // Convert to radians if needed
        final radians = v * pi / 180.0;
        _currentEntry = _trimTrailingZeros(sin(radians));
      }
      return;
    }

    if (action is Cosine) {
      if (_currentEntry.isEmpty) return;
      final v = double.tryParse(_currentEntry);
      if (v != null) {
        // Convert to radians if needed
        final radians = v * pi / 180.0;
        _currentEntry = _trimTrailingZeros(cos(radians));
      }
      return;
    }

    if (action is Tangent) {
      if (_currentEntry.isEmpty) return;
      final v = double.tryParse(_currentEntry);
      if (v != null) {
        // Check for invalid input (90, 270, etc. degrees)
        final degrees = v % 360;
        if (degrees == 90 || degrees == 270) {
          _error = "Invalid input";
          return;
        }
        // Convert to radians
        final radians = v * pi / 180.0;
        _currentEntry = _trimTrailingZeros(tan(radians));
      }
      return;
    }

    if (action is Pi) {
      if (_justEvaluated) {
        _tokens.clear();
        _justEvaluated = false;
      }

      // If there's a number entry, treat pi as multiplication (e.g., 2π = 2*π)
      if (_currentEntry.isNotEmpty && double.tryParse(_currentEntry) != null) {
        _commitEntryIfAny();
        _tokens.add(_OpTok(OperatorType.multiply));
      }

      _currentEntry = _trimTrailingZeros(pi);
      return;
    }

    if (action is Euler) {
      if (_justEvaluated) {
        _tokens.clear();
        _justEvaluated = false;
      }

      // If there's a number entry, treat e as multiplication (e.g., 2e = 2*e)
      if (_currentEntry.isNotEmpty && double.tryParse(_currentEntry) != null) {
        _commitEntryIfAny();
        _tokens.add(_OpTok(OperatorType.multiply));
      }

      _currentEntry = _trimTrailingZeros(e);
      return;
    }

    if (action is Operator) {
      _commitEntryIfAny();
      _error = null;
      // Replace operator if previous token is an operator
      if (_tokens.isNotEmpty && _tokens.last is _OpTok) {
        _tokens[_tokens.length - 1] = _OpTok(action.type);
      } else {
        _tokens.add(_OpTok(action.type));
      }
      _justEvaluated = false;
      return;
    }

    if (action is Equals) {
      _commitEntryIfAny();
      final res = _safeEvaluate();
      if (res == null) {
        // keep tokens as-is; _error populated
        _justEvaluated = true; // still consider as evaluated for UI flow
        return;
      }
      _tokens
        ..clear()
        ..add(_NumberTok(res));
      _currentEntry = "";
      _error = null;
      _justEvaluated = true;
      return;
    }
  }

  void _commitEntryIfAny() {
    if (_currentEntry.isEmpty) return;
    final parsed = double.tryParse(_currentEntry);
    if (parsed != null) {
      _tokens.add(_NumberTok(parsed));
    }
    _currentEntry = "";
  }

  String _formatNumber(double value) => _trimTrailingZeros(value);

  String _trimTrailingZeros(double value) {
    final s = value.toStringAsFixed(12); // avoid floating noise
    // Trim trailing zeros and possibly the decimal point
    String out = s;
    while (out.contains('.') && (out.endsWith('0') || out.endsWith('.'))) {
      out = out.substring(0, out.length - 1);
      if (out.endsWith('.')) {
        out = out.substring(0, out.length - 1);
        break;
      }
    }
    if (out.isEmpty) return "0";
    return out;
  }

  /// Evaluate tokens with operator precedence using a simple shunting-yard.
  /// Calculates the intermediate result of the expression so far, ignoring the last operator
  /// if it's at the end of the token list.
  double _evaluateTokens() {
    // If tokens is empty, return 0
    if (_tokens.isEmpty) return 0.0;

    // Create a copy of tokens to work with
    final tokensCopy = List<_Token>.from(_tokens);

    // If the last token is an operator, remove it for intermediate calculation
    if (tokensCopy.isNotEmpty && tokensCopy.last is _OpTok) {
      tokensCopy.removeLast();
    }

    // If after removing the last operator we have no tokens, return 0
    if (tokensCopy.isEmpty) return 0.0;
    final rpn = <_Token>[];
    final ops = <_Token>[];

    int prec(OperatorType t) {
      switch (t) {
        case OperatorType.plus:
        case OperatorType.minus:
          return 1;
        case OperatorType.multiply:
        case OperatorType.divide:
          return 2;
        case OperatorType.power:
          return 3;
      }
    }

    for (final t in tokensCopy) {
      if (t is _NumberTok) {
        rpn.add(t);
      } else if (t is _OpTok) {
        while (ops.isNotEmpty &&
            ops.last is _OpTok &&
            prec((ops.last as _OpTok).type) >= prec(t.type)) {
          rpn.add(ops.removeLast());
        }
        ops.add(t);
      } else if (t is _ParenTok) {
        if (t.isOpen) {
          // Opening parenthesis
          ops.add(t);
        } else {
          // Closing parenthesis
          while (ops.isNotEmpty && ops.last is! _ParenTok) {
            rpn.add(ops.removeLast());
          }
          if (ops.isNotEmpty && ops.last is _ParenTok) {
            ops.removeLast(); // Remove the opening parenthesis
          }
        }
      } else if (t is _FuncTok) {
        ops.add(t);
      }
    }

    // Pop any remaining operators
    while (ops.isNotEmpty) {
      final op = ops.removeLast();
      if (op is! _ParenTok) {
        // Skip any unmatched parentheses
        rpn.add(op);
      }
    }

    // If we have no tokens in RPN (e.g., only open parentheses), return 0
    if (rpn.isEmpty) return 0.0;

    // If we have only one token and it's a number, return it directly
    if (rpn.length == 1 && rpn.first is _NumberTok) {
      return (rpn.first as _NumberTok).value;
    }

    final stack = <double>[];
    for (final t in rpn) {
      if (t is _NumberTok) {
        stack.add(t.value);
      } else if (t is _OpTok) {
        // If we don't have enough operands, return the last value on the stack
        // or 0 if the stack is empty
        if (stack.length < 2) {
          return stack.isEmpty ? 0.0 : stack.last;
        }
        final b = stack.removeLast();
        final a = stack.removeLast();
        switch (t.type) {
          case OperatorType.plus:
            stack.add(a + b);
            break;
          case OperatorType.minus:
            stack.add(a - b);
            break;
          case OperatorType.multiply:
            stack.add(a * b);
            break;
          case OperatorType.divide when b == 0.0:
            return double.infinity; // will be handled by _safeEvaluate
          case OperatorType.divide:
            stack.add(a / b);
            break;
          case OperatorType.power:
            stack.add(pow(a, b) as double);
            break;
        }
      } else if (t is _FuncTok) {
        if (stack.isEmpty) return 0.0;
        final a = stack.removeLast();
        switch (t.name) {
          case 'sin':
            stack.add(sin(a * pi / 180.0));
            break;
          case 'cos':
            stack.add(cos(a * pi / 180.0));
            break;
          case 'tan':
            if (a % 180 == 90) return double.infinity;
            stack.add(tan(a * pi / 180.0));
            break;
        }
      }
    }
    return stack.isEmpty ? 0.0 : stack.last;
  }

  double? _safeEvaluate() {
    final res = _evaluateTokens();
    if (res.isNaN) {
      _error = "Error";
      return null;
    }
    if (res.isInfinite) {
      _error = "Division by zero";
      return null;
    }
    return res;
  }
}

abstract class _Token {
  const _Token();
}

class _NumberTok extends _Token {
  final double value;
  const _NumberTok(this.value);
}

class _OpTok extends _Token {
  final OperatorType type;
  const _OpTok(this.type);
}

class _ParenTok extends _Token {
  final bool isOpen;
  const _ParenTok(this.isOpen);
}

class _FuncTok extends _Token {
  final String name;
  const _FuncTok(this.name);
}
