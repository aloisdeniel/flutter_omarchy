import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

/// Returns true if the current browser likely supports writing images to the clipboard.
bool isClipboardImageWriteSupported() {
  final clipboard = html.window.navigator.clipboard;
  final clipboardItemCtor = js_util.getProperty(html.window, 'ClipboardItem');
  return (html.window.isSecureContext ?? true) &&
      clipboard != null &&
      clipboardItemCtor != null;
}

/// Copies PNG bytes to the system clipboard (browser) as an image.
/// Throws [UnsupportedError] when not supported or not in a secure context.
/// Throws on any platform error from the Clipboard API.
Future<void> copyPngToClipboard(Uint8List pngBytes) async {
  if (!(html.window.isSecureContext ?? true)) {
    throw UnsupportedError(
      'Clipboard image write requires a secure context (HTTPS).',
    );
  }

  final clipboard = html.window.navigator.clipboard;
  if (clipboard == null) {
    throw UnsupportedError('Clipboard API not available.');
  }

  final clipboardItemCtor = js_util.getProperty(html.window, 'ClipboardItem');
  if (clipboardItemCtor == null) {
    throw UnsupportedError('ClipboardItem is not supported in this browser.');
  }

  final blob = html.Blob(<Object>[pngBytes], 'image/png');

  final dataMap = js_util.newObject();
  js_util.setProperty(dataMap, 'image/png', blob);

  final clipboardItem = js_util.callConstructor(clipboardItemCtor, <Object>[
    dataMap,
  ]);

  await js_util.promiseToFuture<void>(
    js_util.callMethod(clipboard, 'write', <Object>[
      <Object>[clipboardItem],
    ]),
  );
}
