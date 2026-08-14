import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_omarchy/src/config/config.dart';
import 'package:flutter_omarchy/src/theme/text.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';

/// The root widget that provides Omarchy theming to its descendants.
///
/// This widget establishes the theme context for all child widgets and handles
/// automatic theme updates when configuration changes are detected. It also
/// manages font loading and provides default text and icon styling.
///
/// {@tool snippet}
/// ```dart
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Omarchy(
///       child: MaterialApp(
///         home: MyHomePage(),
///       ),
///     );
///   }
/// }
/// ```
/// {@end-tool}
class Omarchy extends StatefulWidget {
  /// Creates an Omarchy widget with the given [child] and optional [theme].
  ///
  /// The [child] parameter is required and represents the widget tree that
  /// will have access to the Omarchy theme.
  ///
  /// If [theme] is provided, it will be used instead of the theme from
  /// configuration files. If [theme] is null, the widget will automatically
  /// load and watch for changes in the configuration files.
  const Omarchy({super.key, required this.child, this.theme});
  
  /// The widget below this widget in the tree.
  final Widget child;
  
  /// The theme data to use for this widget and its descendants.
  ///
  /// If null, the theme will be loaded from configuration files and
  /// automatically updated when the configuration changes.
  final OmarchyThemeData? theme;

  /// Initializes the Omarchy system by loading configuration and fonts.
  ///
  /// This method should be called before using any Omarchy widgets to ensure
  /// that all necessary fonts and configurations are properly loaded.
  ///
  /// {@tool snippet}
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await Omarchy.initialize();
  ///   runApp(MyApp());
  /// }
  /// ```
  /// {@end-tool}
  static Future<void> initialize() async {
    final config = OmarchyConfigData.read();
    final text = OmarchyTextStyleData.fromConfig(config);
    await text.loadFonts();
  }

  @override
  State<Omarchy> createState() => _OmarchyState();
}

class _OmarchyState extends State<Omarchy> {
  late OmarchyConfigData _config;
  StreamSubscription<OmarchyConfigData>? configSubscription;

  void startObservingThemeFromConfig() {
    _config = OmarchyConfigData.read();
    configSubscription = OmarchyConfigData.watch().listen(_onConfigChange);
  }

  void stopObservingThemeFromConfig() {
    configSubscription?.cancel();
    configSubscription = null;
  }

  @override
  void initState() {
    super.initState();
    startObservingThemeFromConfig();
  }

  @override
  void dispose() {
    stopObservingThemeFromConfig();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Omarchy oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.theme != oldWidget.theme) {
      if (widget.theme != null) {
        stopObservingThemeFromConfig();
      } else {
        startObservingThemeFromConfig();
      }
    }
  }

  void _onConfigChange(OmarchyConfigData config) async {
    final text = OmarchyTextStyleData.fromConfig(config);
    await text.loadFonts();
    setState(() {
      _config = config;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        widget.theme ??
        OmarchyThemeProvider.maybeOf(context) ??
        OmarchyThemeData.fromConfig(_config);
    return IconTheme(
      data: IconThemeData(size: 18, color: theme.colors.foreground),
      child: DefaultTextStyle(
        style: theme.text.normal.copyWith(color: theme.colors.foreground),
        child: OmarchyThemeProvider(data: theme, child: widget.child),
      ),
    );
  }
}
