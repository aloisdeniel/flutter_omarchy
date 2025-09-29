import 'package:flutter/widgets.dart';

class StateBuilder<T> extends StatefulWidget {
  const StateBuilder({
    super.key,
    required this.initialState,
    required this.builder,
  });

  final T initialState;
  final Widget Function(BuildContext context, T state, ValueChanged<T> setter)
  builder;

  @override
  State<StateBuilder<T>> createState() => _StateBuilderState<T>();
}

class _StateBuilderState<T> extends State<StateBuilder<T>> {
  late T state = widget.initialState;
  @override
  Widget build(BuildContext context) {
    return widget.builder(context, state, (v) {
      setState(() {
        state = v;
      });
    });
  }
}
