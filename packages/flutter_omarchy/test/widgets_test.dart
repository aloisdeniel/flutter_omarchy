import 'package:flutter_omarchy/flutter_omarchy.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] with the minimal environment needed by Omarchy widgets.
Widget harness(Widget child) {
  return OmarchyApp(
    debugShowCheckedModeBanner: false,
    theme: OmarchyThemeData(
      colors: OmarchyColorThemes.tokyoNight,
      text: const OmarchyTextStyleData.fallback(),
    ),
    home: Center(child: child),
  );
}

void main() {
  group('PanelSize', () {
    test('absolute resolves to its own size', () {
      const size = PanelSize.absolute(200);
      expect(size.resolve(1000), 200);
      expect(size.resolve(100), 100);
    });

    test('absolute addDelta adds to its own size', () {
      const size = PanelSize.absolute(200);
      expect(size.addDelta(1000, 50), const PanelSize.absolute(250));
      expect(size.addDelta(1000, -300), const PanelSize.absolute(0));
    });

    test('ratio resolves relative to the available size', () {
      const size = PanelSize.ratio(0.25);
      expect(size.resolve(1000), 250);
    });
  });

  group('OmarchyButtonStyle', () {
    test('styles have consistent equality', () {
      expect(
        const OmarchyButtonStyle.filled(AnsiColor.red),
        const OmarchyButtonStyle.filled(AnsiColor.red),
      );
      expect(
        const OmarchyButtonStyle.filled(AnsiColor.red),
        isNot(const OmarchyButtonStyle.outline(AnsiColor.red)),
      );
      expect(
        const OmarchyButtonStyle.bar(AnsiColor.red),
        const OmarchyButtonStyle.bar(AnsiColor.red),
      );
      expect(
        const OmarchyButtonStyle.bar(AnsiColor.red),
        isNot(const OmarchyButtonStyle.outline(AnsiColor.red)),
      );
    });
  });

  group('OmarchyButton', () {
    testWidgets('invokes onPressed when tapped', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        harness(
          OmarchyButton(onPressed: () => pressed++, child: const Text('Tap')),
        ),
      );
      await tester.tap(find.text('Tap'));
      expect(pressed, 1);
    });
  });

  group('OmarchyDivider', () {
    testWidgets('horizontal divider is a full-width one pixel line', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          const SizedBox(
            width: 100,
            height: 100,
            child: Center(child: OmarchyDivider.horizontal()),
          ),
        ),
      );
      final size = tester.getSize(find.byType(OmarchyDivider));
      expect(size.width, 100);
      expect(size.height, 1);
    });

    testWidgets('vertical divider is a full-height one pixel line', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          const SizedBox(
            width: 100,
            height: 100,
            child: Center(child: OmarchyDivider.vertical()),
          ),
        ),
      );
      final size = tester.getSize(find.byType(OmarchyDivider));
      expect(size.width, 1);
      expect(size.height, 100);
    });
  });

  group('OmarchyTab', () {
    testWidgets('close button invokes onClose and not onTap', (tester) async {
      var closed = 0;
      var tapped = 0;
      await tester.pumpWidget(
        harness(
          OmarchyTabs(
            children: [
              OmarchyTab.closable(
                title: const Text('tab.dart'),
                onTap: () => tapped++,
                onClose: () => closed++,
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.byIcon(OmarchyIcons.codClose));
      expect(closed, 1);
      expect(tapped, 0);
      await tester.tap(find.text('tab.dart'));
      expect(tapped, 1);
    });
  });

  group('OmarchyStatusBar', () {
    testWidgets('renders leading and trailing statuses', (tester) async {
      await tester.pumpWidget(
        harness(
          SizedBox(
            width: 600,
            child: OmarchyStatusBar(
              leading: const [OmarchyStatus(child: Text('READY'))],
              trailing: const [
                OmarchyStatus(child: Text('UTF-8')),
                OmarchyStatus(child: Text('100%')),
              ],
            ),
          ),
        ),
      );
      expect(find.text('READY'), findsOneWidget);
      expect(find.text('UTF-8'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });
  });

  group('OmarchySelect', () {
    testWidgets('highlights the selected option', (tester) async {
      await tester.pumpWidget(
        harness(
          OmarchySelect<String>(
            value: const Some('b'),
            options: const ['a', 'b', 'c'],
            onChanged: (_) {},
            builder: (context, value) => Text(value),
          ),
        ),
      );
      await tester.tap(find.text('b'));
      await tester.pumpAndSettle();

      bool isSelected(String label) {
        final context = tester.element(
          find.ancestor(
            of: find.text(label).last,
            matching: find.byType(OmarchyTile),
          ),
        );
        return Selected.of(context);
      }

      expect(isSelected('a'), isFalse);
      expect(isSelected('b'), isTrue);
      expect(isSelected('c'), isFalse);
    });

    testWidgets('selecting an option invokes onChanged', (tester) async {
      String? selected;
      await tester.pumpWidget(
        harness(
          OmarchySelect<String>(
            options: const ['a', 'b', 'c'],
            placeholder: const Text('Pick one'),
            onChanged: (v) => selected = v,
            builder: (context, value) => Text(value),
          ),
        ),
      );
      await tester.tap(find.text('Pick one'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('c'));
      await tester.pumpAndSettle();
      expect(selected, 'c');
    });
  });

  group('OmarchyRadio', () {
    testWidgets('selects a value on tap', (tester) async {
      String? selected = 'a';
      await tester.pumpWidget(
        harness(
          StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in ['a', 'b'])
                  OmarchyRadio<String>(
                    key: ValueKey(option),
                    value: option,
                    groupValue: selected,
                    onChanged: (v) => setState(() => selected = v),
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('b')));
      await tester.pump();
      expect(selected, 'b');
    });
  });

  group('OmarchySlider', () {
    testWidgets('clicking on the track updates the value', (tester) async {
      double value = 0;
      await tester.pumpWidget(
        harness(
          SizedBox(
            width: 200,
            child: StatefulBuilder(
              builder: (context, setState) => OmarchySlider(
                value: value,
                onChanged: (v) => setState(() => value = v),
              ),
            ),
          ),
        ),
      );
      await tester.tapAt(tester.getCenter(find.byType(OmarchySlider)));
      await tester.pump();
      expect(value, closeTo(0.5, 0.05));
    });

    testWidgets('snaps to divisions', (tester) async {
      double value = 0;
      await tester.pumpWidget(
        harness(
          SizedBox(
            width: 200,
            child: StatefulBuilder(
              builder: (context, setState) => OmarchySlider(
                value: value,
                divisions: 4,
                onChanged: (v) => setState(() => value = v),
              ),
            ),
          ),
        ),
      );
      final rect = tester.getRect(find.byType(OmarchySlider));
      await tester.tapAt(
        Offset(rect.left + rect.width * 0.6, rect.center.dy),
      );
      await tester.pump();
      expect(value, anyOf(0.5, 0.75));
    });
  });

  group('OmarchyDialog', () {
    testWidgets('confirm dialog completes with true on confirm', (
      tester,
    ) async {
      Future<bool?>? result;
      await tester.pumpWidget(
        harness(
          Builder(
            builder: (context) => OmarchyButton(
              child: const Text('Open'),
              onPressed: () {
                result = showOmarchyConfirmDialog(
                  context: context,
                  title: const Text('Confirm?'),
                  message: const Text('Are you sure?'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Are you sure?'), findsOneWidget);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(await result, isTrue);
      expect(find.text('Are you sure?'), findsNothing);
    });
  });

  group('OmarchyToast', () {
    testWidgets('shows and auto dismisses', (tester) async {
      await tester.pumpWidget(
        harness(
          Builder(
            builder: (context) => OmarchyButton(
              child: const Text('Notify'),
              onPressed: () {
                showOmarchyToast(
                  context: context,
                  message: const Text('Saved!'),
                  accent: AnsiColor.green,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Notify'));
      await tester.pump();
      expect(find.text('Saved!'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('Saved!'), findsNothing);
    });
  });

  group('OmarchyContextMenu', () {
    testWidgets('opens on secondary tap and selects an item', (tester) async {
      var copied = 0;
      await tester.pumpWidget(
        harness(
          OmarchyContextMenuArea(
            entries: [
              OmarchyContextMenuItem(
                label: 'Copy',
                onSelected: () => copied++,
              ),
              const OmarchyContextMenuDivider(),
              const OmarchyContextMenuItem(label: 'Nope', enabled: false),
            ],
            child: const SizedBox(
              width: 200,
              height: 100,
              child: Text('Area'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Area'), buttons: 2);
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsOneWidget);
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();
      expect(copied, 1);
      expect(find.text('Copy'), findsNothing);
    });
  });

  group('OmarchyCommandPanel', () {
    testWidgets('filters items and selects with keyboard', (tester) async {
      String? selected;
      await tester.pumpWidget(
        harness(
          OmarchyCommandPanel<String>(
            items: const ['New File', 'Open File', 'Save File'],
            onItemSelected: (item) => selected = item,
            resultBuilder: (context, item, isSelected, onTap) =>
                OmarchyTile(title: Text(item), onTap: onTap),
          ),
        ),
      );
      await tester.enterText(find.byType(OmarchyTextInput), 'open');
      await tester.pumpAndSettle();
      expect(find.text('Open File'), findsOneWidget);
      expect(find.text('Save File'), findsNothing);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(selected, 'Open File');
    });
  });
}
