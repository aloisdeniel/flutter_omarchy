import 'package:flutter/material.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

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
  late Widget selected = sections.last.$2;

  List<(String, Widget)> sections = [
    ('Theme', const ThemePage()),
    ('Widgets', const WidgetsPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return OmarchyScaffold(
      navigationBar: Builder(
        builder: (context) {
          final sidePanel = OmarchyScaffold.leadingPanelOf(context);
          return OmarchyNavigationBar(
            title: Text('Omarchy Gallery'),
            leading: [
              if (sidePanel.isHidden)
                OmarchyButton(
                  child: Icon(OmarchyIcons.codMenu),
                  onPressed: () {
                    sidePanel.hiddenController.isVisible = true;
                  },
                ),
            ],
          );
        },
      ),
      leadingPanel: Menu(
        selected: selected,
        sections: sections,
        onSectionSelected: (value) {
          setState(() {
            selected = value;
          });
        },
      ),
      child: selected,
    );
  }
}

class Menu extends StatelessWidget {
  const Menu({
    super.key,
    required this.selected,
    required this.sections,
    required this.onSectionSelected,
  });

  final Widget selected;
  final List<(String, Widget)> sections;
  final ValueChanged<Widget> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    final sidePanel = OmarchyScaffold.leadingPanelOf(context);
    return SizedBox(
      width: 200,
      child: ListView(
        children: [
          for (var item in sections)
            Selected(
              isSelected: item.$2.runtimeType == selected.runtimeType,
              child: OmarchyTile(
                onTap: () {
                  onSectionSelected(item.$2);
                  if (sidePanel.isHidden) {
                    sidePanel.hiddenController.isVisible = false;
                  }
                },
                title: Text(item.$1),
              ),
            ),
        ],
      ),
    );
  }
}

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers:
          [
                Section(title: 'Colors', children: [Colors()]),
                Section(title: 'Text', children: [TextStyles()]),
              ]
              .asMap()
              .entries
              .expand(
                (x) => [
                  if (x.key > 0) SliverToBoxAdapter(child: OmarchyDivider()),
                  x.value,
                ],
              )
              .toList(),
    );
  }
}

class TextStyles extends StatelessWidget {
  const TextStyles({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final base = [
      ('normal', theme.text.normal),
      ('bold', theme.text.bold),
      ('italic', theme.text.italic),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        for (var (name, style) in base)
          OmarchyTooltip(
            richMessage: TextSpan(
              children: [
                TextSpan(text: name),
                TextSpan(text: ' '),
                TextSpan(
                  text: style.fontFamily,
                  style: TextStyle(color: theme.colors.bright.black),
                ),
                TextSpan(text: ' '),
                TextSpan(
                  text: '${style.fontSize}pt',
                  style: TextStyle(color: theme.colors.bright.black),
                ),
              ],
            ),
            child: Text(name, style: style),
          ),
      ],
    );
  }
}

class Colors extends StatelessWidget {
  const Colors({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = OmarchyTheme.of(context).colors;
    final base = [
      ('background', colors.background),
      ('foreground', colors.foreground),
      ('border', colors.border),
      ('selectedText', colors.selectedText),
    ];
    final normal = [
      ('normal.black', colors.normal.black),
      ('normal.white', colors.normal.white),
      ('normal.red', colors.normal.red),
      ('normal.green', colors.normal.green),
      ('normal.blue', colors.normal.blue),
      ('normal.cyan', colors.normal.cyan),
      ('normal.magenta', colors.normal.magenta),
      ('normal.yellow', colors.normal.yellow),
    ];
    final bright = [
      ('bright.black', colors.bright.black),
      ('bright.white', colors.bright.white),
      ('bright.red', colors.bright.red),
      ('bright.green', colors.bright.green),
      ('bright.blue', colors.bright.blue),
      ('bright.cyan', colors.bright.cyan),
      ('bright.magenta', colors.bright.magenta),
      ('bright.yellow', colors.bright.yellow),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        for (var group in [base, normal, bright])
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var (name, color) in group)
                OmarchyTooltip(
                  richMessage: TextSpan(
                    children: [
                      TextSpan(text: name),
                      TextSpan(text: ' '),
                      TextSpan(
                        text:
                            '#${color.value.toRadixString(16).padLeft(6, '0')}',
                        style: TextStyle(color: colors.bright.black),
                      ),
                    ],
                  ),
                  child: Container(width: 20, height: 20, color: color),
                ),
            ],
          ),
      ],
    );
  }
}

class Section extends StatelessWidget {
  const Section({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverList.list(
        children: [Text(title), const SizedBox(height: 12), ...children],
      ),
    );
  }
}

