import 'package:flutter/material.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:utopia_cms/src/ui/cms_widget/cms_widget_item.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

class CmsMenuTile extends StatelessWidget {
  final CmsWidgetItem item;
  final bool isExpanded, isSelected;
  final void Function() onPressed;

  const CmsMenuTile({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = context.textStyles.button;
    return InkWell(
      borderRadius: context.theme.borderRadius,
      onTap: onPressed,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(width: 3, color: isSelected ? Colors.white : Colors.transparent),
                right: const BorderSide(width: 3, color: Colors.transparent),
              ),
            ),
            child: IconTheme.merge(
              data: IconThemeData(color: textStyle.color),
              child: DefaultTextStyle(
                style: textStyle,
                child: Row(
                  children: [
                    _buildIcon(),
                    Flexible(child: _buildText(context)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    final duration = isExpanded ? const Duration(milliseconds: 400) : const Duration(milliseconds: 150);
    return AnimatedOpacity(
      curve: Curves.easeOutExpo,
      duration: duration,
      opacity: isExpanded ? 1 : 0,
      child: Collapsible.horizontal(
        isExpanded: isExpanded,
        curve: Curves.easeOutExpo,
        duration: duration,
        child: AnimatedScale(
          scale: isExpanded ? 1 : 0,
          curve: Curves.easeOutExpo,
          duration: duration,
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: DefaultTextStyle.merge(overflow: TextOverflow.ellipsis, child: item.title),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return SimpleShadow(
      opacity: 0.1,
      color: Colors.black,
      offset: const Offset(2, 2),
      sigma: 3,
      child: item.icon,
    );
  }
}
