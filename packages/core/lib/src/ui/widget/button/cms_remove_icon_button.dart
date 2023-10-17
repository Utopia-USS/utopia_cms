import 'package:flutter/material.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';

class CmsRemoveIconButton extends StatelessWidget {
  final void Function() onPressed;

  const CmsRemoveIconButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Icon(
          Icons.clear,
          color: colors.text,
          size: 18,
        ),
      ),
    );
  }
}
