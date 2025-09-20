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
    'linux,macos',
    '--no-pub',
    '.',
  ], workingDirectory: packageDir);

  progress.update('Updates linux confuguration...');

  // Remove the window title bar in linux native code.
  final myAppCc = File(
    join(packageDir, 'linux', 'runner', 'my_application.cc'),
  );
  final content = await myAppCc.readAsString();
  await myAppCc.writeAsString(
    content.replaceFirst('use_header_bar = TRUE', 'use_header_bar = FALSE'),
  );

  progress.complete('Completed post generation');
}
