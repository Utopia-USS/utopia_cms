import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:utopia_cms/src/ui/widget/table/cms_table.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_widgets/misc/multi_widget.dart';

class CmsTableHeader extends StatelessWidget {
  final IList<CmsEntry<dynamic>> entries;
  final CmsFunctionsSortingParams? currentSortParams;
  final void Function(CmsEntry) onSortPressed;
  final bool hasActions;

  const CmsTableHeader({
    super.key,
    required this.entries,
    required this.currentSortParams,
    required this.onSortPressed,
    required this.hasActions,
  });

  @override
  Widget build(BuildContext context) {
    final style = context.textStyles.label;
    return Padding(
      padding: CmsTable.paddingRight,
      child: Container(
        height: CmsTable.tileHeight,
        padding: CmsTable.contentPadding,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.colors.accent, width: 0.75)),
        ),
        child: Row(
          children: [
            ...entries.map(
              (e) => Expanded(flex: e.flex, child: _buildHeaderItem(e, style)),
            ),
            if (hasActions)
              _buildRowCellPadding(
                child: const SizedBox(
                  width: CmsTable.actionsWidth,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderItem(CmsEntry entry, TextStyle style) {
    return MultiWidget(
      [
        if (entry.sortable) (child) => MouseRegion(cursor: SystemMouseCursors.click, child: child),
        if (entry.sortable) (child) => GestureDetector(onTap: () => onSortPressed(entry), child: child),
        (child) => _buildRowCellPadding(child: child),
        (_) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (entry.sortable) _buildSortingIcons(entry, style.color!),
                Flexible(
                  child: Text(
                    entry.fixedLabel,
                    style: style,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
      ],
    );
  }

  Widget _buildSortingIcons(CmsEntry entry, Color color) {
    final isCurrent = entry.key == currentSortParams?.fieldKey;
    final colorBottom = isCurrent && !currentSortParams!.sortDesc;
    final colorTop = isCurrent && currentSortParams!.sortDesc;

    Color getColor({required bool isActive}) => isActive ? color : color.withOpacity(0.25);

    ///giga hax: icons have some padding so they can't be in column
    return Padding(
      padding: const EdgeInsets.only(right: 2.0),
      child: Stack(
        children: [
          Align(
            alignment: const Alignment(0, -0.16),
            child: Icon(Icons.keyboard_arrow_up_rounded, color: getColor(isActive: colorTop), size: 18),
          ),
          Align(
            alignment: const Alignment(0, 0.16),
            child: Icon(Icons.keyboard_arrow_down_rounded, color: getColor(isActive: colorBottom), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildRowCellPadding({required Widget child}) {
    return Padding(
      padding: CmsTable.itemPadding,
      child: child,
    );
  }
}
