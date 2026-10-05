import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms/src/ui/table_page/state/cms_table_page_state.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

import '../_fake/recorder_delegate.dart';
import '../_fake/stub_build_context.dart';

void main() {
  late RecordingCmsDelegate delegate;
  late List<bool?> confirmations;
  late SimpleHookContext<CmsTablePageState> context;

  JsonMap row(String id) => {'id': id, 'name': 'name-$id'};

  /// Builds the table and loads [ids] as its first page (a full page keeps paging enabled).
  Future<void> buildWith(List<String> ids) async {
    context = SimpleHookContext(
      () => useCmsTablePageState(
        delegate: delegate,
        params: CmsTableParams.defaultParams,
        navigator: StubNavigator(),
        entries: IList(),
        filterEntries: IList(),
        confirmDelete: () async => confirmations.removeAt(0),
        pagingLimit: 2,
        managementSectionEntries: const [],
      ),
      provided: {BuildContext: StubBuildContext()},
    );
    await delegate.untilGetCount(1);
    delegate.gets[0].complete([for (final id in ids) row(id)]);
    await context.waitUntil((it) => it.items.length == ids.length);
  }

  /// The offset the next page would be requested from.
  Future<int> nextOffset() async {
    final count = delegate.gets.length;
    unawaited(context.value.computedState.refresh());
    await delegate.untilGetCount(count + 1);
    return delegate.gets.last.offset;
  }

  setUp(() {
    delegate = RecordingCmsDelegate();
    confirmations = [];
  });

  tearDown(() {
    if (context.mounted) context.dispose();
  });

  test('deleting a row removes it and steps the offset back', () async {
    await buildWith(['a', 'b']);

    confirmations.add(true);
    final deletion = context.value.onDeletePressed(row('a'), 0);
    await delegate.untilDeleteCount(1);
    delegate.completeDelete(0);

    expect(await deletion, true);
    expect(delegate.deletes.single['id'], 'a');
    expect(context.value.items.map((it) => it['id']), ['b']);
    expect(await nextOffset(), 1);
  });

  test('a dismissed confirmation deletes nothing and reports that it did not run', () async {
    await buildWith(['a']);

    confirmations.add(null);
    expect(await context.value.onDeletePressed(row('a'), 0), false);
    expect(delegate.deletes, isEmpty);
    expect(context.value.items.length, 1);
  });

  test('a second delete tap while one is in flight is ignored', () async {
    await buildWith(['a', 'b']);

    confirmations.addAll([true, true]);
    // The second tap lands while the first confirmation is still open, so it
    // must not open a second dialog either.
    final first = context.value.onDeletePressed(row('a'), 0);
    // Bounded: an unguarded second tap would await its own delete request, which
    // this test never resolves.
    expect(await context.value.onDeletePressed(row('a'), 0).timeout(const Duration(seconds: 1)), false);

    await delegate.untilDeleteCount(1);
    delegate.completeDelete(0);
    await first;
    expect(delegate.deletes.length, 1);
    expect(confirmations.length, 1);
  });

  group('a delete that resolves after a reload has landed', () {
    /// Starts deleting row 'a' (captured at index 0), reloads, lands [reloaded]
    /// as the new first page, and only then lets the delete resolve.
    Future<void> deleteAcrossReload(List<String> reloaded) async {
      await buildWith(['a', 'b']);
      confirmations.add(true);
      final deletion = context.value.onDeletePressed(row('a'), 0);
      await delegate.untilDeleteCount(1);

      unawaited(context.value.onReloadPressed());
      await delegate.untilGetCount(2);
      delegate.gets[1].complete([for (final id in reloaded) row(id)]);
      await context.waitUntil((it) => it.items.length == reloaded.length);

      delegate.completeDelete(0);
      expect(await deletion, true);
    }

    test('removes the row where it moved to, not the row at the captured index', () async {
      await deleteAcrossReload(['b', 'a']);

      expect(context.value.items.map((it) => it['id']), ['b']);
      expect(await nextOffset(), 1);
    });

    test('leaves the rows and the offset alone when the row is no longer listed', () async {
      await deleteAcrossReload(['c', 'd']);

      expect(context.value.items.map((it) => it['id']), ['c', 'd']);
      expect(await nextOffset(), 2);
    });
  });
}
