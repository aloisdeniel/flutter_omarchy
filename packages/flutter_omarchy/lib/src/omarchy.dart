import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_omarchy/src/config/config.dart';
import 'package:flutter_omarchy/src/theme/text.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';

class Omarchy extends StatefulWidget {
  const Omarchy({super.key, required this.child, this.theme});
  final Widget child;
  final OmarchyThemeData? theme;

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
