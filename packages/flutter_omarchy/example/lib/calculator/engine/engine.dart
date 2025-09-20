import 'package:decimal/decimal.dart';

sealed class CalculationState {
  CalculationState();
}

class IntermediateCalculationState extends CalculationState {
  IntermediateCalculationState({required this.input, this.previousResult});
  final Decimal? previousResult;
  final String input;
}

class ErrorCalculationState extends CalculationState {
  ErrorCalculationState({required this.error});
  final Object? error;
}
