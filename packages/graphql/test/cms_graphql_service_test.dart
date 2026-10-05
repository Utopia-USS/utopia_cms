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
    // The policies CmsGraphQLClientService.createClient ships with.
    client = GraphQLClient(
      link: link,
      cache: GraphQLCache(),
      defaultPolicies: DefaultPolicies(query: Policies(fetch: FetchPolicy.noCache)),
    );
  });

  /// Compares the document the service last sent with [expected], both printed
  /// by gql, so only their structure counts and not how [expected] is laid out.
  void expectSent(String expected) => expect(printNode(link.documents.last), printNode(parseString(expected)));

  Matcher throwsDelegateException(Object message) =>
      throwsA(isA<CmsDelegateException>().having((it) => it.message, 'message', message));

  group('document', () {
    test('aliases the root field to result', () async {
      await service.query(client, name: 'users', fields: const {CmsGraphQLField('id')});

      expectSent('query operation { result: users { id } }');
    });

    test('falls back to __typename for an empty field set', () async {
      await service.query(client, name: 'users', fields: const {});

      expectSent('query operation { result: users { __typename } }');
    });

    test('prints nested selection sets', () async {
      await service.query(
        client,
        name: 'users',
        fields: const {
          CmsGraphQLField('author', {CmsGraphQLField('name')}),
        },
      );

      expectSent('query operation { result: users { author { name } } }');
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

      expectSent('query operation { result: users(limit: 10, where: {id: 1}) { id } }');
    });

    test('omits the selection set when a mutation asks for no fields', () async {
      await service.mutate(client, name: 'deleteUser', arguments: {'id': 1.toValueNodeUnsafe()});

      expectSent('mutation operation { result: deleteUser(id: 1) }');
    });
  });

  test('a string value reads back on the server as the string it was built from', () {
    /// [value] printed inside a document and parsed back the way a server reads it.
    String readBack(StringValueNode value) {
      final document = parseString('{ f(a: ${printNode(value)}) }');
      final field = (document.definitions.single as OperationDefinitionNode).selectionSet.selections.single;
      return ((field as FieldNode).arguments.single.value as StringValueNode).value;
    }

    const values = ['say "hi"', r'C:\temp', 'x\r\ny', 'a\tb', '\b\f', '\x01\x1f', 'zażółć 🙂'];
    for (final value in values) {
      expect(readBack(value.toValueNode()), value, reason: 'printed as ${printNode(value.toValueNode())}');
    }
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

      await expectLater(
        service.query(client, name: 'users', fields: const {CmsGraphQLField('id')}),
        throwsDelegateException('Failed to run GraphQL query "users": permission denied'),
      );
      await expectLater(
        service.mutate(client, name: 'deleteUser'),
        throwsDelegateException('Failed to run GraphQL mutation "deleteUser": permission denied'),
      );
    });

    test('a link failure is described by its cause, without the stack trace its own toString carries', () async {
      link.failure = ServerException(originalException: Exception('Connection refused'), statusCode: 503);

      await expectLater(
        service.query(client, name: 'users', fields: const {CmsGraphQLField('id')}),
        throwsDelegateException(allOf(contains('Connection refused'), isNot(contains('ServerException(')))),
      );
    });

    test('reports a described failure when there is neither data nor errors', () async {
      link.response = const Response(response: {});

      await expectLater(
        service.query(client, name: 'users', fields: const {CmsGraphQLField('id')}),
        throwsDelegateException(
          allOf(startsWith('Failed to run GraphQL query "users": '), contains('no data and no errors')),
        ),
      );
    });

    test('an exception that is not a GraphQL failure keeps its type', () async {
      final throwing = _ThrowingClient(
        ArgumentError('asked for a malformed operation'),
        link: link,
        cache: GraphQLCache(),
      );

      await expectLater(
        service.query(throwing, name: 'users', fields: const {CmsGraphQLField('id')}),
        throwsArgumentError,
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
