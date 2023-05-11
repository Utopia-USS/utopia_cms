import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:utopia_cms/src/model/cms_functions_params.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/ui/common/table/cms_table_item.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_cms/src/util/json_map.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';
import 'package:utopia_widgets/misc/multi_widget.dart';

class CmsTable extends HookWidget {
  final IList<JsonMap> values;
  final IList<CmsEntry<dynamic>> entries;
  final ScrollController? scrollController;
  final CmsFunctionsSortingParams? currentSortParams;
  final void Function(JsonMap, int index)? onManagePressed;
  final void Function(CmsEntry) onSortPressed;
  final Widget Function(JsonMap, int index)? actionsBuilder;

  const CmsTable({
    super.key,
    required this.values,
    required this.entries,
    required this.onSortPressed,
    required this.currentSortParams,
    required this.onManagePressed,
    this.actionsBuilder,
    this.scrollController,
  });

  static const double tileHeight = 68;
  static const double actionsWidth = 24;
  static const EdgeInsets itemPadding = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(horizontal: 16);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      controller: scrollController,
      itemCount: values.length + 1,
      itemExtent: tileHeight,
      itemBuilder: (context, index) {
        final fixedIndex = index - 1;
        if (index == 0) {
          return _buildHeader(context);
        } else {
          return CmsTableItem(
              onManagePressed: () => onManagePressed?.call(values[fixedIndex], fixedIndex),
              data: values[fixedIndex],
              entries: entries,
              actionsWidth: actionsWidth,
              tileHeight: tileHeight,
              contentPadding: contentPadding,
              itemPadding: itemPadding,
              color: fixedIndex.isEven ? Colors.transparent : context.colors.field,
              actionsBuilder: actionsBuilder?.let((it) => (e) => it(e, fixedIndex)));
        }
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final style = context.textStyles.label;
    return Container(
      height: tileHeight,
      padding: contentPadding,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.accent, width: 0.75),
        ),
      ),
      child: Row(
        children: [
          ...entries.map(
            (e) => Expanded(flex: e.flex, child: _buildHeaderItem(e, style)),
          ),
          if (actionsBuilder != null)
            _buildRowCellPadding(
              child: const SizedBox(
                width: actionsWidth,
              ),
            ),
        ],
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
      padding: itemPadding,
      child: child,
    );
  }
}
