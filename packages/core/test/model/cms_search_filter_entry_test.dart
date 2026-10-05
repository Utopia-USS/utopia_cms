import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms/utopia_cms.dart';

void main() {
  CmsFilterSearchEntry entryOf({List<String> filterKeys = const ['name']}) =>
      CmsFilterSearchEntry(filterKeys: filterKeys, entryKey: 'search');

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
}
