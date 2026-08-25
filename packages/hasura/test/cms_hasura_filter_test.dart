import 'package:flutter_test/flutter_test.dart';
import 'package:gql/language.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_graphql/utopia_cms_graphql.dart';
import 'package:utopia_cms_hasura/utopia_cms_hasura.dart';

void main() {
  const service = CmsHasuraService(CmsGraphQLService(), namingConvention: CmsHasuraNamingConvention.hasura);

  /// The printed `where` argument, asserted to still parse as part of a document
  /// - printing is only correct if a server can read it back.
  String where(CmsFilter filter) {
    final printed = printNode(service.buildFilter(filter));
    expect(
      () => parseString('query operation { result(where: $printed) }'),
      returnsNormally,
      reason: 'printed an unparseable filter: $printed',
    );
    return printed;
  }

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

    // The escaping happens twice on purpose: `\%` is the postgres LIKE escape,
    // and the GraphQL string form doubles that backslash so the document parses
    // and the server ends up with `\%` again.
    test('escapes the like wildcards in the search term', () {
      expect(where(const CmsFilter.containsString('name', '50%_off')), r'{name: {_ilike: "%50\\%\\_off%"}}');
    });

    test('escapes a double quote so it cannot end the GraphQL string', () {
      expect(where(const CmsFilter.containsString('name', 'say "hi"')), r'{name: {_ilike: "%say \"hi\"%"}}');
    });

    test('escapes a backslash from the search term on top of the like escape', () {
      expect(where(const CmsFilter.containsString('name', r'a\b')), r'{name: {_ilike: "%a\\\\b%"}}');
    });
  });
}
