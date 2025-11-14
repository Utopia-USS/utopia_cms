import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_supabase/src/model/cms_supabase_table.dart';
import 'package:utopia_cms_supabase/src/service/cms_supabase_service.dart';

class CmsSupabaseOneToManyDelegate implements CmsToManyDelegate {
  final CmsSupabaseService _supabaseService;

  final SupabaseClient client;
  final CmsSupabaseDataTable originTable, foreignTable;
  final String foreignKey;

  final CmsFilterNotEquals? archivedFilter;

  const CmsSupabaseOneToManyDelegate(
    this._supabaseService, {
    required this.client,
    required this.originTable,
    required this.foreignTable,
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
    return _supabaseService.query(
      client,
      table: foreignTable,
      filter: _buildFilter(originId, fixedFilter),
    );
  }

  @override
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

  Future<void> _update({required Object id, required Object? originId}) async => _supabaseService.updateById(
        client,
        table: foreignTable,
        object: {foreignTable.idKey: id, foreignKey: originId},
      );
}

class CmsSupabaseManyToManyDelegate implements CmsToManyDelegate {
  final CmsSupabaseService _supabaseService;

  final SupabaseClient client;
  final CmsSupabaseAssociationTable associationTable;
  final CmsFilterNotEquals? archivedFilter;

  const CmsSupabaseManyToManyDelegate(
    this._supabaseService, {
    required this.client,
    required this.associationTable,
    this.archivedFilter,
  });

  @override
  String get originIdKey => associationTable.originTable.idKey;

  @override
  String get foreignIdKey => associationTable.foreignTable.idKey;

  @override
  Future<List<JsonMap>> get({Object? originId, CmsFilter filter = const CmsFilter.all()}) async {
    final fixedFilter = archivedFilter == null ? filter : CmsFilterAnd([archivedFilter!, filter]);

    if (originId == null) {
      return _supabaseService.query(
        client,
        table: associationTable.foreignTable,
        filter: fixedFilter,
      );
    }

    // Get foreign IDs from association table
    final associations = await _supabaseService.query(
      client,
      table: associationTable,
      filter: CmsFilter.equals(associationTable.originKey, originId),
    );

    final foreignIds = associations.map((a) => a[associationTable.foreignKey] as Object).toList();

    if (foreignIds.isEmpty) {
      return [];
    }

    // Get foreign records
    return _supabaseService.query(
      client,
      table: associationTable.foreignTable,
      filter: fixedFilter & CmsFilter.inList(associationTable.foreignTable.idKey, foreignIds),
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

  Future<void> _add({required Object originId, required ISet<Object> foreignIds}) async {
    await _supabaseService.insert(
      client,
      table: associationTable,
      objects: [
        for (final id in foreignIds)
          {
            associationTable.originKey: originId,
            associationTable.foreignKey: id,
          }
      ],
    );
  }

  Future<void> _remove({required Object originId, required ISet<Object> foreignIds}) async {
    await _supabaseService.delete(
      client,
      table: associationTable,
      filter: CmsFilter.and([
        CmsFilter.equals(associationTable.originKey, originId),
        CmsFilter.inList(associationTable.foreignKey, foreignIds.toList()),
      ]),
    );
  }
}
