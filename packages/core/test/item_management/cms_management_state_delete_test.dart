import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms/src/ui/item_management/cms_management_page.dart';
import 'package:utopia_cms/src/ui/item_management/state/cms_management_state.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

void main() {
  late List<bool> moveBacks;
  late int deleteCallCount;
  late SimpleHookContext<CmsItemManagementState> context;

  /// [deleteItem] mirrors the table's contract: it reports whether the deletion
  /// actually ran, so a dismissed confirmation is distinguishable from a delete.
  SimpleHookContext<CmsItemManagementState> build({Future<bool> Function()? deleteItem}) {
    return context = SimpleHookContext(
      () => useCmsItemManagementState(
        args: CmsManagementArgs(
          initialValue: const {'id': '1', 'name': 'Ada'},
          uploadChanges: (newJson, _) async => newJson,
          deleteItem: deleteItem == null
              ? null
              : () {
                  deleteCallCount++;
                  return deleteItem();
                },
          params: CmsTableParams.defaultParams,
          entries: <CmsEntry<dynamic>>[].lock,
          sectionEntries: const [],
        ),
        moveBack: moveBacks.add,
      ),
    );
  }

  setUp(() {
    moveBacks = [];
    deleteCallCount = 0;
  });

  tearDown(() => context.dispose());

  test('a confirmed delete closes the overlay', () async {
    build(deleteItem: () async => true);

    await context.value.onDelete();

    expect(deleteCallCount, 1);
    expect(moveBacks, [true]);
  });

  test('a dismissed confirmation keeps the overlay open', () async {
    build(deleteItem: () async => false);

    await context.value.onDelete();

    expect(deleteCallCount, 1);
    expect(moveBacks, isEmpty);
  });

  test('a second delete tap while one is in flight does not delete twice', () async {
    final completer = Completer<bool>();
    build(deleteItem: () => completer.future);

    unawaited(context.value.onDelete());
    expect(context.value.isDeleting, true);

    // Bounded: on unguarded code the second call joins the pending delete and hangs.
    await context.value.onDelete().timeout(const Duration(seconds: 1));
    expect(deleteCallCount, 1);

    completer.complete(true);
    await context.waitUntil((it) => !it.isDeleting);
    expect(moveBacks, [true]);
  });

  test('delete is a no-op without a deleteItem', () async {
    build();

    await context.value.onDelete();

    expect(moveBacks, isEmpty);
  });

  test('a failing delete surfaces as an error message', () async {
    build(deleteItem: () => Future.error(const CmsDelegateException('row is referenced elsewhere')));

    await context.value.onDelete();

    expect(context.value.errorMessage, 'row is referenced elsewhere');
    expect(moveBacks, isEmpty);
  });
}
