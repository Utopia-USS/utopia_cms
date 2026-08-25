import 'package:flutter_test/flutter_test.dart';
import 'package:gql/language.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_graphql/utopia_cms_graphql.dart';
import 'package:utopia_cms_hasura/utopia_cms_hasura.dart';

void main() {
  const service = CmsHasuraService(CmsGraphQLService(), namingConvention: CmsHasuraNamingConvention.hasura);

  String where(CmsFilter filter) => printNode(service.buildFilter(filter));

  test('all renders an empty object, which Hasura reads as no condition', () {
    expect(where(const CmsFilter.all()), '{}');
  });

  test('equals nests a dotted path into nested objects', () {
    expect(where(const CmsFilter.equals('author.name', 'ann')), '{author: {name: {_eq: "ann"}}}');
  });

  test('notEquals, greaterOrEq and lesserOrEq map to _neq, _gte and _lte', () {
    expect(where(const CmsFilter.notEquals('age', 30)), '{age: {_neq: 30}}');
    expect(where(const CmsFilter.greaterOrEq('age', 30)), '{age: {_gte: 30}}');
    expect(where(const CmsFilter.lesserOrEq('age', 30)), '{age: {_lte: 30}}');
  });

  test('inList maps to _in', () {
    expect(where(const CmsFilter.inList('id', [1, 2])), '{id: {_in: [1, 2]}}');
  });

  test('and, or and not map to _and, _or and _not', () {
    const a = CmsFilter.equals('a', 1);
    const b = CmsFilter.equals('b', 2);

    expect(where(const CmsFilter.and([a, b])), '{_and: [{a: {_eq: 1}}, {b: {_eq: 2}}]}');
    expect(where(const CmsFilter.or([a, b])), '{_or: [{a: {_eq: 1}}, {b: {_eq: 2}}]}');
    expect(where(const CmsFilter.not(a)), '{_not: {a: {_eq: 1}}}');
  });

  group('containsString', () {
    test('wraps the term in percents and uses _ilike, or _like when case-sensitive', () {
      expect(where(const CmsFilter.containsString('name', 'ann')), '{name: {_ilike: "%ann%"}}');
      expect(where(const CmsFilter.containsString('name', 'ann', caseSensitive: true)), '{name: {_like: "%ann%"}}');
    });

    test('escapes the like wildcards in the search term', () {
      expect(where(const CmsFilter.containsString('name', '50%_off')), r'{name: {_ilike: "%50\%\_off%"}}');
    });
  });
}
