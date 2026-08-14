import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/colors.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/divider.dart';
import 'package:flutter_omarchy/src/widgets/utils/default_foreground.dart';
import 'package:flutter_omarchy/src/widgets/utils/pointer_area.dart';

/// Base class for the entries of an Omarchy context menu.
///
/// See [OmarchyContextMenuItem] and [OmarchyContextMenuDivider].
sealed class OmarchyContextMenuEntry {
  const OmarchyContextMenuEntry();
}

/// A selectable entry of a context menu.
class OmarchyContextMenuItem extends OmarchyContextMenuEntry {
  /// Creates a context menu item with the specified [label].
  const OmarchyContextMenuItem({
    required this.label,
    this.icon,
    this.shortcut,
    this.accent,
    this.enabled = true,
    this.onSelected,
  });

  /// The label of the item.
  final String label;

  /// An optional leading icon.
  final IconData? icon;

  /// An optional keyboard shortcut hint (e.g. `Ctrl+C`), displayed at the
  /// end of the item.
  final String? shortcut;

  /// An optional accent color for the item, typically used for destructive
  /// actions (e.g. [AnsiColor.red]).
  final AnsiColor? accent;

  /// Whether the item can be selected.
  final bool enabled;

  /// Called when the item is selected. The menu is closed first.
  final VoidCallback? onSelected;
}

/// A separator between groups of context menu items.
class OmarchyContextMenuDivider extends OmarchyContextMenuEntry {
  const OmarchyContextMenuDivider();
}

/// Shows an Omarchy context menu at the given global [position].
///
/// The returned future completes when the menu is closed, with the selected
/// [OmarchyContextMenuItem] or null if the menu was dismissed.
///
/// The menu is dismissed by clicking outside of it or pressing Escape, and
/// is repositioned automatically to stay within the screen bounds.
Future<OmarchyContextMenuItem?> showOmarchyContextMenu({
  required BuildContext context,
  required Offset position,
  required List<OmarchyContextMenuEntry> entries,
  double minWidth = 180,
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  final selected = await navigator.push(
    _ContextMenuRoute(
      position: position,
      entries: entries,
      minWidth: minWidth,
      capturedThemes: OmarchyTheme.of(context),
    ),
  );
  if (selected != null) {
    selected.onSelected?.call();
  }
  return selected;
}

/// A region that shows an Omarchy context menu when right-clicked
/// (or long-pressed on touch devices).
///
/// {@tool snippet}
/// ```dart
/// OmarchyContextMenuArea(
///   entries: [
///     OmarchyContextMenuItem(
///       label: 'Copy',
///       icon: OmarchyIcons.codCopy,
///       shortcut: 'Ctrl+C',
///       onSelected: copy,
///     ),
///     const OmarchyContextMenuDivider(),
///     OmarchyContextMenuItem(
///       label: 'Delete',
///       accent: AnsiColor.red,
///       onSelected: delete,
///     ),
///   ],
///   child: FileTile(),
/// )
/// ```
/// {@end-tool}
class OmarchyContextMenuArea extends StatelessWidget {
  /// Creates a context menu area wrapping [child].
  const OmarchyContextMenuArea({
    super.key,
    required this.child,
    this.entries,
    this.entriesBuilder,
  }) : assert(
         entries != null || entriesBuilder != null,
         'Either entries or entriesBuilder must be provided.',
       );

  /// The widget that reacts to secondary clicks.
  final Widget child;

  /// The entries of the menu.
  final List<OmarchyContextMenuEntry>? entries;

  /// Builds the entries lazily each time the menu is opened.
  ///
  /// Takes precedence over [entries] when both are provided.
  final List<OmarchyContextMenuEntry> Function(BuildContext context)?
  entriesBuilder;

  void _show(BuildContext context, Offset globalPosition) {
    final effectiveEntries = entriesBuilder?.call(context) ?? entries!;
    if (effectiveEntries.isEmpty) return;
    showOmarchyContextMenu(
      context: context,
      position: globalPosition,
      entries: effectiveEntries,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapUp: (details) => _show(context, details.globalPosition),
      onLongPressStart: (details) => _show(context, details.globalPosition),
      child: child,
    );
  }
}

class _ContextMenuRoute extends PopupRoute<OmarchyContextMenuItem> {
  _ContextMenuRoute({
    required this.position,
    required this.entries,
    required this.minWidth,
    required this.capturedThemes,
  });

  final Offset position;
  final List<OmarchyContextMenuEntry> entries;
  final double minWidth;
  final OmarchyThemeData capturedThemes;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 100);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return OmarchyThemeProvider(
      data: capturedThemes,
      child: CustomSingleChildLayout(
        delegate: _ContextMenuLayoutDelegate(position: position),
        child: _ContextMenu(entries: entries, minWidth: minWidth),
      ),
    );
  }
}

