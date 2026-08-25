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

  CmsTextEntry entry(String key, {bool sortInvertNulls = false}) => CmsTextEntry(
    key: key,
    modifier: CmsEntryModifier(sortable: true, sortInvertNulls: sortInvertNulls),
  );

  CmsFilterSearchEntry filterEntry(String entryKey, String filterKey) =>
      CmsFilterSearchEntry(filterKeys: [filterKey], entryKey: entryKey);

  SimpleHookContext<CmsTablePageState> build({
    List<CmsFilterEntry<dynamic>> filterEntries = const [],
    JsonMap initialFilterValues = const {},
  }) {
    return context = SimpleHookContext(
      () => useCmsTablePageState(
        delegate: delegate,
        params: CmsTableParams(initialFilterValues: initialFilterValues),
        navigator: StubNavigator(),
        entries: [entry('name'), entry('city')].lock,
        filterEntries: filterEntries.lock,
        confirmDelete: () async => false,
        pagingLimit: 2,
        managementSectionEntries: const [],
      ),
      provided: {BuildContext: StubBuildContext()},
    );
  }

  setUp(() => delegate = RecordingCmsDelegate());

  tearDown(() => context.dispose());

  group('sorting', () {
    test('the first tap on a column sorts ascending', () {
      build();

      context.value.onSortPressed(entry('name'));

      expect(context.value.currentSortingParams?.fieldKey, 'name');
      expect(context.value.currentSortingParams?.sortDesc, false);
    });

    test('a second tap on the same column flips to descending', () {
      build();

      context.value.onSortPressed(entry('name'));
      context.value.onSortPressed(entry('name'));

      expect(context.value.currentSortingParams?.sortDesc, true);
    });

    test('a third tap on the same column flips back to ascending', () {
      build();

      context.value.onSortPressed(entry('name'));
      context.value.onSortPressed(entry('name'));
      context.value.onSortPressed(entry('name'));

      expect(context.value.currentSortingParams?.sortDesc, false);
    });

    test('tapping a different column starts that column ascending', () {
      build();

      context.value.onSortPressed(entry('name'));
      context.value.onSortPressed(entry('name'));
      context.value.onSortPressed(entry('city'));

      expect(context.value.currentSortingParams?.fieldKey, 'city');
      expect(context.value.currentSortingParams?.sortDesc, false);
    });

    test('the sorting params carry the entry sortInvertNulls flag', () {
      build();

      context.value.onSortPressed(entry('name', sortInvertNulls: true));

      expect(context.value.currentSortingParams?.invertNulls, true);
    });

    test('sorting is refetched from offset 0 with the new params', () async {
      build();
      await delegate.untilGetCount(1);
      delegate.gets[0].complete([{'id': 'a'}, {'id': 'b'}]);
      await context.waitUntil((it) => it.items.length == 2);

      context.value.onSortPressed(entry('name'));
      await delegate.untilGetCount(2);

      expect(delegate.gets[1].offset, 0);
      expect(delegate.gets[1].sorting?.fieldKey, 'name');
    });
  });

  group('filters', () {
    test('no filter entries means no filter', () async {
      build();
      await delegate.untilGetCount(1);

      expect(delegate.gets.single.filter, const CmsFilterAll());
    });

    test('a filter without a value is left out', () async {
      build(filterEntries: [filterEntry('query', 'name')]);
      await delegate.untilGetCount(1);

      expect(delegate.gets.single.filter, const CmsFilterAll());
    });

    test('a single active filter is passed through without an AND wrapper', () async {
      build(filterEntries: [filterEntry('query', 'name')]);
      await delegate.untilGetCount(1);

      context.value.onFilterChanged('query', 'needle');
      await delegate.untilGetCount(2);

      expect(delegate.gets[1].filter, const CmsFilterContains('name', 'needle'));
    });

    test('two active filters are combined with AND', () async {
      build(filterEntries: [filterEntry('query', 'name'), filterEntry('cityQuery', 'city')]);
      await delegate.untilGetCount(1);

      context.value.onFilterChanged('query', 'needle');
      context.value.onFilterChanged('cityQuery', 'berlin');
      await delegate.untilGetCount(2);

      expect(delegate.gets[1].filter, const CmsFilterAnd([
        CmsFilterContains('name', 'needle'),
        CmsFilterContains('city', 'berlin'),
      ]));
    });

    test('clearing one of two filters drops it from the query', () async {
      build(filterEntries: [filterEntry('query', 'name'), filterEntry('cityQuery', 'city')]);
      await delegate.untilGetCount(1);

      context.value.onFilterChanged('query', 'needle');
      context.value.onFilterChanged('cityQuery', 'berlin');
      await delegate.untilGetCount(2);

      context.value.onFilterChanged('cityQuery', null);
      await delegate.untilGetCount(3);

      expect(delegate.gets[2].filter, const CmsFilterContains('name', 'needle'));
    });

    test('a dotted filter entryKey still reaches the delegate', () async {
      build(filterEntries: [filterEntry('meta.query', 'name')]);
      await delegate.untilGetCount(1);

      context.value.onFilterChanged('meta.query', 'needle');
      await delegate.untilGetCount(2);

      expect(context.value.filterValues, {
        'meta': {'query': 'needle'},
      });
      expect(delegate.gets[1].filter, const CmsFilterContains('name', 'needle'));
    });

    test('changing a nested filter does not mutate the initial filter values', () async {
      final initialFilterValues = <String, dynamic>{
        'meta': {'query': 'seed'},
      };
      build(filterEntries: [filterEntry('meta.query', 'name')], initialFilterValues: initialFilterValues);
      await delegate.untilGetCount(1);

      context.value.onFilterChanged('meta.query', 'needle');
      await delegate.untilGetCount(2);

      expect(initialFilterValues, {
        'meta': {'query': 'seed'},
      });
    });
  });
}
