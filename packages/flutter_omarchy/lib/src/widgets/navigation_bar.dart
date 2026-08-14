import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/button.dart';
import 'package:flutter_omarchy/src/widgets/utils/title_bar.dart';

/// A top navigation bar widget for desktop-style applications.
///
/// This navigation bar displays a title in the center with optional
/// leading and trailing widgets (typically buttons or icons). It's
/// designed to provide familiar desktop application navigation patterns.
///
/// {@tool snippet}
/// ```dart
/// OmarchyNavigationBar(
///   title: Text('Document Editor'),
///   leading: [
///     OmarchyButton(child: Icon(Icons.menu), onPressed: () => showMenu()),
///     OmarchyButton(child: Icon(Icons.save), onPressed: () => save()),
///   ],
///   trailing: [
///     OmarchyButton(child: Icon(Icons.settings), onPressed: () => showSettings()),
///   ],
/// )
/// ```
/// {@end-tool}
class OmarchyNavigationBar extends StatelessWidget {
  /// Creates a navigation bar with the specified [title] and optional widgets.
  const OmarchyNavigationBar({
    super.key,
    required this.title,
    this.height,
    this.leading,
    this.trailing,
  });

  /// The title widget displayed in the center of the navigation bar.
  final Widget title;
  
  /// The leading widgets displayed on the left side of the navigation bar.
  ///
  /// These widgets are automatically styled with bar-style buttons.
  final List<Widget>? leading;
  
  /// The trailing widgets displayed on the right side of the navigation bar.
  ///
  /// These widgets are automatically styled with bar-style buttons.
  final List<Widget>? trailing;
  
  /// The height of the navigation bar.
  ///
  /// If null, calculates the height based on the current text style.
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
