import 'package:flutter/material.dart';
import 'package:flutter_omarchy/preview.dart';
import 'package:app/src/services/services.dart';
import 'package:app/src/features/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await Services.fromPlatform();
  final initialConfig = await services.config.load();
  final app = App(services: services);
  runApp(initialConfig.demo ? OmarchyPreview(children: [app]) : app);
}
