import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/config/config.dart';
import 'package:flutter_omarchy/src/theme/colors.dart';
import 'package:flutter_omarchy/src/theme/text.dart';

abstract class OmarchyTheme {
  static OmarchyThemeData of(BuildContext context) {
    return OmarchyThemeProvider.maybeOf(context)!;
  }

  static OmarchyThemeData? maybeOf(BuildContext context) {
    return OmarchyThemeProvider.maybeOf(context);
  }
}

class OmarchyThemeProvider extends InheritedWidget {
  const OmarchyThemeProvider({
    super.key,
    required this.data,
    required super.child,
  });

  final OmarchyThemeData data;

  static OmarchyThemeData? maybeOf(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<OmarchyThemeProvider>();
    return inherited?.data;
  }

  @override
  bool updateShouldNotify(covariant OmarchyThemeProvider oldWidget) {
    return oldWidget.data != data;
  }
}

class OmarchyThemeData {
  const OmarchyThemeData({required this.colors, required this.text});

  final OmarchyColorThemeData colors;
  final OmarchyTextStyleData text;

  static OmarchyThemeData fromConfig(OmarchyConfigData config) {
    final colors = OmarchyColorThemeData.fromConfig(config);
    final text = OmarchyTextStyleData.fromConfig(config);
    return OmarchyThemeData(
      colors: colors,
      text: OmarchyTextStyleData(
        bold: text.bold.copyWith(color: colors.foreground),
        normal: text.normal.copyWith(color: colors.foreground),
        italic: text.italic.copyWith(color: colors.foreground),
      ),
    );
  }
}
