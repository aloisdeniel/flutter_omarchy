import 'package:flutter_omarchy/flutter_omarchy.dart';

class HistoryPane extends StatelessWidget {
  const HistoryPane({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Center(
        child: Text(
          'No history yet',
          style: theme.text.bold.copyWith(
            fontSize: 18,
            color: theme.colors.bright.black,
          ),
        ),
      ),
    );
  }
}
