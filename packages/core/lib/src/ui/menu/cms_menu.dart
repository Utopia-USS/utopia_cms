import 'package:flutter/material.dart';
import 'package:utopia_cms/src/model/menu/cms_widget_menu_params.dart';
import 'package:utopia_cms/src/ui/cms_widget/cms_widget_item.dart';
import 'package:utopia_cms/src/ui/menu/cms_menu_tile.dart';
import 'package:utopia_cms/src/ui/widget/layout/cms_gradient_background.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_cms/src/util/foundation.dart';

/// How the menu is laid out by the shell.
///
/// * [rail] - an in-layout column on wide screens: collapsed by default, peeks
///   open on hover and pins open via the top toggle icon.
/// * [drawer] - the menu hosted inside `Scaffold.drawer` on small screens:
///   always full and flush, no collapse / hover, tapping an item closes it.
enum CmsMenuPresentation { rail, drawer }

class CmsMenu extends HookWidget {
  final CmsMenuPresentation presentation;
  final String selectedPageId;
  final List<CmsWidgetItem> items;
  final void Function(int index) onPressed;
  final CmsWidgetMenuParams menuParams;

  static const _heightExtremum = 500;

  /// The uniform shell gutter (window->sidebar, sidebar->content, content->edge).
  /// The single source of truth, also used by `CmsWidget`'s content padding.
  static const double shellGutter = 16;

  static const double _expandedWidth = 300;
  static const double _collapsedWidth = 76;

  const CmsMenu({
    super.key,
    required this.items,
    required this.selectedPageId,
    required this.onPressed,
    this.presentation = CmsMenuPresentation.rail,
    this.menuParams = const CmsWidgetMenuParams(),
  });

  bool get _isDrawer => presentation == CmsMenuPresentation.drawer;

  /// A gradient needs two stops; a single colour is a flat fill.
  static List<Color> _gradientColors(List<Color> colors) => colors.length == 1 ? [colors.first, colors.first] : colors;

  @override
  Widget build(BuildContext context) {
    // Rail-only runtime state. Hooks run unconditionally (the drawer branch
    // ignores them) so hook order stays stable for the element's lifetime.
    final isPinnedExpanded = useState<bool>(false);
    final isHovering = useState<bool>(false);

    if (_isDrawer) return _buildDrawer(context);

    if (!menuParams.isCollapsible) {
      return _buildRail(context, isExpanded: true, isPinned: true, onToggle: () {});
    }

    final isExpanded = isPinnedExpanded.value || isHovering.value;
    return MouseRegion(
      onEnter: (_) => isHovering.value = true,
      onExit: (_) => isHovering.value = false,
      child: _buildRail(
        context,
        isExpanded: isExpanded,
        isPinned: isPinnedExpanded.value,
        onToggle: () => isPinnedExpanded.value = !isPinnedExpanded.value,
      ),
    );
  }

  // --- Rail (wide screens) ---

