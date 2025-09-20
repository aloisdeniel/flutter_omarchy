import 'dart:io';

import 'package:recase/recase.dart';
import 'package:remove_diacritic/remove_diacritic.dart';

final file = File('../lib/src/widgets/icon_data.g.dart');

void main() {
  final result = StringBuffer();
  result.writeln('import \'package:flutter/widgets.dart\' show IconData;');
  result.writeln('abstract class OmarchyIcons {');
  result.writeln('  static const _package = \'flutter_omarchy\';');
  result.writeln('  static const _font = \'CaskaydiaMono Nerd Font Mono\';');

  final css = File('nerd-fonts-generated.css').readAsStringSync();

  String toVarName(String name) {
    var result = ReCase(
      removeDiacritics(name),
    ).camelCase.replaceAll(RegExp(r'[^\w\s]+'), '');
    if (result.startsWith(RegExp(r'[0-9]'))) {
      result = 'v$result';
    }
    return result;
  }

  final regex = RegExp(
    r'\.nf-([a-z0-9A-Z-_]+):before\s\{\s*content\s*:\s*\"\\([a-z0-9A-Z]+)\"',
  );
  for (var match in regex.allMatches(css)) {
    final name = toVarName(match.group(1)!);
    result.writeln(
      '  static const IconData $name = IconData(0x${match.group(2)}, fontFamily: _font, fontPackage: _package,);',
    );
  }

  result.writeln('  static List<(String,IconData)> get values => [');
  for (var match in regex.allMatches(css)) {
    final name = toVarName(match.group(1)!);
    result.writeln('    (\'$name\', $name),');
  }
  result.writeln('  ];');
  result.writeln('}');

  file.writeAsStringSync(result.toString());

  Process.run('dart', ['format', file.path]);
}
