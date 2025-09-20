// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:args/args.dart';
import 'package:example/calculator/app.dart';
import 'package:example/counter.dart';
import 'package:example/file_explorer.dart';
import 'package:example/gallery.dart';
import 'package:example/markdown_editor.dart';
import 'package:example/pomodoro.dart';
import 'package:example/qr_code_generator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';
import 'package:flutter_omarchy/preview.dart';

enum App {
  gallery,
  counter,
  qr_code_generator,
  calculator,
  file_explorer,
  markdown_editor,
  pomodoro;

  Widget build() {
    return switch (this) {
      App.gallery => const GalleryApp(),
      App.counter => const CounterApp(),
      App.qr_code_generator => const QrCodeGeneratorApp(),
      App.calculator => const CalculatorApp(),
      App.file_explorer => const FileExplorerApp(),
      App.markdown_editor => const MarkdownEditorApp(),
      App.pomodoro => const PomodoroApp(),
    };
  }
}

Future<void> main(List<String> args) async {
  final effectiveArgs = [...args];

  // For web we pass query parameters as command line arguments
  if (kIsWeb) {
    for (final entry in Uri.base.queryParameters.entries) {
      effectiveArgs.add('');
      effectiveArgs.add(entry.value);
    }
  }

  final parser = ArgParser();
  parser.addFlag('preview', defaultsTo: kIsWeb || !Platform.isLinux);
  parser.addOption(
    'app',
    defaultsTo: App.gallery.name,
    allowed: App.values.map((x) => x.name),
  );
  final result = parser.parse(effectiveArgs);

  // Initial app
  final appArg = result['app'];
  final app = App.values.firstWhere(
    (x) => x.name == appArg,
    orElse: () => App.gallery,
  );

  await Omarchy.initialize();
  if (result['preview']) {
    return runApp(
      OmarchyPreview(
        wallpapers: {
          for (final entry in OmarchyColorThemes.all.entries)
            entry.key: AssetImage('assets/${entry.key}.jpg'),
        },
        children: App.values.map((x) => x.build()).toList(),
      ),
    );
  }
  runApp(app.build());
}
