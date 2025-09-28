import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_omarchy/src/config/alacritty.dart';
import 'package:flutter_omarchy/src/config/walker.dart';

class OmarchyConfigData {
  const OmarchyConfigData({required this.alacritty, required this.walker});

  final AlacrittyConfig? alacritty;
  final WalkerConfig? walker;

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
