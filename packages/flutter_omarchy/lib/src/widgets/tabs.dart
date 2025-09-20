import 'package:flutter/material.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/utils/default_foreground.dart';
import 'package:flutter_omarchy/src/widgets/utils/default_padding.dart';
import 'package:flutter_omarchy/src/widgets/utils/pointer_area.dart';
import 'package:flutter_omarchy/src/widgets/utils/selected.dart';

class OmarchyTabs extends StatelessWidget {
  const OmarchyTabs({
    super.key,
    required this.children,
    this.padding = const EdgeInsetsGeometry.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
  });

  final EdgeInsetsGeometry padding;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return Container(
      color: theme.colors.normal.black,
      height: 44,
      child: DefaultPadding(
        padding: padding,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [...children],
          ),
        ),
      ),
    );
  }
}

class OmarchyTab extends StatelessWidget {
  const OmarchyTab({
    super.key,
    required this.title,
    this.icon,
    this.onClose,
    this.close,
    this.onTap,
    this.isActive = false,
  });

  const OmarchyTab.closable({
    super.key,
    required this.title,
    required VoidCallback this.onClose,
    this.icon,
    this.onTap,
    Widget? close,
    this.isActive = false,
  }) : close = close ?? const Icon(Icons.close);

  final bool isActive;
  final Widget? icon;
  final Widget title;
  final Widget? close;
  final VoidCallback? onClose;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    Widget child = Center(child: title);
    if (icon != null || close != null) {
      child = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 12,
        children: [
          if (icon case final icon?) icon,
          child,
          if (close case final close?) close,
        ],
      );
    }
    return Selected(
      isSelected: isActive,
      child: PointerArea(
        onTap: onTap,
        child: child,
        builder: (context, state, child) {
          final background = switch (state) {
            PointerState(isHovering: true) when isActive =>
              theme.colors.background,
            PointerState(isHovering: true) => theme.colors.bright.black,
            _ when isActive => theme.colors.background,
            _ => theme.colors.normal.black,
          };
          final foreground = switch (state) {
            PointerState(isHovering: true) when isActive =>
              theme.colors.foreground,
            PointerState(isHovering: true) => theme.colors.bright.white,
            _ when isActive => theme.colors.foreground,
            _ => theme.colors.normal.white,
          };
          return Container(
            decoration: BoxDecoration(color: background),
            padding: DefaultPadding.of(context),
            child: DefaultForeground(
              foreground: foreground,
              textStyle: isActive ? theme.text.italic : theme.text.normal,
              child: child!,
            ),
          );
        },
      ),
    );
  }
}
