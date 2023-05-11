import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:utopia_arch/utopia_arch.dart';
import 'package:utopia_cms/src/delegate/cms_to_many_delegate.dart';
import 'package:utopia_cms/src/model/cms_filter.dart';
import 'package:utopia_cms/src/ui/item_management/state/cms_item_management_state.dart';
import 'package:utopia_cms/src/util/json_map.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

class CmsToManyDropdownState {
  final ISet<JsonMap> selectedValues;

  final FieldState searchState;

  final bool isReady;

  final void Function(ISet<JsonMap>) onChanged;
  final Future<List<JsonMap>> Function({required CmsFilter filter}) getItems;

  const CmsToManyDropdownState({
    required this.searchState,
    required this.onChanged,
    required this.selectedValues,
    required this.isReady,
    required this.getItems,
  });
}

CmsToManyDropdownState useCmsToManyDropdownState({
  required CmsToManyDelegate delegate,
  required Object? originId,
}) {
  final baseState = useProvided<CmsItemManagementBaseState>();
  final selectedItemsState = useState<ISet<JsonMap>>(ISet());
  final searchState = useFieldState(initialValue: '');
  final initialSelectedValuesState = useAutoComputedState<ISet<JsonMap>>(
    compute: () async {
      if (originId != null) {
        final result = await delegate.get(originId: originId);
        selectedItemsState.value = result.toISet();
        return result.toISet();
      } else {
        return ISet();
      }
    },
    keys: [],
  );

  useSimpleEffect(() {
    baseState.addOnSavedCallback((value) async {
      final oldIds = initialSelectedValuesState.valueOrNull!.map((it) => it[delegate.foreignIdKey] as Object).toISet();
      final newIds = selectedItemsState.value.map((it) => it[delegate.foreignIdKey] as Object).toISet();
      return delegate.update(
        originId: value[delegate.originIdKey] as Object,
        addedForeignIds: newIds.difference(oldIds),
        removedForeignIds: oldIds.difference(newIds),
      );
    });
  }, []);

  Future<List<JsonMap>> getItems({required CmsFilter filter}) async {
    final result = await delegate.get(
      originId: null,
      filter: filter,
    );
    final ids = selectedItemsState.value.map((it) => it[delegate.foreignIdKey] as Object).toISet();
    final sorted = result.toSortedList(compareBy([(it) => ids.contains(it[delegate.foreignIdKey]) ? 0 : 1]));
    return sorted;
  }

  return CmsToManyDropdownState(
    isReady: initialSelectedValuesState.valueOrPreviousOrNull != null,
    searchState: searchState,
    selectedValues: selectedItemsState.value,
    getItems: getItems,
    onChanged: (value) => selectedItemsState.value = value,
  );
}
