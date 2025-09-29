import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/divider.dart';
import 'package:flutter_omarchy/src/widgets/text_input.dart';
import 'package:flutter_omarchy/src/widgets/pop_over.dart';
import 'package:flutter_omarchy/src/widgets/utils/selected.dart';

typedef OmarchyCommandPanelResultBuilder<T> =
    Widget Function(
      BuildContext context,
      T result,
      bool isSelected,
      VoidCallback onTap,
    );

typedef OmarchyCommandPanelFilter<T> =
    List<T> Function(String query, List<T> items);

class OmarchyCommandPanel<T> extends StatefulWidget {
  const OmarchyCommandPanel({
    super.key,
    required this.items,
    required this.resultBuilder,
    this.filter,
    this.placeholder = 'Type to search...',
    this.noResultsLabel = 'No results found',
    this.onItemSelected,
    this.maxHeight = 400,
    this.maxDisplayedResults = 10,
    this.autofocus = true,
  });

  final List<T> items;
  final OmarchyCommandPanelResultBuilder<T> resultBuilder;
  final OmarchyCommandPanelFilter<T>? filter;
  final String placeholder;
  final ValueChanged<T>? onItemSelected;
  final double maxHeight;
  final int maxDisplayedResults;
  final bool autofocus;
  final String noResultsLabel;

  @override
  State<OmarchyCommandPanel<T>> createState() => _OmarchyCommandPanelState<T>();
}

class _OmarchyCommandPanelState<T> extends State<OmarchyCommandPanel<T>> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<T> _filteredItems = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final query = _controller.text;
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems =
            widget.filter?.call(query, widget.items) ??
            _defaultFilter(query, widget.items);
      }
      _selectedIndex = 0;
    });
  }

  List<T> _defaultFilter(String query, List<T> items) {
    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      final itemString = item.toString().toLowerCase();
      return itemString.contains(lowerQuery);
    }).toList();
  }

  void _selectNext() {
    if (_filteredItems.isNotEmpty) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % _filteredItems.length;
      });
    }
  }

  void _selectPrevious() {
    if (_filteredItems.isNotEmpty) {
      setState(() {
        _selectedIndex = _selectedIndex > 0
            ? _selectedIndex - 1
            : _filteredItems.length - 1;
      });
    }
  }

  void _selectItem([int? index]) {
    final itemIndex = index ?? _selectedIndex;
    if (itemIndex >= 0 && itemIndex < _filteredItems.length) {
      final item = _filteredItems[itemIndex];
      widget.onItemSelected?.call(item);
    }
  }

  bool _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _selectNext();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _selectPrevious();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        _selectItem();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.of(context).pop();
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final displayedItems = _filteredItems
        .take(widget.maxDisplayedResults)
        .toList();

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyPress,
      child: OmarchyPopOverContainer(
        child: Container(
          width: 400,
          constraints: BoxConstraints(maxHeight: widget.maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OmarchyTextInput(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                controller: _controller,
                focusNode: _focusNode,
                placeholder: Text(widget.placeholder),
                autofocus: widget.autofocus,
              ),
              OmarchyDivider(),
              if (displayedItems.isNotEmpty)
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: displayedItems.length,
                    itemBuilder: (context, index) {
                      final item = displayedItems[index];
                      final isSelected = index == _selectedIndex;
                      return Selected(
                        isSelected: isSelected,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colors.normal.black
                                : Colors.transparent,
                          ),
                          child: widget.resultBuilder(
                            context,
                            item,
                            isSelected,
                            () => _selectItem(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (displayedItems.isEmpty && _controller.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.noResultsLabel,
                    style: theme.text.normal.copyWith(
                      color: theme.colors.bright.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void showOmarchyCommandPanel<T>({
  required BuildContext context,
  required List<T> items,
  required OmarchyCommandPanelResultBuilder<T> resultBuilder,
  OmarchyCommandPanelFilter<T>? filter,
  String placeholder = 'Type to search...',
  String noResultsLabel = 'No results found',
  ValueChanged<T>? onItemSelected,
  double maxHeight = 400,
  int maxDisplayedResults = 10,
  bool autofocus = true,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (context) => Center(
      child: OmarchyCommandPanel<T>(
        items: items,
        resultBuilder: resultBuilder,
        filter: filter,
        placeholder: placeholder,
        noResultsLabel: noResultsLabel,
        onItemSelected: (item) {
          Navigator.of(context).pop();
          onItemSelected?.call(item);
        },
        maxHeight: maxHeight,
        maxDisplayedResults: maxDisplayedResults,
        autofocus: autofocus,
      ),
    ),
  );
}
