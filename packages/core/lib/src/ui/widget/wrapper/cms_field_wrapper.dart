import 'package:flutter/material.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class CmsFieldWrapper extends HookWidget {
  final Widget child;
  final bool includePadding;

  const CmsFieldWrapper({super.key, required this.child, this.includePadding = true});

  @override
  Widget build(BuildContext context) {
    final fieldTheme = context.fieldDecoration;
    final themeValues = context.theme;

    return Container(
      decoration: fieldTheme,
      padding: includePadding ? const EdgeInsets.symmetric(vertical: 4.0) : EdgeInsets.zero,
      child: Padding(
        padding: themeValues.fieldContentPadding,
        child: child,
      ),
    );
  }
}
