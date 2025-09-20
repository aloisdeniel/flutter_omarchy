import 'dart:math' show sqrt;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';
import "utils/copy_image.dart"
    if (dart.library.html) "utils/copy_image.web.dart";
import 'package:qr/qr.dart';

class QrCodeGeneratorApp extends StatelessWidget {
  const QrCodeGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OmarchyApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final RegExp numericRegex = RegExp(r'^[0-9]+$');
  final _qrKey = GlobalKey();
  final _input = TextEditingController();
  int _typeNumber = 10;
  int _errorCorrectLevel = QrErrorCorrectLevel.M;
  Object? _error;
  AnsiColor? _color;
  List<bool> _squares = const <bool>[];

  @override
  void initState() {
    super.initState();
    _input.addListener(_generate);
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _generate() async {
    try {
      final data = _input.text;
      if (data.isEmpty) {
        setState(() {
          _error = null;
          _squares = const <bool>[];
        });
        return;
      }
      final code = QrCode(_typeNumber, _errorCorrectLevel);

      if (numericRegex.hasMatch(data)) {
        code.addNumeric(data);
      } else {
        code.addData(data);
      }
      final image = QrImage(code);

      final squares = <bool>[];

      for (var x = 0; x < code.moduleCount; x++) {
        for (var y = 0; y < code.moduleCount; y++) {
          squares.add(image.isDark(y, x));
        }
      }

      setState(() {
        _error = null;
        _squares = squares;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _squares = const <bool>[];
      });
    }
  }

  Future<void> _captureAndSave(BuildContext context) async {
    try {
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 10.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      copyPngToClipboard(pngBytes);
      await copyPngToClipboard(pngBytes);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return OmarchyScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: RepaintBoundary(
                key: _qrKey,
                child: AnimatedBuilder(
                  animation: _input,
                  builder: (context, _) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: KeyedSubtree(
                        key: ValueKey((
                          _input.text,
                          _errorCorrectLevel,
                          _typeNumber,
                          _color,
                        )),
                        child: switch (_error) {
                          null when _squares.isNotEmpty => FittedBox(
                            fit: BoxFit.contain,
                            child: CustomPaint(
                              size: Size(512, 512),
                              painter: _QrCodePainter(
                                padding: 24,
                                background: theme.colors.background,
                                foreground: switch (_color) {
                                  null => theme.colors.foreground,
                                  AnsiColor.black => theme.colors.bright.black,
                                  AnsiColor.red => theme.colors.bright.red,
                                  AnsiColor.green => theme.colors.bright.green,
                                  AnsiColor.yellow =>
                                    theme.colors.bright.yellow,
                                  AnsiColor.blue => theme.colors.bright.blue,
                                  AnsiColor.magenta =>
                                    theme.colors.bright.magenta,
                                  AnsiColor.cyan => theme.colors.bright.cyan,
                                  AnsiColor.white => theme.colors.bright.white,
                                },
                                squares: _squares,
                              ),
                            ),
                          ),
                          null => Center(
                            child: Text(
                              'Generate a QR Code',
                              style: theme.text.italic.copyWith(
                                color: theme.colors.normal.black,
                              ),
                            ),
                          ),
                          final e => Center(
                            child: Text(
                              'Error: $e',
                              style: theme.text.bold.copyWith(
                                color: theme.colors.bright.red,
                              ),
                            ),
                          ),
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          OmarchyDivider(),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: _ToolBar(
              input: _input,
              color: _color,
              errorCorrectLevel: _errorCorrectLevel,
              typeNumber: _typeNumber,
              onCopy: _squares.isNotEmpty
                  ? () => _captureAndSave(context)
                  : null,
              onErrorCorrectLevelChanged: (v) {
                _errorCorrectLevel = v;
                _generate();
              },
              onTypeNumberChanged: (v) {
                _typeNumber = v;
                _generate();
              },
              onColorChanged: (v) {
                _color = v;
                _generate();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolBar extends StatelessWidget {
  const _ToolBar({
    required this.input,
    required this.color,
    required this.onColorChanged,
    required this.typeNumber,
    required this.errorCorrectLevel,
    required this.onTypeNumberChanged,
    required this.onCopy,
    required this.onErrorCorrectLevelChanged,
  });
  final TextEditingController input;
  final AnsiColor? color;
  final ValueChanged<AnsiColor?> onColorChanged;
  final int typeNumber;
  final ValueChanged<int> onTypeNumberChanged;
  final int errorCorrectLevel;
  final ValueChanged<int> onErrorCorrectLevelChanged;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return LayoutBuilder(
      builder: (context, layout) {
        final isSmall = layout.maxWidth < 500;
        final textInput = OmarchyInputContainer(
          builder: (context, focusNode) => OmarchyTextInput(
            focusNode: focusNode,
            controller: input,
            placeholder: Text('Enter text to generate QR code'),
          ),
        );
        final popOverDirection = isSmall
            ? OmarchyPopOverDirection.upRight
            : OmarchyPopOverDirection.up;
        final options = <Widget>[
          OmarchyInputContainer(
            key: Key('color_input'),
            builder: (context, focusNode) => SizedBox(
              child: OmarchySelect<AnsiColor?>(
                direction: popOverDirection,
                options: [null, ...AnsiColor.values],
                value: Some(color),
                onChanged: onColorChanged,
                builder: (context, v) => SizedBox(
                  width: 40,
                  child: ColorBox(color: v, theme: theme),
                ),
              ),
            ),
          ),
          OmarchyInputContainer(
            key: Key('type_number_input'),
            builder: (context, focusNode) => OmarchySelect<int>(
              direction: popOverDirection,
              options: List.generate(19, (x) => x + 1),
              value: Some(typeNumber),
              onChanged: onTypeNumberChanged,
              builder: (context, v) => Align(
                alignment: Alignment.centerRight,
                child: Text(v.toString()),
              ),
            ),
          ),
          OmarchyInputContainer(
            key: Key('error_correct_level_input'),
            builder: (context, focusNode) => OmarchySelect<int>(
              direction: popOverDirection,
              options: QrErrorCorrectLevel.levels,
              value: Some(errorCorrectLevel),
              onChanged: onErrorCorrectLevelChanged,
              builder: (context, value) =>
                  Text(QrErrorCorrectLevel.getName(value)),
            ),
          ),
        ];
        final copyButton = OmarchyButton(
          style: OmarchyButtonStyle.filled(AnsiColor.green),
          onPressed: onCopy,
          child: Row(
            spacing: 4,
            children: [Text('Copy'), Icon(OmarchyIcons.codCopy)],
          ),
        );
        if (isSmall) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              textInput,
              Row(children: [...options, Spacer(), copyButton]),
            ],
          );
        }
        return Row(
          spacing: 8,
          children: [
            Expanded(key: Key('text_input'), child: textInput),
            ...options,
            copyButton,
          ],
        );
      },
    );
  }
}

class ColorBox extends StatelessWidget {
  const ColorBox({super.key, required AnsiColor? color, required this.theme})
    : _color = color;

  final AnsiColor? _color;
  final OmarchyThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _color == null
          ? theme.colors.foreground
          : theme.colors.bright[_color!],
      height: 16,
    );
  }
}

class _QrCodePainter extends CustomPainter {
  _QrCodePainter({
    required this.background,
    required this.foreground,
    required this.squares,
    required this.padding,
  });
  final Color background;
  final Color foreground;
  final double padding;
  final List<bool> squares;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    final effectiveWidth = size.width - padding * 2;
    final squareSize = effectiveWidth / (sqrt(squares.length)).ceil();
    paint.color = background;
    canvas.drawRect(Offset.zero & size, paint);
    paint.color = foreground;
    for (var i = 0; i < squares.length; i++) {
      if (squares[i]) {
        final x = (i % sqrt(squares.length).ceil()) * squareSize;
        final y = (i ~/ sqrt(squares.length).ceil()) * squareSize;
        canvas.drawRect(
          Rect.fromLTWH(padding + x, padding + y, squareSize, squareSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
