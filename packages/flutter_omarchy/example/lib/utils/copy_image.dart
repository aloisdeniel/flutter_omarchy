import 'dart:typed_data';

import 'package:pasteboard/pasteboard.dart';

/// Copies PNG image bytes to the system clipboard.
Future<void> copyPngToClipboard(Uint8List pngBytes) async {
  await Pasteboard.writeImage(pngBytes);
}
