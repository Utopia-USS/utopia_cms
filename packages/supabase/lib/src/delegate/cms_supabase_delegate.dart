import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_supabase/src/model/cms_supabase_table.dart';
import 'package:utopia_cms_supabase/src/service/cms_supabase_service.dart';

class CmsSupabaseDelegate implements CmsDelegate {
  final CmsSupabaseService supabaseService;

  final SupabaseClient client;
  final CmsSupabaseDataTable table;

  final CmsFilterNotEquals? archivedFilter;

  const CmsSupabaseDelegate(
    this.supabaseService, {
    required this.client,
    required this.table,
    this.archivedFilter,
  });

  @override
  String get idKey => table.idKey;

  @override
  Future<List<JsonMap>> get({
    CmsFunctionsSortingParams? sorting,
    CmsFilter filter = const CmsFilter.all(),
    required CmsFunctionsPagingParams paging,
  }) async {
    final fixedFilter = archivedFilter == null ? filter : CmsFilterAnd([archivedFilter!, filter]);
    return supabaseService.query(
      client,
      table: table,
      sorting: sorting,
      filter: fixedFilter,
      paging: paging,
    );
  }

  @override
  Future<JsonMap> create(JsonMap value) async => supabaseService.insertOne(client, table: table, object: value);

  @override
  Future<JsonMap> update(JsonMap value, _) async => supabaseService.updateById(client, table: table, object: value);

  @override
  Future<void> delete(JsonMap value) async => archivedFilter != null
      ? _archive(value)
      : supabaseService.deleteById(client, table: table, id: value[table.idKey]! as Object);

  Future<void> _archive(JsonMap value) async {
    final map = JsonMap.from(value);
    map.setAtPath(archivedFilter!.field, archivedFilter!.value);
    await update(map, value);
  }
}