class WidgetsPage extends StatelessWidget {
  const WidgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return CustomScrollView(
      slivers:
          [
                Section(
                  title: 'Logo',
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: OmarchyLogo.icon(width: 120),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.topLeft,
                      child: OmarchyLogo(width: 200),
                    ),
                  ],
                ),
                Section(
                  title: 'Icon',
                  children: [
                    SizedBox(
                      height: 24,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final icon in OmarchyIcons.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: OmarchyTooltip(
                                message: icon.$1,
                                child: Icon(icon.$2, size: 24),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                Section(
                  title: 'Button',
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (var style = 0; style < 2; style++)
                          for (var child = 0; child < 2; child++)
                            for (var color in AnsiColor.values)
                              OmarchyButton(
                                style: switch (style) {
                                  1 => OmarchyButtonStyle.filled(color),
                                  _ => OmarchyButtonStyle.outline(color),
                                },
                                child: switch (child) {
                                  1 => Text('Click me!'),
                                  _ => Icon(OmarchyIcons.codSettings),
                                },
                                onPressed: () {},
                              ),
                      ],
                    ),
                  ],
                ),
                Section(
                  title: 'Checkbox',
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OmarchyCheckbox(),
                        for (final state in CheckboxState.values)
                          for (final accent in AnsiColor.values)
                            OmarchyCheckbox(accent: accent, state: state),
                      ],
                    ),
                  ],
                ),
                Section(
                  title: 'ProgressBar',
                  children: [
                    Column(
                      spacing: 14,
                      children: [
                        OmarchyProgressBar(progress: 0),
                        for (final progress in [0.2, 0.6, 1.0]) ...[
                          OmarchyProgressBar(progress: progress),
                          OmarchyProgressBar(
                            accent: AnsiColor.green,
                            progress: progress,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                Section(
                  title: 'TextInput',
                  children: [
                    OmarchyTextInput(placeholder: Text('Enter text here')),
                    OmarchyTextInput(
                      maxLines: null,
                      placeholder: Text('Enter multiline text here'),
                    ),
                  ],
                ),
                Section(
                  title: 'InputContainer',
                  children: [
                    OmarchyInputContainer(
                      builder: (context, node) => OmarchyTextInput(
                        focusNode: node,
                        placeholder: Text('Enter text here'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    OmarchyInputContainer(
                      builder: (context, node) => OmarchyTextInput(
                        focusNode: node,
                        maxLines: null,
                        placeholder: Text('Enter multiline text here'),
                      ),
                    ),
                  ],
                ),
                Section(
                  title: 'Loader',
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OmarchyLoader(),
                        for (final accent in AnsiColor.values)
                          OmarchyLoader(accent: accent),
                      ],
                    ),
                  ],
                ),
                Section(
                  title: 'NavigationBar',
                  children: [
                    OmarchyNavigationBar(
                      title: Text('Example'),
                      trailing: [
                        OmarchyButton(
                          child: Icon(OmarchyIcons.codAdd),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
                Section(
                  title: 'Tile',
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colors.normal.black),
                      ),
                      child: OmarchyTile(title: Text('Example')),
                    ),
                  ],
                ),
                Section(
                  title: 'Scaffold',
                  children: [
                    Container(
                      width: 400,
                      height: 320,
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colors.normal.black),
                      ),
                      child: OmarchyScaffold(
                        leadingPanel: Center(child: Text('Leading Menu')),
                        status: OmarchyStatusBar(
                          leading: [OmarchyStatus(child: Text('Status'))],
                        ),
                        child: Center(child: Text('Content')),
                      ),
                    ),
                  ],
                ),
                Section(
                  title: 'SplitPanel',
                  children: [
                    Container(
                      width: 400,
                      height: 320,
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colors.normal.black),
                      ),
                      child: OmarchySplitPanel(
                        panel: Center(child: Text('Points panel (200)')),
                        child: Center(child: Text('Child')),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: 400,
                      height: 320,
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colors.normal.black),
                      ),
                      child: OmarchySplitPanel(
                        panelInitialSize: PanelSize.ratio(0.5),
                        panel: Center(child: Text('Ratio panel (0.5)')),
                        child: Center(child: Text('Child')),
                      ),
                    ),
                  ],
                ),
                Section(
                  title: 'Select',
                  children: [
                    OmarchySelect<String>(
                      value: Some('Option 2'),
                      options: [for (var i = 0; i < 20; i++) 'Option $i'],
                      onChanged: (v) {},
                      builder: (context, v) => Text(v),
                    ),
                  ],
                ),
                Section(
                  title: 'PopOver',
                  children: [
                    OmarchyPopOver(
                      popOverBuilder: (context, size, hide) {
                        return OmarchyPopOverContainer(
                          child: SizedBox(
                            width: size?.width ?? 200.0,
                            height: 200,
                            child: Center(child: Text('Hello')),
                          ),
                        );
                      },
                      builder: (context, show) =>
                          OmarchyButton(onPressed: show, child: Text('Open')),
                    ),
                  ],
                ),
                Section(
                  title: 'Tabs',
                  children: [
                    OmarchyTabs(
                      children: [
                        OmarchyTab.closable(
                          title: Text('first.dart'),
                          onTap: () {},
                          onClose: () {},
                        ),
                        OmarchyTab.closable(
                          icon: Icon(Icons.file_copy),
                          title: Text('example.dart'),
                          onTap: () {},
                          onClose: () {},
                          isActive: true,
                        ),
                        for (var i = 0; i < 25; i++)
                          OmarchyTab.closable(
                            title: Text('example_$i.dart'),
                            onTap: () {},
                            onClose: () {},
                          ),
                      ],
                    ),
                  ],
                ),
                Section(
                  title: 'Tooltip',
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: OmarchyTooltip(
                        richMessage: TextSpan(
                          children: [
                            TextSpan(text: 'A message for '),
                            TextSpan(
                              text: 'you',
                              style: theme.text.italic.copyWith(
                                color: theme.colors.bright.red,
                              ),
                            ),
                          ],
                        ),
                        child: Text('Hover me!'),
                      ),
                    ),
                  ],
                ),
                Section(
                  title: 'StatusBar',
                  children: [
                    OmarchyStatusBar(
                      leading: [
                        for (var accent in AnsiColor.values)
                          OmarchyStatus(
                            accent: accent,
                            onTap: () {},
                            child: Text(accent.name.toUpperCase()),
                          ),
                      ],
                    ),
                  ],
                ),
              ]
              .asMap()
              .entries
              .expand(
                (x) => [
                  if (x.key > 0) SliverToBoxAdapter(child: OmarchyDivider()),
                  x.value,
                ],
              )
              .toList(),
    );
  }
}
