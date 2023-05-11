import 'package:flutter/material.dart';
import 'package:utopia_cms/src/ui/cms_widget/cms_widget_item.dart';
import 'package:utopia_cms/src/ui/common/layout/cms_gradient_background.dart';
import 'package:utopia_cms/src/ui/menu/cms_menu_tile.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

class CmsMenu extends HookWidget {
  final bool isExpandable;
  final String selectedPageId;
  final List<CmsWidgetItem> items;
  final void Function(int index) onPressed;

  static const _heightExtremum = 500;

  const CmsMenu({
    super.key,
    required this.items,
    required this.isExpandable,
    required this.selectedPageId,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isExpandedState = useState<bool>(false);
    final isExpanded = isExpandable && isExpandedState.value;
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: _buildVerticalPadding(constraints, context), horizontal: 16),
          child: MouseRegion(
            onExit: (_) => isExpandedState.toggle(),
            onEnter: (_) => isExpandedState.toggle(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutExpo,
              decoration: BoxDecoration(
                boxShadow: context.theme.menuShadow,
                borderRadius: _buildBorderRadius(constraints, context),
              ),
              width: isExpanded ? 200 : 70,
              child: CmsGradientBackground(
                borderRadius: _buildBorderRadius(constraints, context),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CmsMenuTile(
                      item: item,
                      isExpanded: isExpanded,
                      isSelected: item.maybeMap(page: (it) => it.id == selectedPageId, orElse: () => false),
                      onPressed: () => onPressed(index),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BorderRadius _buildBorderRadius(BoxConstraints constraints, BuildContext context) {
    if (constraints.maxHeight > _heightExtremum) return context.theme.menuRadius;
    return BorderRadius.zero;
  }

  double _buildVerticalPadding(BoxConstraints constraints, BuildContext context) {
    if (constraints.maxHeight > _heightExtremum) return context.theme.pageTopPadding;
    return 0;
  }
}
