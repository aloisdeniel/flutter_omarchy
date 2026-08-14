import 'dart:io';

import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

/// Type definition for [Process.run].
typedef RunProcess =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
      bool runInShell,
    });

Future<void> run(
  HookContext context, {
  @visibleForTesting RunProcess runProcess = Process.run,
}) async {
  final projectName = context.vars['project_name'] as String;
  final packageDir = join(Directory.current.path, 'packages/$projectName');

  final progress = context.logger.progress('Getting Dart dependencies...');

  // We have to `pub get` the generated project to ensure that the analysis
  // is able to fix the imports with the correct analysis options.
  await runProcess('dart', ['pub', 'get'], workingDirectory: packageDir);

  progress.update('Running build runner...');

  await runProcess('dart', [
    'run',
    'build_runner',
    'build',
  ], workingDirectory: packageDir);

  progress.update('Adds linux desktop support...');

  // Creates the linux folder for desktop support.
  await runProcess('flutter', [
    'create',
    '--platforms',
    'linux,macos,web',
    '--no-pub',
    '.',
  ], workingDirectory: packageDir);

  progress.update('Updates linux confuguration...');

  // Remove the window title bar in linux native code.
  final myAppCc = File(
    join(packageDir, 'linux', 'runner', 'my_application.cc'),
  );
  var content = await myAppCc.readAsString();
  content = content.replaceFirst(
    'use_header_bar = TRUE',
    'use_header_bar = FALSE',
  );

  // Recent Flutter templates only show the window once Flutter has rendered
  // its first frame, which avoids a black window at startup. Older templates
  // show the window immediately, so patch them to use the same strategy.
  if (!content.contains('first-frame')) {
    content = content
        .replaceFirst(
          'static void my_application_activate(GApplication* application) {',
          '// Called when the first Flutter frame is received: only show the\n'
              '// window at this point to avoid a black window at startup.\n'
              'static void first_frame_cb(MyApplication* self, FlView* view) {\n'
              '  gtk_widget_show(gtk_widget_get_toplevel(GTK_WIDGET(view)));\n'
              '}\n'
              '\n'
              'static void my_application_activate(GApplication* application) {',
        )
        .replaceFirst(
          RegExp(
            r'gtk_window_set_default_size\(window, (\d+), (\d+)\);\s*\n\s*gtk_widget_show\(GTK_WIDGET\(window\)\);',
          ),
          'gtk_window_set_default_size(window, 1280, 720);',
        )
        .replaceFirst(
          'fl_register_plugins(FL_PLUGIN_REGISTRY(view));',
          'g_signal_connect_swapped(view, "first-frame",\n'
              '                           G_CALLBACK(first_frame_cb), self);\n'
              '  gtk_widget_realize(GTK_WIDGET(view));\n'
              '\n'
              '  fl_register_plugins(FL_PLUGIN_REGISTRY(view));',
        );
  }
  await myAppCc.writeAsString(content);

  progress.complete('Completed post generation');
}
