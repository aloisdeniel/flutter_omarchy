import 'package:flutter_omarchy/flutter_omarchy.dart';

/// A function that builds a widget representation of a select option value.
typedef OmarchySelectWidgetBuilder<T> =
    Widget Function(BuildContext context, T value);

/// A dropdown select widget that presents options in a popup overlay.
///
/// This widget provides a button-like interface that, when pressed, shows
/// a dropdown list of selectable options. It's ideal for settings, filters,
/// and other single-choice selection scenarios.
///
/// {@tool snippet}
/// ```dart
/// OmarchySelect<String>(
///   value: Some(selectedTheme),
///   options: ['light', 'dark', 'auto'],
///   builder: (context, value) => Text(value.toUpperCase()),
///   onChanged: (newTheme) => setState(() => selectedTheme = newTheme),
///   placeholder: Text('Choose theme...'),
/// )
/// ```
/// {@end-tool}
class OmarchySelect<T> extends StatelessWidget {
  /// Creates a select widget with the specified options and builder.
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

  /// The focus node for keyboard navigation.
  final FocusNode? focusNode;
  
  /// The currently selected value.
  ///
  /// Use [Some(value)] for a selected value or [None()] for no selection.
  final Optional<T> value;
  
  /// The list of available options to choose from.
  final List<T> options;
  
  /// The widget to display when no value is selected.
  final Widget? placeholder;
  
  /// Callback called when a new value is selected.
  final ValueChanged<T>? onChanged;
  
  /// Function that builds the display widget for each option value.
  final OmarchySelectWidgetBuilder<T> builder;
  
  /// The direction in which the dropdown opens.
  final OmarchyPopOverDirection direction;
  
  /// The maximum height of the dropdown popup.
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
