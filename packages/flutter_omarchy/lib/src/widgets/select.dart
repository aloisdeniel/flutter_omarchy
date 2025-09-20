import 'package:flutter_omarchy/flutter_omarchy.dart';

typedef OmarchySelectWidgetBuilder<T> =
    Widget Function(BuildContext context, T value);

class OmarchySelect<T> extends StatelessWidget {
  const OmarchySelect({
    super.key,
    required this.builder,
    required this.options,
    this.focusNode,
    this.value = const None(),
    this.placeholder,
    this.onChanged,
    this.direction = OmarchyPopOverDirection.downRight,
    this.maxPopOverHeight = 500,
  });

  final FocusNode? focusNode;
  final Optional<T> value;
  final List<T> options;
  final Widget? placeholder;
  final ValueChanged<T>? onChanged;
  final OmarchySelectWidgetBuilder<T> builder;
  final OmarchyPopOverDirection direction;
  final double? maxPopOverHeight;

  @override
  Widget build(BuildContext context) {
    return OmarchyPopOver(
      popOverDirection: direction,
      popOverBuilder: (context, size, hide) {
        final content = SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final v in options)
                Selected(
                  isSelected: value == v,
                  child: OmarchyTile(
                    title: builder(context, v),
                    onTap: () {
                      onChanged?.call(v);
                      hide();
                    },
                  ),
                ),
            ],
          ),
        );
        return OmarchyPopOverContainer(
          alignment: switch (direction) {
            OmarchyPopOverDirection.upLeft => Alignment.bottomLeft,
            OmarchyPopOverDirection.upRight => Alignment.bottomRight,
            OmarchyPopOverDirection.downLeft => Alignment.topLeft,
            OmarchyPopOverDirection.downRight => Alignment.topRight,
            OmarchyPopOverDirection.down => Alignment.topCenter,
            OmarchyPopOverDirection.up => Alignment.bottomCenter,
            OmarchyPopOverDirection.left => Alignment.centerRight,
            OmarchyPopOverDirection.right => Alignment.centerLeft,
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: size?.width ?? 0,
              maxHeight: switch (maxPopOverHeight) {
                null => double.infinity,
                double maxHeight => maxHeight,
              },
            ),
            child: content,
          ),
        );
      },
      builder: (context, show) => OmarchyButton(
        focusNode: focusNode,
        borderWidth: 0.0,
        onPressed: onChanged != null ? show : null,
        child: switch (value) {
          None() => placeholder ?? Text('Select an option'),
          Some(value: final v) => builder(context, v),
        },
      ),
    );
  }
}
