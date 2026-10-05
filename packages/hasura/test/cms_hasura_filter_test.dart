import 'package:flutter_test/flutter_test.dart';
import 'package:gql/ast.dart';
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

    test('escapes the like wildcards and the escape character, so the term matches literally', () {
      /// The `_ilike` pattern a server reads back from the filter searching for [term].
      String receivedPattern(String term) {
        final printed = printNode(service.buildFilter(CmsFilter.containsString('name', term)));
        final document = parseString('{ f(where: $printed) }');
        final field = (document.definitions.single as OperationDefinitionNode).selectionSet.selections.single;
        final name = ((field as FieldNode).arguments.single.value as ObjectValueNode).fields.single.value;
        return ((name as ObjectValueNode).fields.single.value as StringValueNode).value;
      }

      expect(receivedPattern('50%_off'), r'%50\%\_off%');
      expect(receivedPattern(r'a\b'), r'%a\\b%');
    });
  });
}
