import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';

class OmarchyDivider extends StatelessWidget {
  const OmarchyDivider({super.key, this.direction});
  const OmarchyDivider.horizontal({super.key}) : direction = Axis.horizontal;
  const OmarchyDivider.vertical({super.key}) : direction = Axis.vertical;
  final Axis? direction;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final direction = this.direction ?? Axis.vertical;
    return Container(
      width: switch (direction) {
        Axis.vertical => double.infinity,
        Axis.horizontal => 1.0,
      },
      height: switch (direction) {
        Axis.horizontal => double.infinity,
        Axis.vertical => 1.0,
      },
      color: theme.colors.normal.black,
    );
  }
}
