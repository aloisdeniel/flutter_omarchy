import 'package:yaml/yaml.dart';

part 'default.dart';

class Config {
  const Config({required this.demo});

  final bool demo;

  factory Config.fromYaml(String yaml) {
    final map = loadYaml(yaml);
    if (map is YamlMap) {
      return Config(demo: map['demo'] as bool);
    } else {
      throw ArgumentError.value(yaml, 'yaml', 'Invalid YAML format');
    }
  }
}
