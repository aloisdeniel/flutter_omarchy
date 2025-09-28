import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/icon_data.g.dart';
import 'package:flutter_omarchy/src/widgets/utils/default_foreground.dart';
import 'package:flutter_omarchy/src/widgets/utils/fade_in.dart';
import 'package:flutter_omarchy/src/widgets/utils/grouping.dart';
import 'package:flutter_omarchy/src/widgets/utils/pointer_area.dart';

/// Controller for managing the expanded/collapsed state of tree nodes.
///
/// This controller maintains the set of expanded nodes and provides methods
/// to programmatically expand, collapse, and toggle tree nodes. It notifies
/// listeners when the expansion state changes.
class OmarchyTreeController<T> extends ChangeNotifier {
  /// Creates a tree controller with an optional set of initially expanded nodes.
  OmarchyTreeController({Set<T>? expandedNodes})
    : _expandedNodes = expandedNodes ?? <T>{};

  final Set<T> _expandedNodes;

  /// Expands the specified [node].
  ///
  /// If the node is already expanded, this method has no effect.
  void expand(OmarchyTreeNode<T> node) {
    if (_expandedNodes.add(node.id)) {
      notifyListeners();
    }
  }

  /// Collapses the specified [node].
  ///
  /// If the node is already collapsed, this method has no effect.
  void collapse(OmarchyTreeNode<T> node) {
    if (_expandedNodes.remove(node.id)) {
      notifyListeners();
    }
  }

  /// Returns whether the specified [node] is currently expanded.
  bool isExpanded(OmarchyTreeNode<T> node) {
    return _expandedNodes.contains(node.id);
  }

  /// Toggles the expansion state of the specified [node].
  ///
  /// If the node is expanded, it will be collapsed. If collapsed, it will be expanded.
  void toggle(OmarchyTreeNode<T> node) {
    if (isExpanded(node)) {
      collapse(node);
    } else {
      expand(node);
    }
  }

  /// Collapses all currently expanded nodes.
  void collapseAll() {
    if (_expandedNodes.isNotEmpty) {
      _expandedNodes.clear();
      notifyListeners();
    }
  }
}

class OmarchyTreeScope<T> extends InheritedModel<T> {
  OmarchyTreeScope({
    super.key,
    required this.controller,
    required Set<T> selectedItems,
    required super.child,
  }) : selectedItems = Set.unmodifiable(selectedItems);

  final OmarchyTreeController<T>? controller;
  final Set<T> selectedItems;

  static OmarchyTreeController<T>? maybeOf<T>(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<OmarchyTreeScope<T>>();
    return widget?.controller;
  }

  static bool? isExpanded<T>(BuildContext context, T id) {
    final controller = context
        .dependOnInheritedWidgetOfExactType<OmarchyTreeScope<T>>(aspect: id);
    if (controller == null) {
      return null;
    }
    return controller.selectedItems.contains(id);
  }

  @override
  bool updateShouldNotify(covariant OmarchyTreeScope<T> oldWidget) {
    if (oldWidget.controller != controller) return true;
    return !setEquals(oldWidget.selectedItems, selectedItems);
  }

  @override
  bool updateShouldNotifyDependent(
    covariant OmarchyTreeScope<T> oldWidget,
    Set<T> dependencies,
  ) {
    if (oldWidget.controller != controller) return true;

    for (final dependency in dependencies) {
      final wasSelected = oldWidget.selectedItems.contains(dependency);
      final isSelected = selectedItems.contains(dependency);
      if (wasSelected != isSelected) {
        return true;
      }
    }
    return false;
  }
}

class OmarchyTree<T> extends StatelessWidget {
  const OmarchyTree({super.key, required this.children, this.controller});

  final OmarchyTreeController<T>? controller;
  final List<OmarchyTreeNode<T>> children;

