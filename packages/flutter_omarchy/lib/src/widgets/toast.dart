import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/colors.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/icon_data.g.dart';
import 'package:flutter_omarchy/src/widgets/utils/default_foreground.dart';
import 'package:flutter_omarchy/src/widgets/utils/pointer_area.dart';

/// A handle on a toast shown with [showOmarchyToast].
///
/// Allows closing the toast before its duration has elapsed.
class OmarchyToastHandle {
  OmarchyToastHandle._(this._entry);

  final _ToastEntry _entry;

  /// Closes the toast.
  ///
  /// Does nothing if the toast is already closed.
  void close() => _entry.close();
}

/// Shows a transient notification at the bottom right of the screen.
///
/// Toasts stack when several are shown at the same time, and are dismissed
/// automatically after [duration] (or by clicking on them). Pass a null
/// [duration] to keep the toast until it is closed manually via the returned
/// handle or a click.
///
/// {@tool snippet}
/// ```dart
/// showOmarchyToast(
///   context: context,
///   message: Text('File saved'),
///   accent: AnsiColor.green,
/// );
/// ```
/// {@end-tool}
OmarchyToastHandle showOmarchyToast({
  required BuildContext context,
  required Widget message,
  AnsiColor accent = AnsiColor.white,
  Widget? icon,
  Duration? duration = const Duration(seconds: 4),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final theme = OmarchyTheme.of(context);
  final manager = _ToastManager.forOverlay(overlay);
  final entry = manager.add(
    theme: theme,
    message: message,
    accent: accent,
    icon: icon,
    duration: duration,
  );
  return OmarchyToastHandle._(entry);
}

class _ToastEntry {
  _ToastEntry({
    required this.manager,
    required this.message,
    required this.accent,
    required this.icon,
    this.duration,
  });

  final _ToastManager manager;
  final Widget message;
  final AnsiColor accent;
  final Widget? icon;
  final Duration? duration;
  Timer? timer;
  bool closed = false;

  void close() {
    if (closed) return;
    closed = true;
    timer?.cancel();
    manager.remove(this);
  }
}

/// Manages the single overlay entry that renders the stack of toasts of an
/// [OverlayState].
class _ToastManager extends ChangeNotifier {
  _ToastManager(this.overlay);

  static final Expando<_ToastManager> _managers = Expando();

  static _ToastManager forOverlay(OverlayState overlay) {
    return _managers[overlay] ??= _ToastManager(overlay);
  }

  final OverlayState overlay;
  final List<_ToastEntry> entries = [];
  OverlayEntry? _overlayEntry;
  OmarchyThemeData? _theme;

  _ToastEntry add({
    required OmarchyThemeData theme,
    required Widget message,
    required AnsiColor accent,
    required Widget? icon,
    Duration? duration,
  }) {
    _theme = theme;
    final entry = _ToastEntry(
      manager: this,
      message: message,
      accent: accent,
      icon: icon,
      duration: duration,
    );
    entries.add(entry);
    if (duration != null) {
      entry.timer = Timer(duration, entry.close);
    }
    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(builder: _buildLayer);
      overlay.insert(_overlayEntry!);
    }
    notifyListeners();
    return entry;
  }

  void remove(_ToastEntry entry) {
    entries.remove(entry);
    notifyListeners();
    if (entries.isEmpty) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  Widget _buildLayer(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: OmarchyThemeProvider(
        data: _theme!,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ListenableBuilder(
            listenable: this,
            builder: (context, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 8,
              children: [
                for (final entry in entries.reversed)
                  _Toast(key: ObjectKey(entry), entry: entry),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Toast extends StatefulWidget {
  const _Toast({super.key, required this.entry});

  final _ToastEntry entry;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> {
  var isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => isVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final normal = theme.colors.normal[widget.entry.accent];
    final bright = theme.colors.bright[widget.entry.accent];
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: isVisible ? 1 : 0,
      child: PointerArea(
        onTap: widget.entry.close,
        builder: (context, state, _) => ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colors.background,
              border: Border.all(
                color: state.isHovering ? bright : normal,
                width: 2,
              ),
            ),
            child: Container(
              color: normal.withValues(alpha: 0.15),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: DefaultForeground(
                foreground: bright,
                textStyle: theme.text.normal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    widget.entry.icon ?? const Icon(OmarchyIcons.codInfo),
                    Flexible(child: widget.entry.message),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
