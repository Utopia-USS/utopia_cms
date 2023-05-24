import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/cupertino.dart';
import 'package:utopia_cms/src/model/cms_table_page_params.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/ui/item_management/cms_item_management_page.dart';
import 'package:utopia_cms/src/util/json_map.dart';
import 'package:utopia_cms/src/util/map_extensions.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

typedef OnSavedCallback = Future<void> Function(JsonMap);

abstract class CmsItemManagementBaseState {
  abstract final JsonMap values;
  abstract final void Function(String key, Object? value) onValueChanged;

  abstract final void Function(OnSavedCallback action) addOnSavedCallback;
}

class CmsItemManagementState implements CmsItemManagementBaseState {
  @override
  final JsonMap values;
  final Future<void> Function() onSubmit;

  @override
  final void Function(String key, Object? value) onValueChanged;

  @override
  final void Function(OnSavedCallback action) addOnSavedCallback;

  final Future<void> Function() onDelete;

  final IList<CmsEntry> entries;

  final bool isUploading;
  final bool isDeleting;
  final bool isSubmitEnabled;
  final bool isEdit;
  final ScrollController scrollController;
  final CmsTableParams params;

  bool get canDelete => isEdit && params.canDelete;

  bool get isButtonAvailable =>
      !entries.where((e) => e.required && e.editable).any((element) => values.getAtPath(element.key) == null);

  const CmsItemManagementState({
    required this.values,
    required this.onSubmit,
    required this.onValueChanged,
    required this.params,
    required this.isUploading,
    required this.isDeleting,
    required this.isSubmitEnabled,
    required this.isEdit,
    required this.scrollController,
    required this.addOnSavedCallback,
    required this.onDelete,
    required this.entries,
  });
}

CmsItemManagementState useCmsItemManagementState({
  required CmsItemManagementArgs args,
  required void Function(bool) moveBack,
}) {
  final state = useState<JsonMap>(args.initialValue ?? {});

  void onValueChanged(String key, Object? value) {
    state.mutate((it) => it.setAtPath(key, value));
  }

  final onSavedCallbacksState = useState<IList<OnSavedCallback>>(IList());

  final uploadSubmitState = useSubmitState();
  Future<void> onSubmit() async {
    await uploadSubmitState.run(() async {
      final result = await args.uploadChanges(state.value);
      await Future.wait([for (final callback in onSavedCallbacksState.value) callback(result)]);
      moveBack(true);
    });
  }

  final deleteSubmitState = useSubmitState();
  Future<void> onDelete() async {
    await deleteSubmitState.run(() async {
      await args.deleteItem?.call();
      moveBack(true);
    });
  }

  final submitEnabled =
      !args.entries.any((e) => e.required && (state.value[e.key] == null || state.value[e.key].toString() == ''));

  final scrollController = useScrollController();

  return CmsItemManagementState(
    onDelete: onDelete,
    addOnSavedCallback: (callback) => onSavedCallbacksState.value = onSavedCallbacksState.value.add(callback),
    values: state.value,
    isSubmitEnabled: submitEnabled,
    onSubmit: onSubmit,
    onValueChanged: onValueChanged,
    isUploading: uploadSubmitState.isSubmitInProgress,
    isDeleting: deleteSubmitState.isSubmitInProgress,
    isEdit: args.initialValue != null,
    scrollController: scrollController,
    params: args.params,
    entries: args.entries,
  );
}
