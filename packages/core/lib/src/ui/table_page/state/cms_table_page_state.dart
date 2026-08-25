import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_cms/src/delegate/cms_delegate.dart';
import 'package:utopia_cms/src/model/cms_filter.dart';
import 'package:utopia_cms/src/model/cms_functions_params.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/filter_entry/cms_filter_entry.dart';
import 'package:utopia_cms/src/model/item_management/cms_management_section_entry.dart';
import 'package:utopia_cms/src/model/table/cms_table_page_params.dart';
import 'package:utopia_cms/src/theme/cms_theme_data.dart';
import 'package:utopia_cms/src/ui/item_management/cms_management_page.dart';
import 'package:utopia_cms/src/util/foundation.dart';
import 'package:utopia_cms/src/util/json_map.dart';
import 'package:utopia_cms/src/util/map_extensions.dart';

class CmsTablePageState {
  final MutableComputedState<void> computedState;
  final IList<JsonMap> items;
  final CmsTableParams params;
  final ScrollController scrollController;

  final JsonMap filterValues;
  final void Function(String entryKey, Object? value) onFilterChanged;
  final CmsFunctionsSortingParams? currentSortingParams;
  final bool pagingEnabled;

  final Future<void> Function() onCreatePressed;
  final Future<void> Function() onReloadPressed;
  final void Function(JsonMap, int index) onEditPressed;

  /// Deletes the row, returning whether the deletion actually ran - `false` when
  /// the confirmation was dismissed or a delete is already in flight.
  final Future<bool> Function(JsonMap, int index) onDeletePressed;
  final void Function(JsonMap, int index) updateItem;
  final void Function(CmsEntry) onSortPressed;

  const CmsTablePageState({
    required this.computedState,
    required this.items,
    required this.onCreatePressed,
    required this.onReloadPressed,
    required this.onDeletePressed,
    required this.onEditPressed,
    required this.params,
    required this.scrollController,
    required this.updateItem,
    required this.currentSortingParams,
    required this.onSortPressed,
    required this.pagingEnabled,
    required this.onFilterChanged,
    required this.filterValues,
  });

  bool get hasDefaultActions => params.canDelete || params.canEdit;
}

