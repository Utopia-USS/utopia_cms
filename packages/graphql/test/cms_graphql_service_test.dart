import 'package:flutter_test/flutter_test.dart';
import 'package:gql/ast.dart';
import 'package:gql/language.dart';
import 'package:graphql/client.dart';
import 'package:utopia_cms_graphql/utopia_cms_graphql.dart';

/// Records the document the service builds and answers with [response].
class _RecorderLink extends Link {
  final List<DocumentNode> documents = [];

  Response response = const Response(data: {'result': null}, response: {});

  String get lastDocument => printNode(documents.last).trim();

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    documents.add(request.operation.document);
    return Stream.value(response);
  }
}

void main() {
  const service = CmsGraphQLService();

  late _RecorderLink link;
  late GraphQLClient client;

  setUp(() {
    link = _RecorderLink();
    client = GraphQLClient(
      link: link,
      cache: GraphQLCache(),
      defaultPolicies: DefaultPolicies(
        query: Policies(fetch: FetchPolicy.noCache),
        mutate: Policies(fetch: FetchPolicy.noCache),
      ),
    );
  });

  group('document', () {
    test('aliases the root field to result', () async {
      await service.query(client, name: 'users', fields: const {CmsGraphQLField('id')});

      expect(link.lastDocument, 'query operation {\n  result: users {\n    id\n  }\n}');
    });

    test('falls back to __typename for an empty field set', () async {
      await service.query(client, name: 'users', fields: const {});

      expect(link.lastDocument, contains('__typename'));
    });

    test('prints nested selection sets', () async {
      await service.query(
        client,
        name: 'users',
        fields: const {
          CmsGraphQLField('author', {CmsGraphQLField('name')}),
        },
      );

      expect(link.lastDocument, contains('author {\n      name\n    }'));
    });

    test('prints arguments from their value nodes', () async {
      await service.query(
        client,
        name: 'users',
        fields: const {CmsGraphQLField('id')},
        arguments: {
          'limit': 10.toValueNodeUnsafe(),
          'where': {'id': 1}.toValueNodeUnsafe(),
        },
      );

      expect(link.lastDocument, contains('users(limit: 10, where: {id: 1})'));
    });

    test('omits the selection set when a mutation asks for no fields', () async {
      await service.mutate(client, name: 'deleteUser', arguments: {'id': 1.toValueNodeUnsafe()});

      expect(link.lastDocument, 'mutation operation {\n  result: deleteUser(id: 1)\n}');
    });
  });

  group('result', () {
    test('unwraps the aliased root field', () async {
      link.response = const Response(
        data: {
          'result': [
            {'id': 1},
          ],
        },
        response: {},
      );

      final result = await service.query(client, name: 'users', fields: const {CmsGraphQLField('id')});

      expect(result, [
        {'id': 1},
      ]);
    });

    test('rethrows the operation exception when the response carries errors', () async {
      link.response = const Response(
        errors: [GraphQLError(message: 'permission denied')],
        response: {},
      );

      expect(
        () => service.query(client, name: 'users', fields: const {CmsGraphQLField('id')}),
        throwsA(isA<OperationException>()),
      );
    });

    test('reports a described failure when there is neither data nor errors', () async {
      link.response = const Response(response: {});

      expect(
        () => service.query(client, name: 'users', fields: const {CmsGraphQLField('id')}),
        throwsA(isA<StateError>().having((it) => it.message, 'message', contains('users'))),
      );
    });
  });
}