  @override
  Widget build(BuildContext context) {
    final result = CustomScrollView(
      slivers: [
        for (var i = 0; i < children.length; i++)
          Grouping(
            position: (i, children.length),
            child: OmarchyTreeNodeSliver(node: children[i]),
          ),
      ],
    );
    if (controller != null) {
      return AnimatedBuilder(
        animation: controller!,
        builder: (context, _) {
          return OmarchyTreeScope<T>(
            controller: controller,
            selectedItems: controller!._expandedNodes,
            child: result,
          );
        },
      );
    }
    return result;
  }
}

class OmarchyTreeNodeSliver<T> extends StatelessWidget {
  const OmarchyTreeNodeSliver({
    super.key,
    required this.node,
    this.fadeIn = false,
  });

  final OmarchyTreeNode<T> node;
  final bool fadeIn;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final isExpanded =
        node.isExpanded ??
        OmarchyTreeScope.isExpanded<T>(context, node.id) == true;
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: fadeIn ? FadeIn(child: node) : node),
        if (isExpanded)
          SliverPadding(
            padding: const EdgeInsets.only(left: 6.0),
            sliver: DecoratedSliver(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: theme.colors.normal.black, width: 1),
                ),
              ),
              sliver: SliverPadding(
                padding: const EdgeInsets.only(left: 12.0),
                sliver: SliverMainAxisGroup(
                  slivers: [
                    for (var i = 0; i < node.children.length; i++)
                      Grouping(
                        position: (i, node.children.length),
                        child: OmarchyTreeNodeSliver(
                          fadeIn: true,
                          node: node.children[i],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class OmarchyTreeNode<T> extends StatelessWidget {
  const OmarchyTreeNode({
    super.key,
    required this.id,
    this.children = const [],
    this.isExpanded,
    this.icon,
    this.title,
    this.trailing,
    this.onTap,
  });

  final T id;
  final bool? isExpanded;
  final Widget? title;
  final Widget? trailing;
  final Widget? icon;
  final List<OmarchyTreeNode<T>> children;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final icon = this.icon;
    final title = this.title;
    final trailing = this.trailing;
    final isExpanded =
        this.isExpanded ?? OmarchyTreeScope.isExpanded(context, id) == true;
    return PointerArea(
      onTap: () {
        final controller = OmarchyTreeScope.maybeOf<T>(context);
        if (controller != null) {
          controller.toggle(this);
        }
        onTap?.call();
      },
      builder: (context, state, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          spacing: 4,
          children: [
            if (children.isNotEmpty)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.rotationZ(!isExpanded ? 0 : math.pi / 2),
                transformAlignment: Alignment.center,
                child: Icon(
                  OmarchyIcons.codChevronRight,
                  size: 12,
                  color: switch (state) {
                    _ when isExpanded => theme.colors.normal.blue,
                    PointerState(isPressed: true) => theme.colors.normal.blue,
                    PointerState(isHovering: true) => theme.colors.normal.white,
                    _ => theme.colors.normal.black,
                  },
                ),
              )
            else
              SizedBox(width: 12, height: 12),
            if (icon != null)
              IconTheme(
                data: IconThemeData(color: theme.colors.normal.blue, size: 18),
                child: icon,
              ),
            if (title != null)
              DefaultForeground(
                foreground: switch (state) {
                  PointerState(isPressed: true) => theme.colors.bright.white,
                  PointerState(isHovering: true) => theme.colors.selectedText,
                  _ => theme.colors.bright.white,
                },
                textStyle: theme.text.normal,
                child: title,
              ),
            const Spacer(),
            if (trailing != null)
              DefaultForeground(
                foreground: switch (state) {
                  PointerState(
                    isEnabled: true,
                    isPressed: false,
                    isHovering: true,
                  ) =>
                    theme.colors.normal.white,
                  _ => theme.colors.normal.black,
                },
                textStyle: theme.text.italic,
                child: trailing,
              ),
          ],
        ),
      ),
    );
  }
}
