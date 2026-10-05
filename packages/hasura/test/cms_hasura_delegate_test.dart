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
  Future<List<JsonMap>> insert(
    GraphQLClient client, {
    required CmsHasuraTable table,
    required List<JsonMap> objects,
    CmsGraphQLFields fields = const {},
  }) async => [];

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

  // Fails any request the recorder does not answer, instead of sending it.
  final client = GraphQLClient(
    link: Link.function((request, [forward]) => Stream.error(UnsupportedError('the recorder must answer'))),
    cache: GraphQLCache(),
  );

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

    test('archives a dotted field on a copy, passing the untouched row as the old value', () async {
      final row = <String, dynamic>{
        'id': 7,
        'meta': {'archived': false},
      };
      final subject = delegate(archivedFilter: const CmsFilterNotEquals('meta.archived', true));

      await subject.delete(row);

      expect(subject.lastUpdate.$1, {
        'id': 7,
        'meta': {'archived': true},
      });
      expect(subject.lastUpdate.$2, {
        'id': 7,
        'meta': {'archived': false},
      });
      expect(row, {
        'id': 7,
        'meta': {'archived': false},
      });
    });
  });

  group('a failing backend', () {
    Future<void> loading() => delegate().get(paging: CmsFunctionsPagingParams(offset: 0, limit: 10));

    test('surfaces a raw server error from a custom service as a message naming the operation and the table', () async {
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

    test('reports an insert that returned no row', () async {
      await expectLater(
        delegate().create({'name': 'ann'}),
        throwsA(
          isA<CmsDelegateException>().having((it) => it.message, 'message', 'Could not create "user": No element'),
        ),
      );
    });

    test('lets a programmer error through unwrapped, since no operator can act on it', () async {
      service.queryFailure = ArgumentError('fields must not be empty');

      await expectLater(loading(), throwsArgumentError);
    });
  });
}
