import 'package:flutter/material.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';

class CmsLoader extends StatelessWidget {
  final Color? color;
  final double size;

  const CmsLoader({
    super.key,
    this.color,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    final style = context.textStyles.label;
    return Center(
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: CircularProgressIndicator(color: color ?? style.color, strokeWidth: size / 6),
        ),
      ),
    );
  }
}
