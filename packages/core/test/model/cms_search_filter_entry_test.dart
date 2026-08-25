import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms/utopia_cms.dart';

void main() {
  CmsFilterSearchEntry entryOf({List<String> filterKeys = const ['name'], String entryKey = 'search'}) =>
      CmsFilterSearchEntry(filterKeys: filterKeys, entryKey: entryKey);

  test('returns all when the search value is absent', () {
    expect(entryOf().filterFromValues({}), const CmsFilterAll());
  });

  test('returns all when the search value is empty', () {
    expect(entryOf().filterFromValues({'search': ''}), const CmsFilterAll());
  });

  test('returns all when there are no filter keys', () {
    expect(entryOf(filterKeys: const []).filterFromValues({'search': 'ann'}), const CmsFilterAll());
  });

  test('builds a single contains filter for one key', () {
    expect(entryOf().filterFromValues({'search': 'ann'}), const CmsFilterContains('name', 'ann'));
  });

  test('ors one contains filter per filter key', () {
    expect(
      entryOf(filterKeys: const ['name', 'email']).filterFromValues({'search': 'ann'}),
      const CmsFilterOr([CmsFilterContains('name', 'ann'), CmsFilterContains('email', 'ann')]),
    );
  });

  test('reads a dotted entry key', () {
    expect(
      entryOf(entryKey: 'filters.search').filterFromValues({
        'filters': {'search': 'ann'},
      }),
      const CmsFilterContains('name', 'ann'),
    );
  });

  test('contains filters default to case-insensitive', () {
    final filter = entryOf().filterFromValues({'search': 'ann'}) as CmsFilterContains;
    expect(filter.caseSensitive, isFalse);
  });
}
