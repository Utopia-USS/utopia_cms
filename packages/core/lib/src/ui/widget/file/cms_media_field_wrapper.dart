import 'package:flutter/material.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

class CmsFileFieldWrapper extends StatelessWidget {
  final  Widget child;
  final  double size;
  final bool hasShadow ;
     final  Color? color;

  const CmsFileFieldWrapper({
    super.key,
    required this.size,
    required this.child,
    this.hasShadow = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? context.colors.disabled,
        borderRadius: context.theme.borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ].takeIf((it) => hasShadow),
      ),
      child: child,
    );
  }
}
