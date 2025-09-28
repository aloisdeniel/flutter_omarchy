import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_omarchy/src/omarchy.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';

/// A top-level application widget that sets up the Omarchy design system.
///
/// This widget provides a complete application structure with Omarchy theming,
/// localization support, and navigation. It's similar to [MaterialApp] but
/// specifically designed for the Omarchy design system.
///
/// {@tool snippet}
/// ```dart
/// OmarchyApp(
///   theme: OmarchyThemeData.fromConfig(config),
///   home: MyHomePage(),
/// )
/// ```
/// {@end-tool}
class OmarchyApp extends StatelessWidget {
  /// Creates an Omarchy application with the specified [home] widget.
  const OmarchyApp({
    super.key,
    required this.home,
    this.debugShowCheckedModeBanner = kDebugMode,
    this.theme,
    this.localizationsDelegates,
  });

  /// Whether to show the debug banner in debug builds.
  final bool debugShowCheckedModeBanner;
  
  /// The theme data to use for the application.
  ///
  /// If null, the theme will be loaded from configuration files.
  final OmarchyThemeData? theme;
  
  /// The widget displayed as the home page of the application.
  final Widget home;
  
  /// Delegates for localization support.
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// The default page route builder for navigation.
  ///
  /// Creates instant page transitions without animations for a more
  /// desktop-like navigation experience.
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
