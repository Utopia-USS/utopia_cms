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
  late SimpleHookContext<CmsTablePageState> context;

  JsonMap row(String id) => {'id': id, 'name': 'name-$id'};

  SimpleHookContext<CmsTablePageState> build() {
    return context = SimpleHookContext(
      () => useCmsTablePageState(
        delegate: delegate,
        params: CmsTableParams.defaultParams,
        navigator: StubNavigator(),
        entries: IList(),
        filterEntries: [CmsFilterSearchEntry(filterKeys: const ['name'], entryKey: 'query')].lock,
        confirmDelete: () async => false,
        pagingLimit: 2,
        managementSectionEntries: const [],
      ),
      provided: {BuildContext: StubBuildContext()},
    );
  }

  setUp(() => delegate = RecordingCmsDelegate());

  tearDown(() {
    if (context.mounted) context.dispose();
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
    expect(delegate.gets[0].limit, 2);
    delegate.gets[0].complete([row('a'), row('b')]);
    await context.waitUntil((it) => it.items.length == 2);

    unawaited(context.value.computedState.refresh());
    await delegate.untilGetCount(2);
    expect(delegate.gets[1].offset, 2);

    // The backend repeats row 'b' - a row inserted before the offset shifts the
    // window - so only 'c' may be appended.
    delegate.gets[1].complete([row('b'), row('c')]);
    await pumpEventQueue();

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
}
