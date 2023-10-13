import 'package:flutter/material.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_utils/utopia_utils.dart';

class CmsFileFieldWrapper extends StatelessWidget {
  final Widget child;
  final double size;
  final bool hasShadow;
  final void Function()? onRemovePressed;
  final Color? color;

  const CmsFileFieldWrapper({
    super.key,
    required this.size,
    required this.child,
    this.onRemovePressed,
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
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          child,
          if (onRemovePressed != null) _buildRemoveIcon(context),
        ],
      ),
    );
  }

  Widget _buildRemoveIcon(BuildContext context) {
    return Positioned(
      top: -8,
      right: -8,
      child: GestureDetector(
        onTap: onRemovePressed,
        child: Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            color: context.colors.error,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: context.colors.text.withOpacity(0.35),
                offset: const Offset(3, 3), //(x,y)
                blurRadius: 14,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.close,
              size: 14,
              color: context.colors.canvas ,
            ),
          ),
        ),
      ),
    );
  }
}
