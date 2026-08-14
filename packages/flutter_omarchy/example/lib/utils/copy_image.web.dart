import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Returns true if the current browser likely supports writing images to the clipboard.
bool isClipboardImageWriteSupported() {
  return web.window.isSecureContext && globalContext.has('ClipboardItem');
}

/// Copies PNG bytes to the system clipboard (browser) as an image.
/// Throws [UnsupportedError] when not supported or not in a secure context.
/// Throws on any platform error from the Clipboard API.
Future<void> copyPngToClipboard(Uint8List pngBytes) async {
  if (!web.window.isSecureContext) {
    throw UnsupportedError(
      'Clipboard image write requires a secure context (HTTPS).',
    );
  }

  if (!globalContext.has('ClipboardItem')) {
    throw UnsupportedError('ClipboardItem is not supported in this browser.');
  }

  final blob = web.Blob(
    <JSAny>[pngBytes.toJS].toJS,
    web.BlobPropertyBag(type: 'image/png'),
  );

  final dataMap = JSObject()..setProperty('image/png'.toJS, blob);
  final clipboardItem = web.ClipboardItem(dataMap);

  await web.window.navigator.clipboard.write([clipboardItem].toJS).toDart;
}
