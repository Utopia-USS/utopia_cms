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

  SimpleHookContext<CmsTablePageState> build({int? pagingLimit = 2}) {
    return context = SimpleHookContext(
      () => useCmsTablePageState(
        delegate: delegate,
        params: CmsTableParams.defaultParams,
        navigator: StubNavigator(),
        entries: IList(),
        filterEntries: [CmsFilterSearchEntry(filterKeys: const ['name'], entryKey: 'query')].lock,
        confirmDelete: () async => confirmations.removeAt(0),
        pagingLimit: pagingLimit,
        managementSectionEntries: const [],
      ),
      provided: {BuildContext: StubBuildContext()},
    );
  }

  setUp(() {
    delegate = RecordingCmsDelegate();
    confirmations = [];
  });

  tearDown(() => context.dispose());

  test('the first page is requested from offset 0 with the initial paging limit', () async {
    build();
    await delegate.untilGetCount(1);

    expect(delegate.gets.single.offset, 0);
    expect(delegate.gets.single.limit, 2);
    expect(context.value.items, isEmpty);
  });

  test('a page shorter than the limit disables paging', () async {
    build();
    await delegate.untilGetCount(1);

    delegate.gets[0].complete([row('a')]);
    await context.waitUntil((it) => it.items.isNotEmpty);

    expect(context.value.pagingEnabled, false);
  });

  test('loading more appends the next page and never duplicates ids', () async {
    build();
    await delegate.untilGetCount(1);
    delegate.gets[0].complete([row('a'), row('b')]);
    await context.waitUntil((it) => it.items.length == 2);

    unawaited(context.value.computedState.refresh());
    await delegate.untilGetCount(2);
    expect(delegate.gets[1].offset, 2);

    // The backend repeats row 'b' - a row inserted before the offset shifts the
    // window - so only 'c' may be appended.
    delegate.gets[1].complete([row('b'), row('c')]);
    await context.waitUntil((it) => it.items.length == 3);

    expect(context.value.items.map((it) => it['id']), ['a', 'b', 'c']);
  });

  test('a page that resolves after a filter change is discarded and the refetch starts at offset 0', () async {
    build();
    await delegate.untilGetCount(1);
    delegate.gets[0].complete([row('a'), row('b')]);
    await context.waitUntil((it) => it.items.length == 2);

    unawaited(context.value.computedState.refresh());
    await delegate.untilGetCount(2);

    context.value.onFilterChanged('query', 'needle');
    expect(context.value.items, isEmpty);

    // The request that was in flight when the filter changed must not write its
    // rows into the emptied list, nor advance the offset past them.
    delegate.gets[1].complete([row('c'), row('d')]);
    await pumpEventQueue();
    expect(context.value.items, isEmpty);

    await delegate.untilGetCount(3);
    expect(delegate.gets[2].offset, 0);
    expect(delegate.gets[2].filter, const CmsFilterContains('name', 'needle'));
  });

  test('reloading while a page is in flight issues a fresh request', () async {
    build();
    await delegate.untilGetCount(1);

    unawaited(context.value.onReloadPressed());
    // Bounded: a reload that joined the in-flight operation instead of starting
    // its own would never issue a second request, and the bare wait would fail
    // as a whole-test timeout rather than as this assertion.
    await delegate.untilGetCount(2).timeout(const Duration(seconds: 1));

    expect(delegate.gets[1].offset, 0);
  });

  test('deleting a row removes it and steps the offset back', () async {
    build();
    await delegate.untilGetCount(1);
    delegate.gets[0].complete([row('a'), row('b')]);
    await context.waitUntil((it) => it.items.length == 2);

    confirmations.add(true);
    final deletion = context.value.onDeletePressed(row('a'), 0);
    await delegate.untilDeleteCount(1);
    delegate.completeDelete(0);

    expect(await deletion, true);
    expect(delegate.deletes.single['id'], 'a');
    expect(context.value.items.map((it) => it['id']), ['b']);

    unawaited(context.value.computedState.refresh());
    await delegate.untilGetCount(2);
    expect(delegate.gets[1].offset, 1);
  });

  test('a dismissed confirmation deletes nothing and reports that it did not run', () async {
    build();
    await delegate.untilGetCount(1);
    delegate.gets[0].complete([row('a')]);
    await context.waitUntil((it) => it.items.isNotEmpty);

    confirmations.add(null);
    expect(await context.value.onDeletePressed(row('a'), 0), false);
    expect(delegate.deletes, isEmpty);
    expect(context.value.items.length, 1);
  });

  test('a second delete tap while one is in flight is ignored', () async {
    build();
    await delegate.untilGetCount(1);
    delegate.gets[0].complete([row('a'), row('b')]);
    await context.waitUntil((it) => it.items.length == 2);

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

  test('a delete that resolves after a reload does not corrupt the offset', () async {
    build();
    await delegate.untilGetCount(1);
    delegate.gets[0].complete([row('a'), row('b')]);
    await context.waitUntil((it) => it.items.length == 2);

    confirmations.add(true);
    final deletion = context.value.onDeletePressed(row('a'), 0);
    await delegate.untilDeleteCount(1);

    // The reload empties the list while the delete request is still open, so the
    // captured index no longer points at row 'a' - or at anything.
    unawaited(context.value.onReloadPressed());
    await delegate.untilGetCount(2);

    delegate.completeDelete(0);
    await deletion;
    expect(context.value.items, isEmpty);

    delegate.gets[1].complete([row('c'), row('d')]);
    await context.waitUntil((it) => it.items.length == 2);
    unawaited(context.value.computedState.refresh());
    await delegate.untilGetCount(3);
    expect(delegate.gets[2].offset, 2);
  });

  test('deleting a row that is already gone leaves the offset at zero', () async {
    // A limit of 1 means the single row fills the page, so paging stays enabled
    // and the offset the deletions left behind is still observable through a
    // plain refresh - a reload would reset it to 0 and prove nothing.
    build(pagingLimit: 1);
    await delegate.untilGetCount(1);
    delegate.gets[0].complete([row('a')]);
    await context.waitUntil((it) => it.items.isNotEmpty);

    confirmations.addAll([true, true]);
    final first = context.value.onDeletePressed(row('a'), 0);
    await delegate.untilDeleteCount(1);
    delegate.completeDelete(0);
    await first;
    expect(context.value.items, isEmpty);

    // Same row again: it is no longer in the list, so the offset - already back
    // at 0 - must be left alone instead of being stepped to -1.
    final second = context.value.onDeletePressed(row('a'), 0);
    await delegate.untilDeleteCount(2);
    delegate.completeDelete(1);
    await second;

    unawaited(context.value.computedState.refresh());
    await delegate.untilGetCount(2);
    expect(delegate.gets[1].offset, 0);
  });
}