CmsTablePageState useCmsTablePageState({
  required CmsDelegate delegate,
  required CmsTableParams params,
  required NavigatorState navigator,
  required IList<CmsEntry<dynamic>> entries,
  required IList<CmsFilterEntry<dynamic>> filterEntries,
  required Future<bool?> Function() confirmDelete,
  required int? pagingLimit,
  required List<CmsManagementSectionEntry> managementSectionEntries,
}) {
  final sortingParamsState = useState<CmsFunctionsSortingParams?>(params.initialSortingParams);

  final pagingEnabledState = useState<bool>(true);
  final pagingOffsetState = useState<int>(0);
  final itemsState = useState<IList<JsonMap>>(IList());

  /// Bumped by every reset so a `get` that is still in flight cannot write its
  /// rows - or its offset - into the state the reset just emptied.
  final requestGenerationState = useState<int>(0);

  void resetState() {
    requestGenerationState.value++;
    pagingOffsetState.value = 0;
    pagingEnabledState.value = true;
    itemsState.value = IList();
  }

  final filtersState = useState(params.initialFilterValues);
  void onFilterChanged(String entryKey, Object? value) {
    resetState();
    // Deep copy: `setAtPath` mutates the parent map in place, so a shallow copy
    // would edit the nested maps of the caller's `initialFilterValues`.
    filtersState.value = filtersState.value.deepCopy()..setAtPath(entryKey, value);
  }

  CmsFilter buildFilter() {
    if (filterEntries.isEmpty) return const CmsFilterAll();
    // Values are written with `setAtPath`, so activeness has to be read with
    // `getAtPath` - a flat lookup misses every dotted `entryKey`.
    final activeEntries = filterEntries.where((a) => filtersState.value.getAtPath(a.entryKey) != null).toList();
    if (activeEntries.isEmpty) return const CmsFilterAll();
    if (activeEntries.length == 1) return activeEntries.first.filterFromValues(filtersState.value);
    return CmsFilterAnd(activeEntries.map((e) => e.filterFromValues(filtersState.value)).toList());
  }

  final state = useAutoComputedState<void>(
    () async {
      if (pagingEnabledState.value) {
        final generation = requestGenerationState.value;
        final result = await delegate.get(
          sorting: sortingParamsState.value,
          paging: CmsFunctionsPagingParams(offset: pagingOffsetState.value, limit: pagingLimit),
          filter: buildFilter(),
        );
        // Cancelling the operation this compute belongs to does not stop the
        // closure, so the discarded page has to be dropped explicitly - and a
        // page arriving after the table is gone must not touch the states at
        // all, because writing an unmounted one throws.
        if (!itemsState.mounted || generation != requestGenerationState.value) return;
        if (pagingLimit == null || result.length < pagingLimit) pagingEnabledState.value = false;

        if (result.isNotEmpty) {
          final existingIds = itemsState.value.map((e) => e[delegate.idKey]).toSet();
          final filtered = result.where((e) => !existingIds.contains(e[delegate.idKey]));
          itemsState.value = itemsState.value.addAll(filtered);
          pagingOffsetState.value += result.length;
        }
      }
    },
    keys: [sortingParamsState.value, filtersState.value],
    debounceDuration: const Duration(milliseconds: 300),
  );

  void updateItem(JsonMap value, int index) {
    itemsState.value = itemsState.value.replace(index, value);
  }

  final deleteSubmitState = useSubmitState();

  Future<bool> onDelete(JsonMap value, int index) async {
    // Guards a double tap: without it the confirmation opens twice and the row
    // is deleted twice. The confirmation runs inside the submit state so the
    // guard already holds while the dialog is open.
    if (deleteSubmitState.inProgress) return false;
    var isDeleted = false;
    // `run` routes a failing delete through the app's error handling (and makes
    // it retryable) instead of dropping it as an unhandled async error; inside
    // the management overlay `deleteItem` maps it onto the error message.
    await deleteSubmitState.run(() async {
      if (await confirmDelete() != true) return;
      await delegate.delete(value);
      isDeleted = true;
      // The row is gone either way, but the table it belonged to may have been
      // disposed while the request was open.
      if (!itemsState.mounted) return;
      // The captured index spans the confirmation and the request, so a reload
      // in that window may have shifted or replaced the rows.
      final items = itemsState.value;
      final id = value[delegate.idKey];
      final currentIndex = index >= 0 && index < items.length && items[index][delegate.idKey] == id
          ? index
          : items.indexWhere((it) => it[delegate.idKey] == id);
      if (currentIndex < 0) return;
      itemsState.value = items.removeAt(currentIndex);
      if (pagingOffsetState.value > 0) pagingOffsetState.value--;
    });
    return isDeleted;
  }

  // The overlay is pushed onto the app Navigator, outside the CmsWidget theme
  // provider, so the theme is resolved at push time and re-provided inside it.
  // Reading it lazily in onManage (rather than caching a value captured with
  // listen: false at an earlier build) means a runtime theme change is picked
  // up the next time the overlay opens, without waiting for a table refresh.
  final buildContext = useBuildContext();

  Future<void> reload() async {
    resetState();
    // `refresh` joins an operation that is already in progress and would hand
    // back its stale page instead of refetching, so cancel it first. The new
    // operation is deliberately not awaited: the next `clear` cancels it, and a
    // cancelled `CancelableOperation.value` never completes, so overlapping
    // reloads would strand the awaited future forever.
    state.clear();
    unawaited(state.refresh());
  }

  ///not null params mean that it's edit
  Future<void> onManage({JsonMap? value, int? index}) async {
    final theme = Provider.of<CmsThemeData?>(buildContext, listen: false) ?? CmsThemeData.defaultTheme;
    final result = await navigator.push<bool?>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, _) => CmsManagementOverlay(
          theme: theme,
          args: CmsManagementArgs(
            uploadChanges: (newJson, oldJson) =>
                value != null ? delegate.update(newJson, oldJson!) : delegate.create(newJson),
            deleteItem: value != null && index != null ? () => onDelete(value, index) : null,
            entries: entries,
            // Deep copy, so editing a dotted-key field cannot reach into the
            // live row and so `update` still sees the pre-edit nested values.
            initialValue: value?.deepCopy(),
            params: params,
            sectionEntries: managementSectionEntries,
          ),
          animation: animation,
        ),
      ),
    );
    if (result != null) await reload();
  }

  Future<void> onCreate() async => onManage();

  Future<void> onReload() async => reload();

  Future<void> onEdit(JsonMap value, int index) async => onManage(value: value, index: index);

  final scrollController = useMemoized(ScrollController.new, const [], (it) => it.dispose());

  Future<void> onSortPressed(CmsEntry entry) async {
    final currentValue = sortingParamsState.value;
    final isCurrent = entry.key == currentValue?.fieldKey;
    sortingParamsState.value = CmsFunctionsSortingParams(
      sortDesc: !(currentValue == null || !isCurrent) && !currentValue.sortDesc,
      invertNulls: entry.sortInvertNulls,
      fieldKey: entry.key,
    );
    resetState();
  }

  return CmsTablePageState(
    computedState: state,
    pagingEnabled: pagingEnabledState.value,
    items: itemsState.value,
    params: params,
    onCreatePressed: onCreate,
    onReloadPressed: onReload,
    onDeletePressed: onDelete,
    onEditPressed: onEdit,
    scrollController: scrollController,
    updateItem: updateItem,
    onSortPressed: onSortPressed,
    currentSortingParams: sortingParamsState.value,
    onFilterChanged: onFilterChanged,
    filterValues: filtersState.value,
  );
}
