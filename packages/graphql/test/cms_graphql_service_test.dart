import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gql/ast.dart';
import 'package:gql/language.dart';
import 'package:graphql/client.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_graphql/utopia_cms_graphql.dart';

/// Records the document the service builds and answers with [response], or fails
/// the request with [failure] the way the transport would.
class _RecorderLink extends Link {
  final List<DocumentNode> documents = [];

  Response response = const Response(data: {'result': null}, response: {});
  Object? failure;

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    documents.add(request.operation.document);
    final failure = this.failure;
    return failure != null ? Stream.error(failure) : Stream.value(response);
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

  /// The document the service last sent, asserted to still parse - printing is
  /// only correct if the server can read the result back.
  String lastDocument() {
    final printed = printNode(link.documents.last);
    expect(() => parseString(printed), returnsNormally, reason: 'printed an unparseable document: $printed');
    return printed.trim();
  }

  group('document', () {
    test('aliases the root field to result', () async {
      await service.query(client, name: 'users', fields: const {CmsGraphQLField('id')});

      expect(lastDocument(), 'query operation {\n  result: users {\n    id\n  }\n}');
    });

    test('falls back to __typename for an empty field set', () async {
      await service.query(client, name: 'users', fields: const {});

      expect(lastDocument(), contains('__typename'));
    });

    test('prints nested selection sets', () async {
      await service.query(
        client,
        name: 'users',
        fields: const {
          CmsGraphQLField('author', {CmsGraphQLField('name')}),
        },
      );

      expect(lastDocument(), contains('author {\n      name\n    }'));
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

      expect(lastDocument(), contains('users(limit: 10, where: {id: 1})'));
    });

    test('escapes quotes, backslashes and control characters in string arguments', () async {
      await service.query(
        client,
        name: 'users',
        fields: const {CmsGraphQLField('id')},
        arguments: {'where': 'say "hi"\\ok\nbye\t.'.toValueNodeUnsafe()},
      );

      expect(lastDocument(), contains(r'users(where: "say \"hi\"\\ok\nbye\t.")'));
    });

    test('omits the selection set when a mutation asks for no fields', () async {
      await service.mutate(client, name: 'deleteUser', arguments: {'id': 1.toValueNodeUnsafe()});

      expect(lastDocument(), 'mutation operation {\n  result: deleteUser(id: 1)\n}');
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

    test('server errors surface as a CmsDelegateException naming the operation', () async {
      link.response = const Response(
        errors: [GraphQLError(message: 'permission denied')],
        response: {},
      );

      expect(
        () => service.query(client, name: 'users', fields: const {CmsGraphQLField('id')}),
        throwsA(
          isA<CmsDelegateException>().having(
            (it) => it.message,
            'message',
            'Failed to run GraphQL query "users": permission denied',
          ),
        ),
      );
    });

    test('a mutation names itself as a mutation', () async {
      link.response = const Response(
        errors: [GraphQLError(message: 'permission denied')],
        response: {},
      );

      expect(
        () => service.mutate(client, name: 'deleteUser'),
        throwsA(
          isA<CmsDelegateException>().having(
            (it) => it.message,
            'message',
            startsWith('Failed to run GraphQL mutation "deleteUser": '),
          ),
        ),
      );
    });

    test('a link failure is described by its cause, without the stack trace its own toString carries', () async {
      link.failure = const ServerException(originalException: SocketException('Connection refused'), statusCode: 503);

      expect(
        () => service.query(client, name: 'users', fields: const {CmsGraphQLField('id')}),
        throwsA(
          isA<CmsDelegateException>().having(
            (it) => it.message,
            'message',
            allOf(contains('Connection refused'), isNot(contains('ServerException('))),
          ),
        ),
      );
    });

    test('reports a described failure when there is neither data nor errors', () async {
      link.response = const Response(response: {});

      expect(
        () => service.query(client, name: 'users', fields: const {CmsGraphQLField('id')}),
        throwsA(
          isA<CmsDelegateException>().having(
            (it) => it.message,
            'message',
            allOf(startsWith('Failed to run GraphQL query "users": '), contains('no data and no errors')),
          ),
        ),
      );
    });

    test('an exception that is not a GraphQL failure keeps its type', () async {
      final throwing = _ThrowingClient(
        ArgumentError('asked for a malformed operation'),
        link: link,
        cache: GraphQLCache(),
      );

      expect(
        () => service.query(throwing, name: 'users', fields: const {CmsGraphQLField('id')}),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}

/// Fails every operation with [failure], the way a caller error would before the
/// request ever leaves the client.
class _ThrowingClient extends GraphQLClient {
  final Object failure;

  _ThrowingClient(this.failure, {required super.link, required super.cache});

  @override
  Future<QueryResult<TParsed>> query<TParsed>(QueryOptions<TParsed> options) => throw failure;
}
