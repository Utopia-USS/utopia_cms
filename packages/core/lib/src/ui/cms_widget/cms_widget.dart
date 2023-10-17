import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_arch/utopia_arch.dart';
import 'package:utopia_cms/src/model/menu/cms_widget_menu_params.dart';
import 'package:utopia_cms/src/theme/cms_theme_data.dart';
import 'package:utopia_cms/src/ui/cms_widget/cms_widget_item.dart';
import 'package:utopia_cms/src/ui/menu/cms_menu.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';
import 'package:utopia_widgets/misc/cross_fade_indexed_stack.dart';

class CmsWidget extends HookWidget {
  final List<CmsWidgetItem> items;
  final CmsThemeData? theme;
  final MutableValue<String>? selectedPageId;
  final CmsWidgetMenuParams menuParams;

  const CmsWidget({
    super.key,
    required this.items,
    this.theme,
    this.selectedPageId,
    this.menuParams = const CmsWidgetMenuParams(),
  });

  static const double contentWidth = 600;

  @override
  Widget build(BuildContext context) {
    final selectedPageIdState =
        selectedPageId ?? useState(useMemoized(() => items.whereType<CmsWidgetItemPage>().first.id)).asMutableValue();

    return Provider.value(
      value: theme ?? CmsThemeData.defaultTheme,
      child: Scaffold(
        backgroundColor: context.colors.canvas,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Row(
              children: [
                CmsMenu(
                  canExpand: width > contentWidth * 1.3,
                  items: items,
                  selectedPageId: selectedPageIdState.value,
                  menuParams: menuParams,
                  onPressed: (index) => items[index].map(
                    page: (it) => selectedPageIdState.value = it.id,
                    action: (it) => it.onPressed(),
                    custom: (it) {
                      return null;
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: CrossFadeIndexedStack(
                      duration: const Duration(milliseconds: 400),
                      index: items.indexWhere((it) => it is CmsWidgetItemPage && it.id == selectedPageIdState.value),
                      lazy: true,
                      children: [
                        for (final item in items)
                          item.map(
                            page: (it) => it.content,
                            action: (_) => const SizedBox.shrink(),
                            custom: (_) => const SizedBox.shrink(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
