import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/utils/default_padding.dart';

typedef OmarchyInputContainerBuilder =
    Widget Function(BuildContext context, FocusNode node);

class OmarchyInputContainer extends StatelessWidget {
  const OmarchyInputContainer({
    super.key,
    required this.builder,
    this.focusNode,
  });

  final FocusNode? focusNode;
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

class OmarchyFocusBorder extends StatefulWidget {
  const OmarchyFocusBorder({super.key, required this.builder, this.focusNode});

  final FocusNode? focusNode;
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
