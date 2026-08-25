import 'package:flutter/cupertino.dart';
import 'package:utopia_cms/src/delegate/cms_delegate_exception.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/table/cms_table_page_params.dart';
import 'package:utopia_cms/src/ui/item_management/cms_management_page.dart';
import 'package:utopia_cms/src/util/foundation.dart';
import 'package:utopia_cms/src/util/json_map.dart';
import 'package:utopia_cms/src/util/map_extensions.dart';

typedef OnSavedCallback = Future<void> Function(JsonMap);

abstract class CmsManagementBaseState {
  abstract final JsonMap values;
  abstract final void Function(String key, Object? value) onValueChanged;

  abstract final void Function(OnSavedCallback action) addOnSavedCallback;
}

class CmsItemManagementState implements CmsManagementBaseState {
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
  final bool isEdit;
  final bool hasChanges;
  final String? errorMessage;
  final ScrollController scrollController;
  final CmsTableParams params;

  bool get canDelete => isEdit && params.canDelete;

  bool get canCreate => !isEdit || params.canEdit;

  bool get isButtonAvailable {
    // Validate exactly the entries the flow renders as writable, through the
    // same `CmsEntry.isWritable` rule `EntriesExtensions.editable` applies. The
    // old `required && editable` filter both skipped a required
    // initializable-only entry and demanded a value for a required
    // editable-only entry that create never shows.
    final requiredFieldsFilled = !entries
        .where((e) => e.required && e.isWritable(isCreate: !isEdit))
        .any((e) => values.getAtPath(e.key) == null);
    if (!requiredFieldsFilled) return false;
    if (!isEdit) return true;
    return hasChanges;
  }

  const CmsItemManagementState({
    required this.values,
    required this.onSubmit,
    required this.onValueChanged,
    required this.params,
    required this.isUploading,
    required this.isDeleting,
    required this.isEdit,
    required this.hasChanges,
    required this.errorMessage,
    required this.scrollController,
    required this.addOnSavedCallback,
    required this.onDelete,
    required this.entries,
  });
}

CmsItemManagementState useCmsItemManagementState({
  required CmsManagementArgs args,
  // ignore: avoid_positional_boolean_parameters
  required void Function(bool) moveBack,
}) {
  // Deep copies, because `setAtPath` mutates the parent map in place: with a
  // shallow copy a dotted-key edit would reach into the live table row and
  // would also hide itself from the old/new diff `uploadChanges` receives.
  final state = useState<JsonMap>(args.initialValue?.deepCopy() ?? <String, dynamic>{});
  final hasChangesState = useState(false);

  void onValueChanged(String key, Object? value) {
    final newMap = state.value.deepCopy();
    newMap.setAtPath(key, value);
    state.value = newMap;
    hasChangesState.value = true;
  }

  final onSavedCallbacksState = useState<IList<OnSavedCallback>>(IList());
  final errorMessageState = useState<String?>(null);

  final uploadSubmitState = useSubmitState();
  Future<void> onSubmit() async {
    var isCommitted = false;
    await uploadSubmitState.runSimple<void, String>(
      // A second tap must not write a second row.
      skipIfInProgress: true,
      beforeSubmit: () => errorMessageState.value = null,
      submit: () async {
        final result = await args.uploadChanges(state.value, args.initialValue);
        // From here on the row is written. A post-save callback that throws must
        // not send the user back to retry the write - that would create a
        // duplicate - so the overlay closes either way and the failure travels
        // out of `runSimple` to the app error handler instead of `errorMessage`.
        isCommitted = true;
        try {
          await Future.wait([for (final callback in onSavedCallbacksState.value) callback(result)]);
        } finally {
          moveBack(true);
        }
      },
      mapError: (exception) => !isCommitted && exception is CmsDelegateException ? exception.message : null,
      afterKnownError: (errorMessage) => errorMessageState.value = errorMessage,
    );
  }

  final deleteSubmitState = useSubmitState();

  Future<void> onDelete() async {
    await deleteSubmitState.runSimple<void, String>(
      skipIfInProgress: true,
      beforeSubmit: () => errorMessageState.value = null,
      submit: () async {
        // `deleteItem` reports whether the deletion actually ran: a cancelled
        // confirmation must leave the overlay - and its unsaved edits - open.
        final isDeleted = await args.deleteItem?.call() ?? false;
        if (isDeleted) moveBack(true);
      },
      mapError: (exception) => exception is CmsDelegateException ? exception.message : null,
      afterKnownError: (errorMessage) => errorMessageState.value = errorMessage,
    );
  }

  final scrollController = useMemoized(ScrollController.new, const [], (it) => it.dispose());

  return CmsItemManagementState(
    onDelete: onDelete,
    addOnSavedCallback: (callback) => onSavedCallbacksState.value = onSavedCallbacksState.value.add(callback),
    values: state.value,
    onSubmit: onSubmit,
    onValueChanged: onValueChanged,
    isUploading: uploadSubmitState.inProgress,
    isDeleting: deleteSubmitState.inProgress,
    isEdit: args.initialValue != null,
    hasChanges: hasChangesState.value,
    errorMessage: errorMessageState.value,
    scrollController: scrollController,
    params: args.params,
    entries: args.entries,
  );
}
