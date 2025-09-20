import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/side_panel.dart';
import 'package:flutter_omarchy/src/widgets/utils/panel_size.dart';
import 'package:flutter_omarchy/src/widgets/widgets.dart';

typedef OmarchyScaffoldLeadingMenuState = ({
  bool isHidden,
  OmarchySidePanelController hiddenController,
});

class OmarchyScaffold extends StatefulWidget {
  const OmarchyScaffold({
    super.key,
    required this.child,
    this.leadingPanel,
    this.navigationBar,
    this.status,
    this.panelInitialSize = const PanelSize.ratio(0.3),
    this.maxPanelSize = const PanelSize.absolute(400),
    this.minPanelSize = const PanelSize.absolute(200),
    this.hideLeadingMenuUnderWidth = 500.0,
  });

  static OmarchyScaffoldLeadingMenuState? leadingPanelMaybeOf(
    BuildContext context,
  ) {
    return context
        .dependOnInheritedWidgetOfExactType<_LeadingMenuStateProvider>()
        ?.state;
  }

  static OmarchyScaffoldLeadingMenuState leadingPanelOf(BuildContext context) {
    return leadingPanelMaybeOf(context)!;
  }

  final Widget child;
  final Widget? leadingPanel;
  final Widget? navigationBar;
  final Widget? status;
  final PanelSize panelInitialSize;
  final PanelSize? minPanelSize;
  final PanelSize? maxPanelSize;

  /// If null, default to a third of the scaffold's width.
  ///
  /// If 0, then always show the leading menu.
  final double hideLeadingMenuUnderWidth;

  @override
  State<OmarchyScaffold> createState() => _OmarchyScaffoldState();
}

class _OmarchyScaffoldState extends State<OmarchyScaffold> {
  final contentKey = GlobalKey();
  final menuKey = GlobalKey();
  final controller = OmarchySidePanelController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return LayoutBuilder(
      builder: (context, layout) {
        var child = widget.child;
        final isLeadingMenuHidden =
            layout.maxWidth < widget.hideLeadingMenuUnderWidth;

        if (widget.navigationBar case final bar?) {
          child = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              bar,
              Expanded(key: Key('main'), child: child),
            ],
          );
        }
        if (widget.leadingPanel case final panel?) {
          if (!isLeadingMenuHidden) {
            child = OmarchySplitPanel(
              panelInitialSize: widget.panelInitialSize,
              minPanelSize: widget.minPanelSize,
              maxPanelSize: widget.maxPanelSize,
              panel: panel,
              child: child,
            );
          } else {
            child = OmarchySidePanel(
              controller: controller,
              panel: panel,
              child: child,
            );
          }
        }

        if (widget.status case final status?) {
          child = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(key: Key('main'), child: child),
              status,
            ],
          );
        }
        return _LeadingMenuStateProvider(
          state: (isHidden: isLeadingMenuHidden, hiddenController: controller),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            color: theme.colors.background,
            child: child,
          ),
        );
      },
    );
  }
}

class _LeadingMenuStateProvider extends InheritedWidget {
  const _LeadingMenuStateProvider({required super.child, required this.state});
  final OmarchyScaffoldLeadingMenuState state;
  @override
  bool updateShouldNotify(covariant _LeadingMenuStateProvider oldWidget) {
    return oldWidget.state != state;
  }
}
