import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:utopia_cms/src/delegate/cms_delegate.dart';
import 'package:utopia_cms/src/model/cms_filter.dart';
import 'package:utopia_cms/src/model/cms_functions_params.dart';
import 'package:utopia_cms/src/model/cms_table_page_params.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/filter_entry/cms_filter_entry.dart';
import 'package:utopia_cms/src/ui/item_management/cms_item_management_page.dart';
import 'package:utopia_cms/src/util/json_map.dart';
import 'package:utopia_cms/src/util/map_extensions.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class CmsTablePageState {
  final MutableComputedState<void> computedState;
  final IList<JsonMap> items;
  final CmsTableParams params;
  final ScrollController scrollController;

  final JsonMap filterValues;
  final void Function(String entryKey, dynamic value) onFilterChanged;
  final CmsFunctionsSortingParams? currentSortingParams;
  final bool pagingEnabled;

  final Future<void> Function() onCreatePressed;
  final void Function(JsonMap, int index) onEditPressed;
  final Future<void> Function(JsonMap, int index) onDeletePressed;
  final void Function(JsonMap, int index) updateItem;
  final void Function(CmsEntry) onSortPressed;

  const CmsTablePageState({
    required this.computedState,
    required this.items,
    required this.onCreatePressed,
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
}) {
  final sortingParamsState = useState<CmsFunctionsSortingParams?>(params.initialSortingParams);

  final pagingEnabledState = useState<bool>(true);
  final pagingOffsetState = useState<int>(0);
  final itemsState = useState<IList<JsonMap>>(IList());
  void resetState() {
    pagingOffsetState.value = 0;
    pagingEnabledState.value = true;
    itemsState.value = IList();
  }

  final filtersState = useState<JsonMap>({});
  void onFilterChanged(String entryKey, dynamic value) {
    resetState();
    filtersState.value = {...filtersState.value}..setAtPath(entryKey, value);
  }

  CmsFilter buildFilter() {
    if (filterEntries.isEmpty) return const CmsFilterAll();
    final fixedValues = filterEntries.where((a) => filtersState.value[a.entryKey] != null);
    if(fixedValues.isEmpty) return const CmsFilterAll();
    if(fixedValues.length == 1) return fixedValues.first.filterFromValues(filtersState.value);
    return CmsFilterAnd(filterEntries
        .where((a) => filtersState.value[a.entryKey] != null)
        .map((e) => e.filterFromValues(filtersState.value))
        .toList());
  }

  final state = useAutoComputedState<void>(
    compute: () async {
      if (pagingEnabledState.value) {
        final result = await delegate.get(
          sorting: sortingParamsState.value,
          paging: CmsFunctionsPagingParams(offset: pagingOffsetState.value, limit: pagingLimit),
          filter: buildFilter(),
        );
        if (pagingLimit == null || result.length < pagingLimit) pagingEnabledState.value = false;

        if (result.isNotEmpty) {
          final filtered =
          result.where((e1) => !itemsState.value.any((e2) => e1[delegate.idKey] == e2[delegate.idKey]));
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



  Future<void> onCreate() async {
    final result = await navigator.push<bool?>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, ___) =>
            CmsItemManagement(
              args: CmsItemManagementArgs(
                uploadChanges: (json, _) => delegate.create(json),
                entries: entries,
                params: params,
              ),
              animation: animation,
            ),
      ),
    );
    if (result != null) {
      resetState();
      await state.refresh();
    }
  }

  Future<void> onDelete(JsonMap value, int index) async {
    final shouldDelete = await confirmDelete();
    if (shouldDelete != null && shouldDelete) {
      await delegate.delete(value);
      itemsState.value = itemsState.value.removeAt(index);
      pagingOffsetState.value--;
    }
  }

  Future<void> onEdit(JsonMap value, int index) async {
    final result = await navigator.push<bool?>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, ___) =>
            CmsItemManagement(
              args: CmsItemManagementArgs(
                uploadChanges: (newJson, oldJson) => delegate.update(newJson, oldJson!),
                deleteItem: () => onDelete(value, index),
                entries: entries,
                initialValue: Map.of(value),
                params: params,
              ),
              animation: animation,
            ),
      ),
    );
    if (result != null) {
      resetState();
      await state.refresh();
    }
  }

  final scrollController = useScrollController();

  Future<void> onSortPressed(CmsEntry entry) async {
    final currentValue = sortingParamsState.value;
    final isCurrent = entry.key == currentValue?.fieldKey;
    if (currentValue == null || !isCurrent) {
      sortingParamsState.value = CmsFunctionsSortingParams(sortDesc: false, fieldKey: entry.key);
    } else {
      sortingParamsState.value = CmsFunctionsSortingParams(sortDesc: !currentValue.sortDesc, fieldKey: entry.key);
    }
    resetState();
  }

  return CmsTablePageState(
    computedState: state,
    pagingEnabled: pagingEnabledState.value,
    items: itemsState.value,
    params: params,
    onCreatePressed: onCreate,
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
