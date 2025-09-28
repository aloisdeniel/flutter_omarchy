import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/utils/panel_size.dart';
import 'package:flutter_omarchy/src/widgets/widgets.dart';

/// Represents the state of the leading panel in an [OmarchyScaffold].
typedef OmarchyScaffoldLeadingMenuState = ({
  /// Whether the leading panel is currently hidden.
  bool isHidden,
  /// Controller for managing the hidden state of the panel.
  OmarchySidePanelController hiddenController,
});

/// A scaffold widget that provides a structured layout for desktop applications.
///
/// This scaffold includes support for a leading side panel, navigation bar,
/// status bar, and main content area. The leading panel can automatically
/// hide under certain width constraints for responsive design.
///
/// {@tool snippet}
/// ```dart
/// OmarchyScaffold(
///   leadingPanel: NavigationPanel(),
///   navigationBar: TopNavigationBar(),
///   status: StatusBar(),
///   child: MainContent(),
/// )
/// ```
/// {@end-tool}
class OmarchyScaffold extends StatefulWidget {
  /// Creates an Omarchy scaffold with the specified layout components.
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

  /// Returns the leading panel state from the closest [OmarchyScaffold] ancestor,
  /// or null if no such ancestor exists.
  static OmarchyScaffoldLeadingMenuState? leadingPanelMaybeOf(
    BuildContext context,
  ) {
    return context
        .dependOnInheritedWidgetOfExactType<_LeadingMenuStateProvider>()
        ?.state;
  }

  /// Returns the leading panel state from the closest [OmarchyScaffold] ancestor.
  ///
  /// Throws if no [OmarchyScaffold] is found in the widget tree.
  static OmarchyScaffoldLeadingMenuState leadingPanelOf(BuildContext context) {
    return leadingPanelMaybeOf(context)!;
  }

  /// The main content widget displayed in the scaffold.
  final Widget child;
  
  /// An optional side panel displayed on the left side of the scaffold.
  final Widget? leadingPanel;
  
  /// An optional navigation bar displayed at the top of the scaffold.
  final Widget? navigationBar;
  
  /// An optional status bar displayed at the bottom of the scaffold.
  final Widget? status;
  
  /// The initial size of the leading panel.
  final PanelSize panelInitialSize;
  
  /// The minimum size the leading panel can be resized to.
  final PanelSize? minPanelSize;
  
  /// The maximum size the leading panel can be resized to.
  final PanelSize? maxPanelSize;

  /// The width threshold below which the leading panel is automatically hidden.
  ///
  /// If 0, the leading panel is always shown regardless of screen width.
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
