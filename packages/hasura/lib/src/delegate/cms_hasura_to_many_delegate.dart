import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:graphql/client.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_graphql/utopia_cms_graphql.dart';
import 'package:utopia_cms_hasura/src/model/cms_hasura_table.dart';
import 'package:utopia_cms_hasura/src/service/cms_hasura_service.dart';

class CmsHasuraOneToManyDelegate implements CmsToManyDelegate {
  final CmsHasuraService _hasuraService;

  final GraphQLClient client;
  final CmsHasuraDataTable originTable, foreignTable;
  final CmsGraphQLFields foreignFields;
  final String foreignKey;

  final CmsFilterNotEquals? archivedFilter;

  const CmsHasuraOneToManyDelegate(
    this._hasuraService, {
    required this.client,
    required this.originTable, // TODO this is needed only for [originIdKey], research if it can be inferred.
    required this.foreignTable,
    required this.foreignFields,
    required this.foreignKey,
        this.archivedFilter,
  });

  @override
  String get originIdKey => originTable.idKey;

  @override
  String get foreignIdKey => foreignTable.idKey;

  @override
  Future<List<JsonMap>> get({Object? originId, CmsFilter filter = const CmsFilter.all()}) async {
    final fixedFilter = archivedFilter == null ? filter : CmsFilterAnd([archivedFilter!, filter]);
    return _hasuraService.query(
      client,
      table: foreignTable,
      fields: foreignFields,
      filter: _buildFilter(originId, fixedFilter),
    );
  }

  @override
  // TODO use batch update
  Future<void> update({
    required Object originId,
    required ISet<Object> addedForeignIds,
    required ISet<Object> removedForeignIds,
  }) async {
    await Future.wait([
      for (final id in addedForeignIds) _update(id: id, originId: originId),
      for (final id in removedForeignIds) _update(id: id, originId: null),
    ]);
  }

  CmsFilter _buildFilter(Object? originId, CmsFilter filter) =>
      originId != null ? filter & CmsFilter.equals(foreignKey, originId) : filter;

  Future<void> _update({required Object id, required Object? originId}) async =>
      _hasuraService.updateById(client, table: foreignTable, object: {foreignTable.idKey: id, foreignKey: originId});
}

class CmsHasuraManyToManyDelegate implements CmsToManyDelegate {
  final CmsHasuraService _hasuraService;

  final GraphQLClient client;
  final CmsHasuraAssociationTable associationTable;
  final CmsGraphQLFields foreignFields;
  final CmsFilterNotEquals? archivedFilter;

  const CmsHasuraManyToManyDelegate(
    this._hasuraService, {
    required this.client,
    required this.associationTable,
    required this.foreignFields,
        this.archivedFilter,
  });

  @override
  String get originIdKey => associationTable.originTable.idKey;

  @override
  String get foreignIdKey => associationTable.foreignTable.idKey;

  @override
  Future<List<JsonMap>> get({Object? originId, CmsFilter filter = const CmsFilter.all()}) async {
    final fixedFilter = archivedFilter == null ? filter : CmsFilterAnd([archivedFilter!, filter]);
    return _hasuraService.query(
      client,
      table: associationTable.foreignTable,
      fields: foreignFields,
      filter: originId != null ? fixedFilter & _buildFilter(originId) : fixedFilter,
    );
  }

  @override
  Future<void> update({
    required Object originId,
    required ISet<Object> addedForeignIds,
    required ISet<Object> removedForeignIds,
  }) async {
    await Future.wait([
      if (addedForeignIds.isNotEmpty) _add(originId: originId, foreignIds: addedForeignIds),
      if (removedForeignIds.isNotEmpty) _remove(originId: originId, foreignIds: removedForeignIds),
    ]);
  }

  CmsFilter _buildFilter(Object originId) =>
      CmsFilter.equals("${associationTable.originTable.name}.${associationTable.originKey}", originId);

  Future<void> _add({required Object originId, required ISet<Object> foreignIds}) async {
    await _hasuraService.insert(
      client,
      table: associationTable,
      objects: [
        for (final id in foreignIds) {associationTable.originKey: originId, associationTable.foreignKey: id}
      ],
    );
  }

  Future<void> _remove({required Object originId, required ISet<Object> foreignIds}) async {
    await _hasuraService.delete(
      client,
      table: associationTable,
      filter: CmsFilter.and([
        CmsFilter.equals(associationTable.originKey, originId),
        CmsFilter.inList(associationTable.foreignKey, foreignIds.toList()),
      ]),
    );
  }
}
