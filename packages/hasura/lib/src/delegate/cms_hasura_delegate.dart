import 'package:graphql/client.dart';
import 'package:utopia_cms/src/util/map_extensions.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_graphql/utopia_cms_graphql.dart';
import 'package:utopia_cms_hasura/src/model/cms_hasura_table.dart';
import 'package:utopia_cms_hasura/src/service/cms_hasura_service.dart';

class CmsHasuraDelegate implements CmsDelegate {
  final CmsHasuraService _hasuraService;

  final GraphQLClient client;
  final CmsHasuraDataTable table;
  final CmsGraphQLFields fields;

  final CmsFilterNotEquals? archivedFilter;

  const CmsHasuraDelegate(
    this._hasuraService, {
    required this.client,
    required this.table,
    this.archivedFilter,
    this.fields = const {},
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
    return _hasuraService.query(
      client,
      table: table,
      fields: fields,
      sorting: sorting,
      filter: fixedFilter,
      paging: paging,
    );
  }

  @override
  Future<JsonMap> create(JsonMap value) async =>
      _hasuraService.insertOne(client, table: table, fields: fields, object: value);

  @override
  Future<JsonMap> update(JsonMap value) async =>
      _hasuraService.updateById(client, table: table, fields: fields, object: value);

  @override
  Future<void> delete(JsonMap value) async => archivedFilter != null
      ? _archive(value)
      : _hasuraService.deleteById(client, table: table, fields: fields, object: value);

  Future<void> _archive(JsonMap value) async {
    final map = value;
    map.setAtPath(archivedFilter!.field, archivedFilter!.value);
    await update(value);
  }
}
