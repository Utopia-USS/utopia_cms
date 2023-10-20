import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/filter_entry/cms_filter_entry.dart';
import 'package:utopia_cms/src/model/table_action/cms_table_action.dart';
import 'package:utopia_cms/src/ui/table_page/state/cms_table_page_state.dart';
import 'package:utopia_cms/src/ui/table_page/widget/cms_table_actions.dart';
import 'package:utopia_cms/src/ui/widget/button/cms_button.dart';
import 'package:utopia_cms/src/ui/widget/header/cms_header.dart';
import 'package:utopia_cms/src/ui/widget/loading/cms_loader.dart';
import 'package:utopia_cms/src/ui/widget/table/cms_table.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_cms/src/util/entries_extensions.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_widgets/misc/multi_widget.dart';

class CmsTablePageView extends HookWidget {
  final CmsTablePageState state;
  final IList<CmsEntry<dynamic>> entries;
  final IList<CmsFilterEntry<dynamic>> filterEntries;
  final IList<CmsTableAction> customActions;
  final String title;

  const CmsTablePageView({
    super.key,
    required this.state,
    required this.entries,
    required this.title,
    required this.customActions,
    required this.filterEntries,
  });

  static const double _filterWidthFactor = 120.0;

  @override
  Widget build(BuildContext context) {
    return MultiWidget(
      [
        (child) => Scaffold(backgroundColor: context.colors.canvas, body: child),
        (child) => SizedBox.expand(child: child),
        (child) => _buildNotificationListener(child: child),
        (_) => _buildContent(context),
      ],
    );
  }

  Widget _buildNotificationListener({required Widget child}) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.extentAfter < 50 && state.pagingEnabled && state.items.isNotEmpty) {
          unawaited(state.computedState.refresh());
        }
        return false;
      },
      child: child,
    );
  }

  Widget _buildContent(BuildContext context) {
    final values = state.items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: context.theme.pageTopPadding),
        _buildTopRow(context),
        Expanded(
          child:

              _buildTable(context),
        ),
        if (values.isNotEmpty && state.computedState.value is ComputedStateValueInProgress)
          const Center(
            child: CmsLoader(),
          ),
      ],
    );
  }

  Widget _buildTopRow(BuildContext context) {
    //todo revisit text
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CmsHeader(text: title),
              const Spacer(),
              if (state.params.canCreate)
                CmsButton(
                  maxWidth: context.theme.shortButtonWidth,
                  onTap: state.onCreatePressed,
                  dense: true,
                  child: const Text("Create"),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: filterEntries.map(
              (e) {
                return Flexible(
                  key: Key(e.entryKey),
                  flex: e.flex,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: _filterWidthFactor * e.flex),
                      child: e.buildField(
                        context: context,
                        value: e.fromJson(state.filterValues[e.entryKey]),
                        onChanged: (value) => state.onFilterChanged(e.entryKey, e.toJson(value)),
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    return CmsTable(
      showLoader: state.items.isEmpty && state.computedState.value is ComputedStateValueInProgress,
      onManagePressed: state.onEditPressed,
      scrollController: state.scrollController,
      values: state.items,
      entries: entries.pinned,
      onSortPressed: state.onSortPressed,
      currentSortParams: state.currentSortingParams,
      actionsBuilder: !state.hasDefaultActions && customActions.isEmpty
          ? null
          : (e, index) {
              ///workaround: force actions to the end of the [DataTable]
              return CmsTableActionsButton(
                value: e,
                onUpdate: (value) => state.updateItem(value, index),
                actions: [
                  _buildManageAction(index),
                  if (customActions.isNotEmpty) ...customActions,
                  if (state.params.canDelete) _buildDeleteAction(index),
                ],
              );
            },
    );
  }

  CmsTableAction _buildDeleteAction(int index) {
    return CmsTableAction(
      label: "Delete",
      shouldUpdateTable: false,
      onPressed: (value) async {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
            await state.onDeletePressed(value, index);
          },
        );
        return null;
      },
    );
  }

  CmsTableAction _buildManageAction(int index) {
    return CmsTableAction(
      label: "Manage",
      shouldUpdateTable: false,
      onPressed: (value) async {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
            state.onEditPressed(value, index);
          },
        );
        return null;
      },
    );
  }
}
