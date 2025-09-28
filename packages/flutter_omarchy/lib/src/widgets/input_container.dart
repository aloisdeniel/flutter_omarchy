import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/utils/default_padding.dart';

/// A function that builds input content with access to a focus node.
typedef OmarchyInputContainerBuilder =
    Widget Function(BuildContext context, FocusNode node);

/// A container widget that provides consistent styling for input fields.
///
/// This widget wraps input content with a themed border and default padding,
/// creating a consistent appearance for form fields and other input components
/// throughout the application.
///
/// {@tool snippet}
/// ```dart
/// OmarchyInputContainer(
///   builder: (context, focusNode) => TextField(
///     focusNode: focusNode,
///     decoration: InputDecoration(
///       hintText: 'Enter your name',
///       border: InputBorder.none,
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
class OmarchyInputContainer extends StatelessWidget {
  /// Creates an input container with the specified builder.
  const OmarchyInputContainer({
    super.key,
    required this.builder,
    this.focusNode,
  });

  /// The focus node for the input field.
  ///
  /// If null, an internal focus node is created.
  final FocusNode? focusNode;
  
  /// Builder function that creates the input content.
  final OmarchyInputContainerBuilder builder;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return OmarchyFocusBorder(
      builder: (context, node) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.normal.white, width: 1),
        ),
        child: DefaultPadding(
          padding: const EdgeInsets.all(8.0),
          child: builder(context, node),
        ),
      ),
    );
  }
}

/// A widget that provides focus-aware border styling for input components.
///
/// This widget animates the border appearance based on focus state, providing
/// visual feedback when input fields receive or lose focus. It's typically
/// used as a building block for custom input widgets.
class OmarchyFocusBorder extends StatefulWidget {
  /// Creates a focus-aware border widget.
  const OmarchyFocusBorder({super.key, required this.builder, this.focusNode});

  /// The focus node to observe for focus changes.
  ///
  /// If null, an internal focus node is created.
  final FocusNode? focusNode;
  
  /// Builder function that creates the bordered content.
  final OmarchyInputContainerBuilder builder;

  @override
  State<OmarchyFocusBorder> createState() => _OmarchyFocusBorderState();
}

class _OmarchyFocusBorderState extends State<OmarchyFocusBorder> {
  late final focusNode = widget.focusNode ?? FocusNode();
  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return AnimatedBuilder(
      animation: focusNode,
      child: widget.builder(context, focusNode),
      builder: (context, child) => Stack(
        children: [
          child!,
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: switch (focusNode.hasFocus) {
                      true => theme.colors.border,
                      _ => theme.colors.normal.black,
                    },
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
