import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:graphql/client.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_graphql/utopia_cms_graphql.dart';
import 'package:utopia_cms_hasura/src/delegate/cms_hasura_backend_guard.dart';
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
    return _guard(
      'load',
      () => _hasuraService.query(
        client,
        table: foreignTable,
        fields: foreignFields,
        filter: _buildFilter(originId, fixedFilter),
      ),
    );
  }

  @override
  // TODO use batch update
  Future<void> update({
    required Object originId,
    required ISet<Object> addedForeignIds,
    required ISet<Object> removedForeignIds,
  }) async {
    await _guard(
      'update',
      () => Future.wait([
        for (final id in addedForeignIds) _update(id: id, originId: originId),
        for (final id in removedForeignIds) _update(id: id, originId: null),
      ]),
    );
  }

  CmsFilter _buildFilter(Object? originId, CmsFilter filter) =>
      originId != null ? filter & CmsFilter.equals(foreignKey, originId) : filter;

  Future<T> _guard<T>(String operation, Future<T> Function() call) =>
      guardHasuraCall(call, operation: operation, table: foreignTable);

  Future<void> _update({required Object id, required Object? originId}) async =>
      _hasuraService.updateById(client, table: foreignTable, object: {foreignTable.idKey: id, foreignKey: originId});
}

class CmsHasuraManyToManyDelegate implements CmsToManyDelegate {
  final CmsHasuraService _hasuraService;

  final GraphQLClient client;
  final CmsHasuraAssociationTable associationTable;
  final CmsGraphQLFields foreignFields;
  final CmsFilterNotEquals? archivedFilter;

  /// Name of the Hasura relationship that leads from the foreign table back to
  /// the association rows, used to filter the foreign rows down to one origin:
  /// `where: {<relationshipName>: {<originKey>: {_eq: originId}}}`.
  ///
  /// It must match the array (or object) relationship Hasura tracks on
  /// [CmsHasuraAssociationTable.foreignTable] over the association table - the
  /// name from the Hasura metadata, which need not be any table name. For a
  /// `user` / `role` pair joined through `user_role`, this is the relationship
  /// on `role` pointing at `user_role`, commonly named `user_roles`.
  ///
  /// Defaults to the origin table name, which only resolves when the
  /// relationship happens to be named exactly like the origin table.
  final String? relationshipName;

  const CmsHasuraManyToManyDelegate(
    this._hasuraService, {
    required this.client,
    required this.associationTable,
    required this.foreignFields,
    this.archivedFilter,
    this.relationshipName,
  });

  @override
  String get originIdKey => associationTable.originTable.idKey;

  @override
  String get foreignIdKey => associationTable.foreignTable.idKey;

  @override
  Future<List<JsonMap>> get({Object? originId, CmsFilter filter = const CmsFilter.all()}) async {
    final fixedFilter = archivedFilter == null ? filter : CmsFilterAnd([archivedFilter!, filter]);
    return _guard(
      'load',
      associationTable.foreignTable,
      () => _hasuraService.query(
        client,
        table: associationTable.foreignTable,
        fields: foreignFields,
        filter: originId != null ? fixedFilter & _buildFilter(originId) : fixedFilter,
      ),
    );
  }

  @override
  Future<void> update({
    required Object originId,
    required ISet<Object> addedForeignIds,
    required ISet<Object> removedForeignIds,
  }) async {
    await _guard(
      'update',
      associationTable,
      () => Future.wait([
        if (addedForeignIds.isNotEmpty) _add(originId: originId, foreignIds: addedForeignIds),
        if (removedForeignIds.isNotEmpty) _remove(originId: originId, foreignIds: removedForeignIds),
      ]),
    );
  }

  Future<T> _guard<T>(String operation, CmsHasuraTable table, Future<T> Function() call) =>
      guardHasuraCall(call, operation: operation, table: table);

  CmsFilter _buildFilter(Object originId) => CmsFilter.equals(
    "${relationshipName ?? associationTable.originTable.name}.${associationTable.originKey}",
    originId,
  );

  Future<void> _add({required Object originId, required ISet<Object> foreignIds}) async {
    await _hasuraService.insert(
      client,
      table: associationTable,
      objects: [
        for (final id in foreignIds) {associationTable.originKey: originId, associationTable.foreignKey: id},
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
