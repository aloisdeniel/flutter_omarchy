import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_omarchy/src/omarchy.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';

class OmarchyApp extends StatelessWidget {
  const OmarchyApp({
    super.key,
    required this.home,
    this.debugShowCheckedModeBanner = kDebugMode,
    this.theme,
    this.localizationsDelegates,
  });

  final bool debugShowCheckedModeBanner;
  final OmarchyThemeData? theme;
  final Widget home;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  static PageRoute<T> defaultPageRouteBuilder<T>(
    RouteSettings settings,
    WidgetBuilder builder,
  ) {
    return PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) {
        return builder(context);
      },
    );
  }

  Iterable<LocalizationsDelegate<dynamic>> get _localizationsDelegates {
    return <LocalizationsDelegate<dynamic>>[
      if (localizationsDelegates != null) ...localizationsDelegates!,
      DefaultMaterialLocalizations.delegate,
      DefaultCupertinoLocalizations.delegate,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Omarchy(
      theme: theme,
      child: Builder(
        builder: (context) {
          final theme = OmarchyTheme.of(context);
          return WidgetsApp(
            debugShowCheckedModeBanner: debugShowCheckedModeBanner,
            localizationsDelegates: _localizationsDelegates,
            color: theme.colors.border,
            pageRouteBuilder: defaultPageRouteBuilder,
            textStyle: theme.text.normal.copyWith(
              color: theme.colors.foreground,
            ),
            home: home,
          );
        },
      ),
    );
  }
}