class _ContextMenuLayoutDelegate extends SingleChildLayoutDelegate {
  const _ContextMenuLayoutDelegate({required this.position});

  final Offset position;

  static const _margin = 8.0;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(
      Size(
        constraints.maxWidth - _margin * 2,
        constraints.maxHeight - _margin * 2,
      ),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    var dx = position.dx;
    var dy = position.dy;
    if (dx + childSize.width > size.width - _margin) {
      dx = position.dx - childSize.width;
    }
    if (dy + childSize.height > size.height - _margin) {
      dy = position.dy - childSize.height;
    }
    dx = dx.clamp(_margin, size.width - childSize.width - _margin);
    dy = dy.clamp(_margin, size.height - childSize.height - _margin);
    return Offset(dx, dy);
  }

  @override
  bool shouldRelayout(covariant _ContextMenuLayoutDelegate oldDelegate) {
    return position != oldDelegate.position;
  }
}

class _ContextMenu extends StatelessWidget {
  const _ContextMenu({required this.entries, required this.minWidth});

  final List<OmarchyContextMenuEntry> entries;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth, maxWidth: 320),
      child: DefaultTextStyle(
        style: theme.text.normal.copyWith(color: theme.colors.foreground),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colors.background,
            border: Border.all(color: theme.colors.border, width: 2),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in entries)
                  switch (entry) {
                    OmarchyContextMenuItem item => _ContextMenuTile(item: item),
                    OmarchyContextMenuDivider() => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: OmarchyDivider.horizontal(),
                    ),
                  },
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContextMenuTile extends StatelessWidget {
  const _ContextMenuTile({required this.item});

  final OmarchyContextMenuItem item;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final accentColor = switch (item.accent) {
      AnsiColor accent => theme.colors.bright[accent],
      null => theme.colors.foreground,
    };
    if (!item.enabled) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: _ContextMenuTileContent(
          item: item,
          foreground: theme.colors.bright.black,
          shortcutForeground: theme.colors.bright.black,
        ),
      );
    }
    return PointerArea(
      onTap: () => Navigator.of(context).pop(item),
      builder: (context, state, _) {
        final hovering = state.isHovering || state.hasFocus;
        return Container(
          color: hovering
              ? theme.colors.normal.black
              : theme.colors.normal.black.withValues(alpha: 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: _ContextMenuTileContent(
            item: item,
            foreground: hovering ? theme.colors.selectedText : accentColor,
            shortcutForeground: theme.colors.bright.black,
          ),
        );
      },
    );
  }
}

class _ContextMenuTileContent extends StatelessWidget {
  const _ContextMenuTileContent({
    required this.item,
    required this.foreground,
    required this.shortcutForeground,
  });

  final OmarchyContextMenuItem item;
  final Color foreground;
  final Color shortcutForeground;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return DefaultForeground(
      foreground: foreground,
      child: Row(
        spacing: 8,
        children: [
          if (item.icon case final icon?) Icon(icon, size: 16),
          Expanded(child: Text(item.label, maxLines: 1)),
          if (item.shortcut case final shortcut?)
            Text(
              shortcut,
              style: theme.text.italic.copyWith(
                color: shortcutForeground,
                fontSize: (theme.text.normal.fontSize ?? 14) - 2,
              ),
            ),
        ],
      ),
    );
  }
}
