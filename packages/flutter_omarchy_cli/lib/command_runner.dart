import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flutter_omarchy_cli/commands/create/command.dart';
import 'package:mason/mason.dart' hide packageVersion;

class FlutterOmarchyCommandRunner extends CommandRunner<int> {
  FlutterOmarchyCommandRunner({
    Logger? logger,
    Map<String, String>? environment,
  }) : _logger = logger ?? Logger(),
       super(
         'flutter_omarchy',
         'A set of tools to create and maintain Omarchy apps.',
       ) {
    argParser.addFlag(
      'verbose',
      help: 'Noisy logging, including all shell commands executed.',
    );
    addCommand(CreateCommand());
  }

  final Logger _logger;

  @override
  void printUsage() => _logger.info(usage);

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final argResults = parse(args);

      if (argResults['verbose'] == true) {
        _logger.level = Level.verbose;
      }
      return await runCommand(argResults) ?? ExitCode.success.code;
    } on FormatException catch (e, stackTrace) {
      _logger
        ..err(e.message)
        ..err('$stackTrace')
        ..info('')
        ..info(usage);
      return ExitCode.usage.code;
    } on UsageException catch (e) {
      _logger
        ..err(e.message)
        ..info('')
        ..info(e.usage);
      return ExitCode.usage.code;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults.command?.name == 'completion') {
      await super.runCommand(topLevelResults);
      return ExitCode.success.code;
    }

    _logger
      ..detail('Argument information:')
      ..detail('  Top level options:');

    for (final option in topLevelResults.options) {
      if (topLevelResults.wasParsed(option)) {
        _logger.detail('  - $option: ${topLevelResults[option]}');
      }
    }

    if (topLevelResults.command != null) {
      final commandResult = topLevelResults.command!;
      _logger
        ..detail('  Command: ${commandResult.name}')
        ..detail('    Command options:');
      for (final option in commandResult.options) {
        if (commandResult.wasParsed(option)) {
          _logger.detail('    - $option: ${commandResult[option]}');
        }
      }

      if (commandResult.command != null) {
        final subCommandResult = commandResult.command!;
        _logger.detail('    Command sub command: ${subCommandResult.name}');
      }
    }

    final exitCode = await super.runCommand(topLevelResults);
    return exitCode;
  }
}
