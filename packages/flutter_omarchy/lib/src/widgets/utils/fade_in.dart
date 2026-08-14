import 'package:flutter/widgets.dart';

/// A widget that fades in its child with a smooth opacity animation.
///
/// This widget automatically starts a fade-in animation after the first frame
/// is rendered, making it useful for entrance animations and revealing content
/// with a polished visual effect.
///
/// {@tool snippet}
/// ```dart
/// FadeIn(
///   duration: Duration(milliseconds: 500),
///   child: Text('This text will fade in smoothly'),
/// )
/// ```
/// {@end-tool}
class FadeIn extends StatefulWidget {
  /// Creates a fade-in animation widget.
  const FadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
  });

  /// The widget to animate with a fade-in effect.
  final Widget child;
  
  /// The duration of the fade-in animation.
  final Duration duration;

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> {
  var _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: widget.duration,
      child: widget.child,
    );
  }
}
