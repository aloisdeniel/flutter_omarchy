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
    var vars = {
      for (var entry in bundle.vars.entries) entry.key: argResults?[entry.key],
    };
    final projectName = argResults?['project_name'];
    final generator = await MasonGenerator.fromBundle(bundle);
    final directory = Directory(projectName);
    final target = DirectoryGeneratorTarget(directory);
    await generator.hooks.preGen(vars: vars, onVarsChanged: (v) => vars = v);
    await generator.generate(target, vars: vars);
    await generator.hooks.postGen(
      vars: vars,
      onVarsChanged: (v) => vars = v,
      workingDirectory: projectName,
    );
    return ExitCode.success.code;
  }
}
