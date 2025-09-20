import 'package:{{project_name.snakeCase()}}/src/features/app/app.dart';
import 'package:{{project_name.snakeCase()}}/src/features/home/state/notifier.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeNotifier? notifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = ServicesProvider.of(context).database;
    if (notifier?.db != db) {
      notifier = HomeNotifier(db: db)..refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return OmarchyScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          Text.rich(
            style: theme.text.normal.copyWith(fontSize: 24),
            TextSpan(
              children: [
                TextSpan(text: 'Hello '),
                TextSpan(
                  text: 'Omarchy',
                  style: theme.text.bold.copyWith(
                    color: theme.colors.bright.green,
                    fontSize: 24,
                  ),
                ),
                TextSpan(text: '!'),
              ],
            ),
          ),
          if (notifier case final notifier?)
            AnimatedBuilder(
              animation: notifier,
              builder: (context, _) {
                return Text.rich(
                  style: theme.text.italic,
                  TextSpan(
                    children: [
                      TextSpan(text: 'You launched this app '),
                      TextSpan(
                        text: notifier.appLaunchCount.toString(),
                        style: TextStyle(color: theme.colors.bright.blue),
                      ),
                      TextSpan(text: ' times!'),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
