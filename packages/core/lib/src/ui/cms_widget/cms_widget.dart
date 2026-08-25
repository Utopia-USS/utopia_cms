import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_cms/src/model/menu/cms_widget_menu_params.dart';
import 'package:utopia_cms/src/theme/cms_theme_data.dart';
import 'package:utopia_cms/src/ui/cms_widget/cms_shell_menu_scope.dart';
import 'package:utopia_cms/src/ui/cms_widget/cms_widget_item.dart';
import 'package:utopia_cms/src/ui/menu/cms_menu.dart';
import 'package:utopia_cms/src/ui/widget/layout/cms_breakpoints.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_cms/src/util/foundation.dart';

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

  @override
  Widget build(BuildContext context) {
    // Every hook runs unconditionally: `selectedPageId ?? useState(...)` would
    // short-circuit the hook calls whenever the host app hoists the id, so a
    // value that starts null and resolves later would change the hook count.
    // The first page id is also resolved leniently - a shell built only from
    // `.action` / `.custom` items simply has no selected page.
    final firstPageId = useMemoized(() {
      for (final item in items) {
        if (item is CmsWidgetItemPage) return item.id;
      }
      return null;
    });
    final localSelectedPageIdState = useState<String?>(firstPageId);
    final selectedPageIdValue = selectedPageId?.value ?? localSelectedPageIdState.value;
    final scaffoldKey = useMemoized(GlobalKey<ScaffoldState>.new);

    void selectPage(String id) {
      final hoistedSelectedPageId = selectedPageId;
      if (hoistedSelectedPageId != null) {
        hoistedSelectedPageId.value = id;
      } else {
        localSelectedPageIdState.value = id;
      }
    }

    void onItemPressed(int index, {required bool fromDrawer}) {
      items[index].map(
        page: (it) => selectPage(it.id),
        action: (it) => it.onPressed(),
        custom: (_) => null,
      );
      // In drawer presentation a tap dismisses the overlay.
      if (fromDrawer) scaffoldKey.currentState?.closeDrawer();
    }

    return Provider.value(
      value: theme ?? CmsThemeData.defaultTheme,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Shell breakpoint is measured on the full window width, before the
          // sidebar takes its share - tablet and phone both fall to the drawer.
          final isDrawer = constraints.maxWidth < CmsBreakpoints.sidebarMin;
          final content = _buildContent(selectedPageIdValue);

          return Scaffold(
            key: scaffoldKey,
            backgroundColor: context.colors.canvas,
            drawerScrimColor: Colors.black.withValues(alpha: 0.32),
            drawer: isDrawer
                ? CmsMenu(
                    presentation: CmsMenuPresentation.drawer,
                    items: items,
                    selectedPageId: selectedPageIdValue,
                    menuParams: menuParams,
                    onPressed: (index) => onItemPressed(index, fromDrawer: true),
                  )
                : null,
            body: Provider.value(
              value: CmsShellMenuScope(isDrawer: isDrawer, openDrawer: () => scaffoldKey.currentState?.openDrawer()),
              child: isDrawer
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: CmsMenu.shellGutter),
                      child: content,
                    )
                  : Row(
                      children: [
                        CmsMenu(
                          items: items,
                          selectedPageId: selectedPageIdValue,
                          menuParams: menuParams,
                          onPressed: (index) => onItemPressed(index, fromDrawer: false),
                        ),
                        Expanded(
                          // Left padding is the single shell gutter between sidebar
                          // and content (the menu carries no right margin); right
                          // padding matches it so the shell gutters stay uniform.
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: CmsMenu.shellGutter),
                            child: content,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(String? selectedPageId) {
    if (items.isEmpty) return const SizedBox.shrink();
    // An id that matches nothing - a typo, or a page dropped by role gating
    // while the hoisted id still points at it - must not reach the stack as -1.
    final index = items.indexWhere((it) => it is CmsWidgetItemPage && it.id == selectedPageId);
    final firstPageIndex = items.indexWhere((it) => it is CmsWidgetItemPage);
    return CrossFadeIndexedStack(
      duration: const Duration(milliseconds: 400),
      index: index >= 0
          ? index
          : firstPageIndex >= 0
          ? firstPageIndex
          : 0,
      lazy: true,
      children: [
        for (final item in items)
          item.map(
            page: (it) => it.content,
            action: (_) => const SizedBox.shrink(),
            custom: (_) => const SizedBox.shrink(),
          ),
      ],
    );
  }
}
