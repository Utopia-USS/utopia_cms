import 'package:flutter/material.dart';
import 'package:utopia_arch/utopia_arch.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';

class CmsHeader extends StatelessWidget {
  final String text;
  final bool navigateBack;

  const CmsHeader({
    super.key,
    required this.text,
    this.navigateBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (navigateBack) _buildNavigateBack(context),
        Text(
          text,
          style: context.textStyles.header,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildNavigateBack(BuildContext context) {
    final style = context.textStyles.title;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.navigator.pop(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(Icons.arrow_back, color: style.color),
              const SizedBox(width: 4),
              //todo
              Text("Back", style: style),
            ],
          ),
        ),
      ),
    );
  }
}