  Widget _buildRail(
    BuildContext context, {
    required bool isExpanded,
    required bool isPinned,
    required VoidCallback onToggle,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final verticalPadding = _railVerticalPadding(constraints, context);
        final radius = _railBorderRadius(constraints, context);
        final theme = context.theme;
        // Default sidebar is a card matching the content card (same surface,
        // border, shadow, radius). A colour gradient is used only when the host
        // opts in via menuParams.backgroundColors. No right margin here: the
        // single shell gutter to the content is owned by the content's left
        // padding (see CmsWidget), so the shell gutters stay uniform.
        final useCard = menuParams.backgroundColors == null;
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.fromLTRB(shellGutter, verticalPadding, 0, verticalPadding),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutExpo,
            width: isExpanded ? _expandedWidth : _collapsedWidth,
            clipBehavior: Clip.antiAlias,
            decoration: useCard
                ? BoxDecoration(color: theme.colors.surface, borderRadius: radius, boxShadow: theme.cardShadow)
                : BoxDecoration(
                    boxShadow: theme.menuShadow,
                    borderRadius: radius,
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: _gradientColors(menuParams.backgroundColors!),
                    ),
                  ),
            foregroundDecoration: useCard
                ? BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(color: theme.colors.border, width: theme.cardBorderWidth),
                  )
                : null,
            child: _buildBody(
              context,
              isExpanded: isExpanded,
              onColored: !useCard,
              toolbar: menuParams.isCollapsible
                  ? _buildToolbar(
                      context,
                      isExpanded: isExpanded,
                      isPinned: isPinned,
                      onToggle: onToggle,
                      onColored: !useCard,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  // --- Drawer (small screens) ---

  Widget _buildDrawer(BuildContext context) {
    final theme = context.theme;
    final useCard = menuParams.backgroundColors == null;
    final body = SafeArea(child: _buildBody(context, isExpanded: true, onColored: !useCard, toolbar: null));
    return SizedBox(
      width: _expandedWidth,
      child: Material(
        color: useCard ? theme.colors.surface : Colors.transparent,
        child: useCard
            ? body
            : CmsGradientBackground(borderRadius: BorderRadius.zero, colors: menuParams.backgroundColors, child: body),
      ),
    );
  }

  // --- Shared body ---

  Widget _buildBody(
    BuildContext context, {
    required bool isExpanded,
    required bool onColored,
    required Widget? toolbar,
  }) {
    return FillViewportScrollView(
      child: Column(
        children: [
          ?toolbar,
          if (menuParams.headerBuilder != null) _buildHeader(context, isCollapsed: !isExpanded),
          const SizedBox(height: 12),
          for (int index = 0; index < items.length; index++)
            if (items[index] is CmsWidgetItemCustom)
              _buildCustom(items[index] as CmsWidgetItemCustom)
            else
              CmsMenuTile(
                item: items[index],
                isExpanded: isExpanded,
                onColored: onColored,
                isSelected: items[index].maybeMap(page: (it) => it.id == selectedPageId, orElse: () => false),
                onPressed: () => onPressed(index),
              ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// The top control row: the panel toggle that pins / unpins the rail. The
  /// glyph reflects the pinned *intent* (not a transient hover-peek): a panel
  /// icon while flexible, a collapse icon while pinned open. Left-aligned when
  /// expanded, centred in the narrow rail when collapsed.
  Widget _buildToolbar(
    BuildContext context, {
    required bool isExpanded,
    required bool isPinned,
    required VoidCallback onToggle,
    required bool onColored,
  }) {
    final toggle = _CmsMenuIconButton(
      icon: isPinned ? Icons.menu_open : Icons.view_sidebar_outlined,
      tooltip: isPinned ? 'Collapse menu' : 'Expand menu',
      onColored: onColored,
      onPressed: onToggle,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(isExpanded ? 14 : 0, 14, isExpanded ? 14 : 0, 2),
      child: Align(alignment: isExpanded ? Alignment.centerLeft : Alignment.center, child: toggle),
    );
  }

  Widget _buildCustom(CmsWidgetItemCustom item) {
    return MultiWidget([if (item.flex != null) (child) => Expanded(flex: item.flex!, child: child), (_) => item.child]);
  }

  /// The host-provided header, pinned above the items with a consistent top
  /// gutter. The host owns the header's height and alignment (via the builder):
  /// keep the height equal across collapsed / expanded so the items below do
  /// not shift when the rail toggles.
  Widget _buildHeader(BuildContext context, {required bool isCollapsed}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: menuParams.headerBuilder!(context, isCollapsed),
    );
  }

  BorderRadius _railBorderRadius(BoxConstraints constraints, BuildContext context) {
    if (constraints.maxHeight > _heightExtremum) return context.theme.cardRadius;
    return BorderRadius.zero;
  }

  double _railVerticalPadding(BoxConstraints constraints, BuildContext context) {
    if (constraints.maxHeight > _heightExtremum) return context.theme.pageTopPadding;
    return 0;
  }
}

/// A small, square icon button for the menu's top control row. Muted by
/// default, with a soft hover fill, matching the chrome icons in the Claude
/// sidebar reference.
class _CmsMenuIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool onColored;
  final VoidCallback? onPressed;

  const _CmsMenuIconButton({required this.icon, required this.tooltip, this.onColored = false, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final color = onColored ? Colors.white.withValues(alpha: 0.85) : context.colors.hint;
    final hover = onColored ? Colors.white.withValues(alpha: 0.10) : context.colors.hover;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          hoverColor: hover,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }
}
