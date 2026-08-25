import 'package:flutter_test/flutter_test.dart';
import 'package:gql/ast.dart';
import 'package:gql/language.dart';
import 'package:graphql/client.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_graphql/utopia_cms_graphql.dart';
import 'package:utopia_cms_hasura/utopia_cms_hasura.dart';

typedef _Call = ({String name, Map<String, ValueNode> arguments, CmsGraphQLFields? fields});

/// Records the operation the hasura service asks for, and answers with [response].
class _GraphQLRecorder extends CmsGraphQLService {
  final calls = <_Call>[];

  Object? response;

  _Call get last => calls.last;

  @override
  Future<Object?> query(
    GraphQLClient client, {
    required String name,
    required CmsGraphQLFields fields,
    Map<String, String> variableTypes = const {},
    Map<String, ValueNode> arguments = const {},
    JsonMap variables = const {},
  }) async => _record((name: name, arguments: arguments, fields: fields));

  @override
  Future<Object?> mutate(
    GraphQLClient client, {
    required String name,
    CmsGraphQLFields? fields,
    Map<String, String> variableTypes = const {},
    Map<String, ValueNode> arguments = const {},
    JsonMap variables = const {},
  }) async => _record((name: name, arguments: arguments, fields: fields));

  Object? _record(_Call call) {
    calls.add(call);
    return response;
  }
}

void main() {
  const table = CmsHasuraDataTable('user_profile');

  final client = GraphQLClient(link: HttpLink('http://localhost'), cache: GraphQLCache());

  late _GraphQLRecorder graphQL;

  setUp(() => graphQL = _GraphQLRecorder());

  CmsHasuraService service() => CmsHasuraService(graphQL, namingConvention: CmsHasuraNamingConvention.hasura);

  /// The printed argument [name] of the last call, asserted to still parse as
  /// part of a document - printing is only correct if a server can read it back.
  String argument(String name) {
    final printed = printNode(graphQL.last.arguments[name]!);
    expect(
      () => parseString('query operation { result($name: $printed) }'),
      returnsNormally,
      reason: 'printed an unparseable argument: $printed',
    );
    return printed;
  }

  group('query', () {
    setUp(() => graphQL.response = <JsonMap>[]);

    test('names the root field through the naming convention, which is a no-op for snake', () async {
      await service().query(client, table: table, fields: const {});

      expect(graphQL.last.name, 'user_profile');
    });

    test('sends limit and offset from paging', () async {
      await service().query(
        client,
        table: table,
        fields: const {},
        paging: CmsFunctionsPagingParams(offset: 20, limit: 10),
      );

      expect(argument('limit'), '10');
      expect(argument('offset'), '20');
    });

    test('sends a null limit, which Hasura reads as unlimited', () async {
      await service().query(
        client,
        table: table,
        fields: const {},
        paging: CmsFunctionsPagingParams(offset: 0, limit: null),
      );

      expect(argument('limit'), 'null');
    });

    test('orders descending, and desc_nulls_last when nulls are inverted', () async {
      await service().query(
        client,
        table: table,
        fields: const {},
        sorting: const CmsFunctionsSortingParams(fieldKey: 'name', sortDesc: true),
      );
      expect(argument('order_by'), '{name: desc}');

      await service().query(
        client,
        table: table,
        fields: const {},
        sorting: const CmsFunctionsSortingParams(fieldKey: 'name', sortDesc: true, invertNulls: true),
      );
      expect(argument('order_by'), '{name: desc_nulls_last}');
    });
  });

  group('insert', () {
    test('wraps the requested fields in returning and unwraps the response', () async {
      graphQL.response = <String, dynamic>{
        'returning': [
          {'id': 1},
        ],
      };

      final result = await service().insertOne(
        client,
        table: table,
        object: {'name': 'ann'},
        fields: const {CmsGraphQLField('id')},
      );

      expect(graphQL.last.name, 'insert_user_profile');
      expect(graphQL.last.fields!.single.key, 'returning');
      expect(graphQL.last.fields!.single.fields!.single.key, 'id');
      expect(argument('objects'), '[{name: "ann"}]');
      expect(result, {'id': 1});
    });
  });

  group('updateById', () {
    setUp(() => graphQL.response = <String, dynamic>{'id': 1});

    test('addresses the row through pk_columns', () async {
      await service().updateById(client, table: table, object: {'id': 1, 'name': 'ann'});

      expect(graphQL.last.name, 'update_user_profile_by_pk');
      expect(argument('pk_columns'), '{id: 1}');
    });

    test('keeps the primary key out of _set', () async {
      await service().updateById(client, table: table, object: {'id': 1, 'name': 'ann'});

      expect(argument('_set'), '{name: "ann"}');
    });

    test('sends nothing when only the primary key was given, since _set may not be empty', () async {
      final result = await service().updateById(client, table: table, object: {'id': 1});

      expect(graphQL.calls, isEmpty);
      expect(result, {'id': 1});
    });

    test('leaves the object it was given untouched', () async {
      final object = <String, dynamic>{'id': 1, 'name': 'ann'};

      await service().updateById(client, table: table, object: object);

      expect(object, {'id': 1, 'name': 'ann'});
    });
  });

  test('deleteByPk names the mutation after the table', () async {
    graphQL.response = <String, dynamic>{'id': 1};

    await service().deleteByPk(client, table: table, keys: {'id': 1});

    expect(graphQL.last.name, 'delete_user_profile_by_pk');
    expect(argument('id'), '1');
  });
}
