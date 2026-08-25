import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_supabase/src/model/cms_supabase_table.dart';
import 'package:utopia_cms_supabase/src/service/cms_supabase_service.dart';
import 'package:utopia_cms_supabase/src/util/cms_supabase_guard.dart';

class CmsSupabaseDelegate implements CmsDelegate {
  final CmsSupabaseService supabaseService;

  final SupabaseClient client;
  final CmsSupabaseDataTable table;

  final CmsFilterNotEquals? archivedFilter;

  const CmsSupabaseDelegate(this.supabaseService, {required this.client, required this.table, this.archivedFilter});

  @override
  String get idKey => table.idKey;

  @override
  Future<List<JsonMap>> get({
    CmsFunctionsSortingParams? sorting,
    CmsFilter filter = const CmsFilter.all(),
    required CmsFunctionsPagingParams paging,
  }) async {
    final fixedFilter = archivedFilter == null ? filter : CmsFilterAnd([archivedFilter!, filter]);
    return _guard(
      'load',
      () => supabaseService.query(client, table: table, sorting: sorting, filter: fixedFilter, paging: paging),
    );
  }

  @override
  Future<JsonMap> create(JsonMap value) async =>
      _guard('create', () => supabaseService.insertOne(client, table: table, object: value));

  @override
  Future<JsonMap> update(JsonMap value, _) async =>
      _guard('update', () => supabaseService.updateById(client, table: table, object: value));

  @override
  Future<void> delete(JsonMap value) async {
    // The archiving path goes through `update`, which reports its own failures.
    if (archivedFilter != null) return _archive(value);
    await _guard('delete', () => supabaseService.deleteById(client, table: table, id: value[table.idKey]! as Object));
  }

  Future<T> _guard<T>(String action, Future<T> Function() run) => guardSupabaseCall('$action "${table.name}"', run);

  Future<void> _archive(JsonMap value) async {
    // A deep copy - the archived field may sit on a dotted path, and `value` is
    // the row the table still renders, so no nested map may be shared with it.
    final map = value.deepCopy();
    map.setAtPath(archivedFilter!.field, archivedFilter!.value);
    await update(map, value);
  }
}
