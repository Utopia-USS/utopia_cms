import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_graphql/utopia_cms_graphql.dart';
import 'package:utopia_cms_hasura/utopia_cms_hasura.dart';

/// Records what the delegate asks the service for, and answers with nothing.
class _ServiceRecorder extends CmsHasuraService {
  CmsFilter? queriedFilter;
  JsonMap? deletedKeys;

  /// Thrown by [query] instead of answering, standing in for the backend.
  Object? queryFailure;

  _ServiceRecorder() : super(const CmsGraphQLService(), namingConvention: CmsHasuraNamingConvention.hasura);

  @override
  Future<List<JsonMap>> query(
    GraphQLClient client, {
    required CmsHasuraTable table,
    required CmsGraphQLFields fields,
    CmsFunctionsPagingParams? paging,
    CmsFilter filter = const CmsFilter.all(),
    CmsFunctionsSortingParams? sorting,
  }) async {
    if (queryFailure != null) throw queryFailure!;
    queriedFilter = filter;
    return [];
  }

  @override
  Future<JsonMap> deleteByPk(
    GraphQLClient client, {
    required CmsHasuraTable table,
    required JsonMap keys,
    CmsGraphQLFields fields = const {},
  }) async {
    deletedKeys = keys;
    return {};
  }
}

/// A delegate that records the update `_archive` performs, the way a business
/// logic subclass would see it.
class _RecordingDelegate extends CmsHasuraDelegate {
  final updates = <(JsonMap, JsonMap)>[];

  _RecordingDelegate(super.hasuraService, {required super.client, required super.table, super.archivedFilter});

  (JsonMap, JsonMap) get lastUpdate => updates.last;

  @override
  Future<JsonMap> update(JsonMap value, JsonMap oldValue) async {
    updates.add((value, oldValue));
    return value;
  }
}

void main() {
  const table = CmsHasuraDataTable('user');
  const archivedFilter = CmsFilterNotEquals('archived', true);

  final client = GraphQLClient(link: HttpLink('http://localhost'), cache: GraphQLCache());

  late _ServiceRecorder service;

  setUp(() => service = _ServiceRecorder());

  _RecordingDelegate delegate({CmsFilterNotEquals? archivedFilter}) =>
      _RecordingDelegate(service, client: client, table: table, archivedFilter: archivedFilter);

  test('get ands the archived filter into the caller filter', () async {
    await delegate(
      archivedFilter: archivedFilter,
    ).get(filter: const CmsFilter.equals('role', 'admin'), paging: CmsFunctionsPagingParams(offset: 0, limit: 10));

    expect(service.queriedFilter, const CmsFilter.and([archivedFilter, CmsFilter.equals('role', 'admin')]));
  });

  test('delete hard-deletes by primary key when there is no archived filter', () async {
    await delegate().delete({'id': 7});

    expect(service.deletedKeys, {'id': 7});
  });

  group('delete with an archived filter', () {
    test('updates the archived flag instead of deleting', () async {
      final subject = delegate(archivedFilter: archivedFilter);

      await subject.delete({'id': 7, 'archived': false});

      expect(service.deletedKeys, isNull);
      expect(subject.lastUpdate.$1, {'id': 7, 'archived': true});
    });

    test('passes the row as it was before archiving as the old value', () async {
      final subject = delegate(archivedFilter: archivedFilter);

      await subject.delete({'id': 7, 'archived': false});

      expect(subject.lastUpdate.$2, {'id': 7, 'archived': false});
    });

    test('leaves the row the table passed in untouched', () async {
      final row = <String, dynamic>{'id': 7, 'archived': false};

      await delegate(archivedFilter: archivedFilter).delete(row);

      expect(row, {'id': 7, 'archived': false});
    });

    test('leaves a nested map of the row untouched for a dotted archived field', () async {
      final row = <String, dynamic>{
        'id': 7,
        'meta': {'archived': false},
      };

      await delegate(archivedFilter: const CmsFilterNotEquals('meta.archived', true)).delete(row);

      expect(row, {
        'id': 7,
        'meta': {'archived': false},
      });
    });
  });

  group('a failing backend', () {
    Future<void> loading() => delegate().get(paging: CmsFunctionsPagingParams(offset: 0, limit: 10));

    test('surfaces a server error as a message naming the operation and the table', () async {
      service.queryFailure = OperationException(
        graphqlErrors: const [GraphQLError(message: 'permission denied for table "user"')],
      );

      await expectLater(
        loading(),
        throwsA(
          isA<CmsDelegateException>().having(
            (it) => it.message,
            'message',
            'Could not load "user": permission denied for table "user"',
          ),
        ),
      );
    });

    test('surfaces a response that carries neither data nor errors the same way', () async {
      service.queryFailure = StateError('GraphQL operation "user" returned no data and no errors.');

      await expectLater(
        loading(),
        throwsA(
          isA<CmsDelegateException>().having(
            (it) => it.message,
            'message',
            'Could not load "user": GraphQL operation "user" returned no data and no errors.',
          ),
        ),
      );
    });

    test('lets a programmer error through unwrapped, since no operator can act on it', () async {
      service.queryFailure = ArgumentError('fields must not be empty');

      await expectLater(loading(), throwsArgumentError);
    });
  });
}
