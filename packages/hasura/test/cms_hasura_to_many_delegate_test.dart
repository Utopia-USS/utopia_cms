import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_graphql/utopia_cms_graphql.dart';
import 'package:utopia_cms_hasura/utopia_cms_hasura.dart';

/// Records what the delegate asks the service for, and answers with nothing.
class _ServiceRecorder extends CmsHasuraService {
  CmsHasuraTable? queriedTable;
  CmsFilter? queriedFilter;
  List<JsonMap>? insertedObjects;
  CmsFilter? deletedFilter;
  final updatedObjects = <JsonMap>[];

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
    queriedTable = table;
    queriedFilter = filter;
    return [];
  }

  @override
  Future<List<JsonMap>> insert(
    GraphQLClient client, {
    required CmsHasuraTable table,
    required List<JsonMap> objects,
    CmsGraphQLFields fields = const {},
  }) async {
    insertedObjects = objects;
    return [];
  }

  @override
  Future<List<JsonMap>> delete(
    GraphQLClient client, {
    required CmsHasuraTable table,
    required CmsFilter filter,
    CmsGraphQLFields fields = const {},
  }) async {
    deletedFilter = filter;
    return [];
  }

  @override
  Future<JsonMap> updateById(
    GraphQLClient client, {
    required CmsHasuraDataTable table,
    required JsonMap object,
    CmsGraphQLFields fields = const {},
  }) async {
    updatedObjects.add(object);
    return {};
  }
}

void main() {
  const associationTable = CmsHasuraAssociationTable(
    'user_role',
    originTable: CmsHasuraDataTable('user'),
    foreignTable: CmsHasuraDataTable('role'),
    originKey: 'user_id',
    foreignKey: 'role_id',
  );

  // Fails any request the recorder does not answer, instead of sending it.
  final client = GraphQLClient(
    link: Link.function((request, [forward]) => Stream.error(UnsupportedError('the recorder must answer'))),
    cache: GraphQLCache(),
  );

  late _ServiceRecorder service;

  setUp(() => service = _ServiceRecorder());

  CmsHasuraManyToManyDelegate delegate({String? relationshipName, CmsFilterNotEquals? archivedFilter}) =>
      CmsHasuraManyToManyDelegate(
        service,
        client: client,
        associationTable: associationTable,
        foreignFields: const {},
        relationshipName: relationshipName,
        archivedFilter: archivedFilter,
      );

  group('get', () {
    test('queries the foreign table, not the association table', () async {
      await delegate().get(originId: 1);

      expect(service.queriedTable, same(associationTable.foreignTable));
    });

    test('walks the relationship named after the origin table by default', () async {
      await delegate().get(originId: 1);

      expect(service.queriedFilter, const CmsFilter.and([CmsFilter.all(), CmsFilter.equals('user.user_id', 1)]));
    });

    test('walks the given relationship instead when one is named', () async {
      await delegate(relationshipName: 'user_roles').get(originId: 1);

      expect(service.queriedFilter, const CmsFilter.and([CmsFilter.all(), CmsFilter.equals('user_roles.user_id', 1)]));
    });

    test('keeps the caller filter and the archived filter alongside the relationship', () async {
      await delegate(
        relationshipName: 'user_roles',
        archivedFilter: const CmsFilterNotEquals('archived', true),
      ).get(originId: 1, filter: const CmsFilter.containsString('name', 'ad'));

      expect(
        service.queriedFilter,
        const CmsFilter.and([
          CmsFilterNotEquals('archived', true),
          CmsFilter.containsString('name', 'ad'),
          CmsFilter.equals('user_roles.user_id', 1),
        ]),
      );
    });

    test('leaves the relationship out entirely when there is no origin', () async {
      await delegate(relationshipName: 'user_roles').get();

      expect(service.queriedFilter, const CmsFilter.all());
    });
  });

  group('update', () {
    test('inserts the added pairs into the association table', () async {
      await delegate(
        relationshipName: 'user_roles',
      ).update(originId: 1, addedForeignIds: {7}.lock, removedForeignIds: const ISetConst({}));

      expect(service.insertedObjects, [
        {'user_id': 1, 'role_id': 7},
      ]);
    });

    test('deletes the removed pairs by both keys, never through the relationship', () async {
      await delegate(
        relationshipName: 'user_roles',
      ).update(originId: 1, addedForeignIds: const ISetConst({}), removedForeignIds: {7}.lock);

      expect(
        service.deletedFilter,
        const CmsFilter.and([
          CmsFilter.equals('user_id', 1),
          CmsFilter.inList('role_id', [7]),
        ]),
      );
    });
  });

  test('one-to-many update points added rows at the origin and unlinks removed ones', () async {
    await CmsHasuraOneToManyDelegate(
      service,
      client: client,
      originTable: const CmsHasuraDataTable('user'),
      foreignTable: const CmsHasuraDataTable('post'),
      foreignFields: const {},
      foreignKey: 'author_id',
    ).update(originId: 1, addedForeignIds: {7}.lock, removedForeignIds: {8}.lock);

    expect(service.updatedObjects, [
      {'id': 7, 'author_id': 1},
      {'id': 8, 'author_id': null},
    ]);
  });
}
