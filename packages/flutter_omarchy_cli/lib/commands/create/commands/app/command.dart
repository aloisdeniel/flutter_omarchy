import 'package:flutter_omarchy_cli/commands/create/commands/app/omarchy_app_bundle.dart';
import 'package:flutter_omarchy_cli/commands/create/commands/subcommand.dart';
import 'package:mason/mason.dart';

class CreateApp extends CreateSubcommand {
  @override
  String get name => 'app';

  @override
  String get description => 'Generate an Omarchy application.';

  @override
  MasonBundle get bundle => omarchyAppBundle;
}
