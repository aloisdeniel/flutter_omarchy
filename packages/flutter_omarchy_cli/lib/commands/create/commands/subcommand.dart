import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';

abstract class CreateSubcommand extends Command<int> {
  MasonBundle get bundle;

  CreateSubcommand() {
    for (var entry in bundle.vars.entries) {
      argParser.addOption(
        entry.key,
        help: entry.value.description,
        mandatory: true,
      );
    }
  }

  @override
  FutureOr<int>? run() async {
    final projectName = argResults?['project_name'];
    final generator = await MasonGenerator.fromBundle(bundle);
    final target = DirectoryGeneratorTarget(Directory(projectName));
    await generator.generate(
      target,
      vars: {
        for (var entry in bundle.vars.entries)
          entry.key: argResults?[entry.key],
      },
    );
    return ExitCode.success.code;
  }
}
