import 'package:flutter/material.dart';
import 'package:utopia_arch/utopia_arch.dart';
import 'package:utopia_cms/src/model/menu/cms_widget_menu_params.dart';
import 'package:utopia_cms/src/ui/cms_widget/cms_widget_item.dart';
import 'package:utopia_cms/src/ui/widget/layout/cms_gradient_background.dart';
import 'package:utopia_cms/src/ui/menu/cms_menu_tile.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_widgets/layout/fill_viewport_scroll_view.dart';
import 'package:utopia_widgets/misc/multi_widget.dart';

class CmsMenu extends HookWidget {
  final bool canExpand;
  final String selectedPageId;
  final List<CmsWidgetItem> items;
  final void Function(int index) onPressed;
  final CmsWidgetMenuParams menuParams;

  static const _heightExtremum = 500;

  const CmsMenu({
    super.key,
    required this.items,
    required this.canExpand,
    required this.selectedPageId,
    required this.onPressed,
    this.menuParams = const CmsWidgetMenuParams(),
  });

  CmsMenuType get type => menuParams.type;

  CmsMenuBehavior get behavior => menuParams.behavior;

  @override
  Widget build(BuildContext context) {
    final isExpandedState = useState<bool>(false);
    final isExpanded = (canExpand && isExpandedState.value && behavior != CmsMenuBehavior.collapsed) ||
        behavior == CmsMenuBehavior.expanded;

    return LayoutBuilder(
      builder: (context, constraints) {
        final verticalPadding = _buildVerticalPadding(constraints, context);
        final leftPadding = type == CmsMenuType.standard ? 0.0 : 16.0;
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.fromLTRB(leftPadding, verticalPadding, 16, verticalPadding),
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
                colors: menuParams.backgroundColors,
                child: FillViewportScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      for (int index = 0; index < items.length; index++)
                        if (items[index] is CmsWidgetItemCustom)
                          _buildCustom(items[index] as CmsWidgetItemCustom)
                        else
                          CmsMenuTile(
                            item: items[index],
                            isExpanded: isExpanded,
                            isSelected:
                                items[index].maybeMap(page: (it) => it.id == selectedPageId, orElse: () => false),
                            onPressed: () => onPressed(index),
                          ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustom(CmsWidgetItemCustom item) {
    return MultiWidget(
      [
        if (item.flex != null) (child) => Expanded(flex: item.flex!, child: child),
        (_) => item.child,
      ],
    );
  }

  BorderRadius _buildBorderRadius(BoxConstraints constraints, BuildContext context) {
    if (type == CmsMenuType.standard) return BorderRadius.zero;
    if (constraints.maxHeight > _heightExtremum) return context.theme.menuRadius;
    return BorderRadius.zero;
  }

  double _buildVerticalPadding(BoxConstraints constraints, BuildContext context) {
    if (type == CmsMenuType.standard) return 0;
    if (constraints.maxHeight > _heightExtremum) return context.theme.pageTopPadding;
    return 0;
  }
}
