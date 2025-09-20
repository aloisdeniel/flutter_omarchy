import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/button.dart';
import 'package:flutter_omarchy/src/widgets/utils/title_bar.dart';

class OmarchyNavigationBar extends StatelessWidget {
  const OmarchyNavigationBar({
    super.key,
    required this.title,
    this.height,
    this.leading,
    this.trailing,
  });

  final Widget title;
  final List<Widget>? leading;
  final List<Widget>? trailing;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);

    return Container(
      height: theme.text.normal.fontSize! * 4,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: theme.colors.normal.black),
        ),
      ),
      child: TitleBar(
        title: DefaultTextStyle(
          style: theme.text.bold.copyWith(color: theme.colors.foreground),
          child: title,
        ),
        leading: leading != null
            ? OmarchyButtonTheme(
                data: OmarchyButtonStyle.bar(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [...leading!],
                ),
              )
            : const SizedBox.shrink(),
        trailing: trailing != null
            ? OmarchyButtonTheme(
                data: OmarchyButtonStyle.bar(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [...trailing!],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
