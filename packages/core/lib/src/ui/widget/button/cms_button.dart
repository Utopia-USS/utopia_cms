import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:utopia_cms/src/ui/widget/layout/cms_gradient_background.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';

class CmsButton extends StatelessWidget {
  final Widget child;
  final void Function() onTap;
  final bool isEnabled;
  final bool loading;
  final bool dense;
  final double maxWidth;
  final List<Color>? colors;

  const CmsButton({
    super.key,
    required this.child,
    required this.onTap,
    this.isEnabled = true,
    this.loading = false,
    this.dense = false,
    this.maxWidth = 300,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: dense ? 44 : 60,
          maxHeight: dense ? 44 : 60,
          minWidth: dense ? 44 : 60,
          maxWidth: maxWidth,
        ),
        child: CmsGradientBackground(
          colors: colors,
          clipBehavior: Clip.antiAlias,
          borderRadius: context.theme.borderRadius,
          isEnabled: isEnabled,
          child: Center(
            heightFactor: 1,
            child: _buildTitle(context),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final style = context.textStyles.button;
    if (loading) {
      return SpinKitThreeBounce(color: style.color, size: 20);
    } else {
      return IconTheme.merge(
        data: IconThemeData(color: style.color),
        child: DefaultTextStyle(
          style: style,
          child: child,
        ),
      );
    }
  }
}
