import 'package:flutter/material.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';

class CmsGradientBackground extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final Clip? clipBehavior;
  final bool isEnabled;
  final List<Color>? colors;

  const CmsGradientBackground({
    super.key,
    required this.child,
    this.borderRadius,
    this.clipBehavior,
    this.isEnabled = true,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = colors ?? [context.colors.primary, context.colors.accent];
    return AnimatedContainer(
      height: double.infinity,
      width: double.infinity,
      clipBehavior: clipBehavior ?? Clip.none,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: isEnabled ? gradient : [context.colors.disabled, context.colors.disabled.withOpacity(0.95)],
        ),
      ),
      duration: const Duration(milliseconds: 400),
      child: child,
    );
  }
}
