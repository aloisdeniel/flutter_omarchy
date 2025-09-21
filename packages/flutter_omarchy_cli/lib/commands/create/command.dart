import 'package:args/command_runner.dart';
import 'package:flutter_omarchy_cli/commands/create/commands/app/command.dart';

class CreateCommand extends Command<int> {
  CreateCommand() {
    addSubcommand(CreateApp());
  }

  @override
  String get summary => '$invocation\n$description';

  @override
  String get description => 'Creates a new omarchy app from a template.';

  @override
  String get name => 'create';

  @override
  String get invocation => 'flutter_omarchy create [arguments]';
}
