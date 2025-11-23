import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:utopia_cms/src/model/cms_functions_params.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/ui/widget/loading/cms_mock_loading_box.dart';
import 'package:utopia_cms/src/ui/widget/table/cms_table_header.dart';
import 'package:utopia_cms/src/ui/widget/table/cms_table_item.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_cms/src/util/json_map.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class CmsTable extends HookWidget {
  final bool showLoader;
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
    required this.showLoader,
    required this.onSortPressed,
    required this.currentSortParams,
    required this.onManagePressed,
    this.actionsBuilder,
    this.scrollController,
  });

  static const double tileHeight = 68;
  static const double actionsWidth = 24;
  static const EdgeInsets paddingRight = EdgeInsets.only(right: 14);
  static const EdgeInsets itemPadding = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(horizontal: 16);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CmsTableHeader(
          entries: entries,
          currentSortParams: currentSortParams,
          onSortPressed: onSortPressed,
          hasActions: actionsBuilder != null,
        ),
        if (showLoader)
          Expanded(child: _buildLoader(context))
        else
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.only(right: 14),
                controller: scrollController,
                itemCount: values.length,
                itemExtent: tileHeight,
                itemBuilder: (context, index) {
                  return CmsTableItem(
                    onManagePressed: () => onManagePressed?.call(values[index], index),
                    data: values[index],
                    entries: entries,
                    actionsWidth: actionsWidth,
                    tileHeight: tileHeight,
                    contentPadding: contentPadding,
                    itemPadding: itemPadding,
                    color: index.isOdd ? Colors.transparent : context.colors.field,
                    actionsBuilder: actionsBuilder?.let((it) => (e) => it(e, index)),
                  );
                }),
          ),
      ],
    );
  }

  Widget _buildLoader(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) {
        return const Padding(
          padding: EdgeInsets.only(bottom: CmsTable.tileHeight),
          child: CmsMockLoadingBox(
            width: double.infinity,
            height: CmsTable.tileHeight,
          ),
        );
      },
    );
  }
}
