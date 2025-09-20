import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/widgets/utils/pointer_area.dart';

class SimulatedPressController {
  SimulatedPressController();

  _SimulatedPressedState? _state;

  void press() {
    _state?._simulatePress();
  }

  void dispose() {
    _state = null;
  }
}

class SimulatedPress extends StatefulWidget {
  const SimulatedPress({
    super.key,
    required this.child,
    this.controller,
    this.pressedDuration = const Duration(milliseconds: 200),
  });

  final SimulatedPressController? controller;
  final Duration pressedDuration;
  final Widget child;

  @override
  State<SimulatedPress> createState() => _SimulatedPressedState();
}

class _SimulatedPressedState extends State<SimulatedPress> {
  var _request = 0;
  var _isPressed = false;

  @override
  void initState() {
    widget.controller?._state = this;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SimulatedPress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
    widget.controller?._state = null;
    super.dispose();
  }

  Future<void> _simulatePress() async {
    final initialRequire = ++_request;
    setState(() {
      _isPressed = true;
    });
    await Future.delayed(widget.pressedDuration);
    if (initialRequire == _request) {
      setState(() {
        _isPressed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PointerStateProvider(
      state: _isPressed
          ? PointerState(
              isEnabled: true,
              hasFocus: false,
              isPressed: true,
              isHovering: false,
            )
          : null,
      child: widget.child,
    );
  }
}
