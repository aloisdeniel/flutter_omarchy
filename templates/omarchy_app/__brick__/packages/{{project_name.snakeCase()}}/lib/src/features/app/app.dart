import 'package:{{project_name.snakeCase()}}/src/features/home/screen.dart';
import 'package:{{project_name.snakeCase()}}/src/services/services.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';

class App extends StatefulWidget {
  const App({super.key, required this.services});

  final Services services;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    widget.services.database.analytics.insert(name: 'app_launch');
  }

  @override
  Widget build(BuildContext context) {
    return ServicesProvider(
      services: widget.services,
      child: const OmarchyApp(home: HomeScreen()),
    );
  }
}

class ServicesProvider extends InheritedWidget {
  const ServicesProvider({
    super.key,
    required super.child,
    required this.services,
  });

  final Services services;

  static Services of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ServicesProvider>();
    assert(provider != null, 'No ServicesProvider found in context');
    return provider!.services;
  }

  @override
  bool updateShouldNotify(covariant ServicesProvider oldWidget) {
    return services != oldWidget.services;
  }
}
