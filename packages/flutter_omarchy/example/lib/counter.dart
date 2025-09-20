import 'package:flutter_omarchy/flutter_omarchy.dart';

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OmarchyApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OmarchyScaffold(
      navigationBar: OmarchyNavigationBar(title: Text('Counter')),
      child: Center(
        child: Column(
          spacing: 24,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                key: ValueKey(_counter),
                '$_counter',
                style: TextStyle(fontSize: 92),
              ),
            ),
            OmarchyButton(
              onPressed: _incrementCounter,
              child: const Icon(OmarchyIcons.codAdd, size: 42),
            ),
          ],
        ),
      ),
    );
  }
}
