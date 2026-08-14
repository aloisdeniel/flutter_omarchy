import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_omarchy/src/config/alacritty.dart';
import 'package:flutter_omarchy/src/config/theme_config.dart';

/// Configuration data for the Omarchy theming system.
///
/// This class aggregates the current Omarchy theme (its canonical
/// `colors.toml` palette) and the Alacritty terminal configuration (used for
/// font settings) to provide a unified theming experience across desktop
/// applications.
class OmarchyConfigData {
  /// Creates configuration data with the specified [theme] and [alacritty]
  /// configs.
  const OmarchyConfigData({required this.theme, required this.alacritty});

  /// The currently applied Omarchy theme.
  ///
  /// May be null on non-Linux platforms, or on Omarchy versions that predate
  /// the `colors.toml` theme format.
  final OmarchyThemeConfig? theme;

  /// Configuration data loaded from Alacritty terminal settings.
  ///
  /// This contains fonts and color schemes that are used to theme UI
  /// components, and acts as a color fallback on older Omarchy versions.
  /// May be null on non-Linux platforms or when Alacritty is not available.
  final AlacrittyConfig? alacritty;

  /// Reads configuration data from the file system.
  ///
  /// This method attempts to load the current Omarchy theme and the Alacritty
  /// configuration. On non-Linux platforms or web, it returns a configuration
  /// with null values.
  static OmarchyConfigData read() {
    if (kIsWeb || !Platform.isLinux) {
      return const OmarchyConfigData(theme: null, alacritty: null);
    }
    return OmarchyConfigData(
      theme: OmarchyThemeConfig.read(),
      alacritty: AlacrittyConfig.read(),
    );
  }

  /// Watch for config changes and yield updated config data.
  ///
  /// This only works on Linux. When a theme is applied, Omarchy atomically
  /// swaps the `~/.local/state/omarchy/current/theme` directory and rewrites
  /// the `theme.name` file, so watching that state directory is the reliable
  /// way to detect theme changes. The Alacritty config directory is watched
  /// too so that font changes (`omarchy font set`) are picked up, and the
  /// SIGUSR2 signal is kept for backwards compatibility with older Omarchy
  /// versions.
  static Stream<OmarchyConfigData> watch({List<Directory>? directories}) {
    if (kIsWeb || !Platform.isLinux) {
      return const Stream.empty();
    }

    final controller = StreamController<OmarchyConfigData>();
    final subscriptions = <StreamSubscription<Object?>>[];
    Timer? debounce;

    void onEvent(Object? event) {
      // A theme change touches many files in a short burst, so debounce
      // before reading the new configuration.
      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 200), () {
        if (!controller.isClosed) {
          controller.add(read());
        }
      });
    }

    controller.onListen = () {
      final home = Platform.environment['HOME'];
      final watched =
          directories ??
          [
            Directory('$home/.local/state/omarchy/current'),
            Directory('$home/.config/omarchy/current'),
            Directory('$home/.config/alacritty'),
          ];
      for (final dir in watched) {
        if (dir.existsSync()) {
          subscriptions.add(
            dir.watch().listen(onEvent, onError: (Object _) {}),
          );
        }
      }
      subscriptions.add(ProcessSignal.sigusr2.watch().listen(onEvent));
    };
    controller.onCancel = () {
      debounce?.cancel();
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
      subscriptions.clear();
    };

    return controller.stream;
  }
}
