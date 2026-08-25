import 'package:provider/provider.dart';
import 'package:utopia_cms/src/delegate/cms_to_many_delegate.dart';
import 'package:utopia_cms/src/model/cms_filter.dart';
import 'package:utopia_cms/src/ui/item_management/state/cms_management_state.dart';
import 'package:utopia_cms/src/util/foundation.dart';
import 'package:utopia_cms/src/util/json_map.dart';

class CmsToManyDropdownState {
  final ISet<JsonMap> selectedValues;

  /// Options matching the current (debounced) search; `null` while loading.
  final IList<JsonMap>? items;

  final FieldState searchState;

  final bool isReady;

  final void Function(JsonMap item) onToggle;

  const CmsToManyDropdownState({
    required this.selectedValues,
    required this.items,
    required this.searchState,
    required this.isReady,
    required this.onToggle,
  });
}

CmsToManyDropdownState useCmsToManyDropdownState({
  required CmsToManyDelegate delegate,
  required Object? originId,
  required List<String>? filterFields,
  required CmsFilter Function(String)? filterBuilder,
}) {
  // `CmsManagementOverlay` provides this via Flutter [Provider.value], so we
  // must read it through Flutter's context, not the utopia_hooks lookup.
  final baseState = Provider.of<CmsManagementBaseState>(useBuildContext(), listen: false);
  final selectedItemsState = useState<ISet<JsonMap>>(ISet());
  final searchState = useFieldState(initialValue: '');
  final debouncedSearch = useDebounced(searchState.value, duration: const Duration(milliseconds: 300));

  final initialSelectedValuesState = useAutoComputedState<ISet<JsonMap>>(() async {
    if (originId != null) {
      final result = await delegate.get(originId: originId);
      selectedItemsState.value = result.toISet();
      return result.toISet();
    } else {
      return ISet();
    }
  }, keys: []);

  final initialSelectedValuesOrPrevious = usePreviousIfNull(initialSelectedValuesState.valueOrNull);

  useEffect(() {
    baseState.addOnSavedCallback((value) async {
      // The field may not have finished loading when the parent form saves; treat an
      // unloaded field as having no previous selections (every current item is an add).
      final oldIds = (initialSelectedValuesState.valueOrNull ?? ISet<JsonMap>())
          .map((it) => it[delegate.foreignIdKey] as Object)
          .toISet();
      final newIds = selectedItemsState.value.map((it) => it[delegate.foreignIdKey] as Object).toISet();
      return delegate.update(
        originId: value[delegate.originIdKey] as Object,
        addedForeignIds: newIds.difference(oldIds),
        removedForeignIds: oldIds.difference(newIds),
      );
    });
    return null;
  }, []);

  CmsFilter buildFilter(String query) {
    final custom = filterBuilder?.call(query);
    if (custom != null) return custom;
    final fields = filterFields ?? const <String>[];
    // An empty OR group is always-false on supabase and hasura alike, so a field
    // configured without search columns would silently show no options at all.
    if (fields.isEmpty) return const CmsFilter.all();
    return CmsFilter.or([for (final field in fields) CmsFilter.containsString(field, query)]);
  }

  final itemsState = useAutoComputedState<IList<JsonMap>>(() async {
    final result = await delegate.get(filter: buildFilter(debouncedSearch));
    final ids = selectedItemsState.value.map((it) => it[delegate.foreignIdKey] as Object).toISet();
    // Keep already-selected rows pinned to the top of the list.
    return result.toSortedList(compareBy([(it) => ids.contains(it[delegate.foreignIdKey]) ? 0 : 1])).toIList();
  }, keys: [debouncedSearch]);

  void onToggle(JsonMap item) {
    final id = item[delegate.foreignIdKey];
    final current = selectedItemsState.value;
    final existing = current.where((it) => it[delegate.foreignIdKey] == id).toISet();
    selectedItemsState.value = existing.isEmpty ? current.add(item) : current.removeAll(existing);
  }

  return CmsToManyDropdownState(
    isReady: initialSelectedValuesOrPrevious != null,
    searchState: searchState,
    selectedValues: selectedItemsState.value,
    items: itemsState.valueOrNull,
    onToggle: onToggle,
  );
}
