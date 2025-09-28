import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_omarchy/src/config/alacritty.dart';
import 'package:flutter_omarchy/src/config/walker.dart';

/// Configuration data for the Omarchy theming system.
///
/// This class aggregates configuration from various sources like Alacritty
/// terminal and Walker application launcher to provide a unified theming
/// experience across desktop applications.
class OmarchyConfigData {
  /// Creates configuration data with the specified [alacritty] and [walker] configs.
  const OmarchyConfigData({required this.alacritty, required this.walker});

  /// Configuration data loaded from Alacritty terminal settings.
  ///
  /// This contains color schemes, fonts, and other terminal-specific settings
  /// that can be used to theme UI components. May be null on non-Linux
  /// platforms or when Alacritty is not available.
  final AlacrittyConfig? alacritty;

  /// Configuration data loaded from Walker application launcher settings.
  ///
  /// May be null on non-Linux platforms or when Walker is not available.
  final WalkerConfig? walker;

  /// Reads configuration data from the file system.
  ///
  /// This method attempts to load configuration from Alacritty and Walker
  /// configuration files. On non-Linux platforms or web, it returns a
  /// configuration with null values.
  ///
  /// Returns a [OmarchyConfigData] instance with loaded configuration data
  /// or null values if configuration files are not available.
  static OmarchyConfigData read() {
    if (kIsWeb || !Platform.isLinux) {
      return OmarchyConfigData(alacritty: null, walker: null);
    }
    return OmarchyConfigData(
      alacritty: AlacrittyConfig.read(),
      walker: WalkerConfig.read(),
    );
  }

  /// Watch for config changes and yield updated config data.
  ///
  /// This only works on Linux and is based on receiving the SIGUSR2 signal.
  static Stream<OmarchyConfigData> watch() async* {
    if (kIsWeb || !Platform.isLinux) {
      return;
    }

    // Watch for SIGUSR2 to reload config
    await for (final _ in ProcessSignal.sigusr2.watch()) {
      yield read();
    }
  }
}
