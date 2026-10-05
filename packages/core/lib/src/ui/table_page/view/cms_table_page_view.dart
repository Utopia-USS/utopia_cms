import 'dart:async';

import 'package:flutter/material.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/filter_entry/cms_filter_entry.dart';
import 'package:utopia_cms/src/model/filter_entry/cms_search_filter_entry.dart';
import 'package:utopia_cms/src/model/table/cms_table_action.dart';
import 'package:utopia_cms/src/ui/table_page/state/cms_table_page_state.dart';
import 'package:utopia_cms/src/ui/widget/header/cms_header.dart';
import 'package:utopia_cms/src/ui/widget/layout/cms_page_wrapper.dart';
import 'package:utopia_cms/src/ui/widget/loading/cms_loader.dart';
import 'package:utopia_cms/src/ui/widget/table/cms_table.dart';
import 'package:utopia_cms/src/ui/widget/table/cms_table_actions.dart';
import 'package:utopia_cms/src/ui/widget/table/cms_table_search_panel.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_cms/src/util/entries_extensions.dart';
import 'package:utopia_cms/src/util/foundation.dart';
import 'package:utopia_cms/src/util/map_extensions.dart';

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

  @override
  Widget build(BuildContext context) {
    return MultiWidget([
      (child) => Scaffold(backgroundColor: context.colors.canvas, body: child),
      (child) => SizedBox.expand(child: child),
      (child) => _buildNotificationListener(child: child),
      (_) => _buildContent(context),
    ]);
  }

  Widget _buildNotificationListener({required Widget child}) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.extentAfter < 50 &&
            state.pagingEnabled &&
            state.items.isNotEmpty &&
            state.computedState.value is! ComputedStateValueInProgress) {
          unawaited(state.computedState.refresh());
        }
        return false;
      },
      child: child,
    );
  }

  Widget _buildContent(BuildContext context) {
    final isLoadingMore = state.items.isNotEmpty && state.computedState.value is ComputedStateValueInProgress;
    return CustomScrollView(
      controller: state.scrollController,
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: context.theme.pageTopPadding)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CmsHeader(text: title),
          ),
        ),
        SliverPadding(padding: const EdgeInsets.only(bottom: 24), sliver: _buildTable(context)),
        if (isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CmsLoader()),
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: context.theme.pageTopPadding)),
      ],
    );
  }

  Widget _buildTable(BuildContext context) {
    return CmsTable(
      showLoader: state.items.isEmpty && state.computedState.value is ComputedStateValueInProgress,
      onManagePressed: state.onEditPressed,
      values: state.items,
      entries: entries.pinnedFor(context.pageType),
      onSortPressed: state.onSortPressed,
      currentSortParams: state.currentSortingParams,
      searchPanel: _buildSearchPanel(context),
      actionsBuilder: !state.hasDefaultActions && customActions.isEmpty
          ? null
          : (e, index) {
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

  Widget _buildSearchPanel(BuildContext context) {
    final search = _searchEntry();
    return CmsTableSearchPanel(
      searchEntry: search,
      searchHint: _searchHint(search),
      searchValue: search == null ? null : state.filterValues.getAtPath(search.entryKey) as String?,
      otherFilters: filterEntries.where((e) => e is! CmsFilterSearchEntry).toIList(),
      filterValues: state.filterValues,
      onFilterChanged: state.onFilterChanged,
      canCreate: state.params.canCreate,
      onCreatePressed: state.onCreatePressed,
      isReloading: state.computedState.value is ComputedStateValueInProgress,
      onReloadPressed: state.onReloadPressed,
    );
  }

  CmsFilterSearchEntry? _searchEntry() {
    for (final entry in filterEntries) {
      if (entry is CmsFilterSearchEntry) return entry;
    }
    return null;
  }

  String _searchHint(CmsFilterSearchEntry? search) {
    if (search == null) return 'Search';
    final labels = entries
        .where((e) => search.filterKeys.any((key) => key == e.key || key.startsWith('${e.key}.')))
        .map((e) => e.fixedLabel)
        .toList();
    if (labels.isNotEmpty) return 'Search by ${labels.join(', ')}';
    final label = search.label;
    return label == null || label.isEmpty ? 'Search' : label;
  }

  CmsTableAction _buildDeleteAction(int index) {
    return CmsTableAction(
      label: "Delete",
      shouldUpdateTable: false,
      onPressed: (value) async {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await state.onDeletePressed(value, index);
        });
        return null;
      },
    );
  }

  CmsTableAction _buildManageAction(int index) {
    return CmsTableAction(
      label: "Manage",
      shouldUpdateTable: false,
      onPressed: (value) async {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          state.onEditPressed(value, index);
        });
        return null;
      },
    );
  }
}
