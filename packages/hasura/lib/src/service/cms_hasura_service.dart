import 'package:gql/ast.dart';
import 'package:graphql/client.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_graphql/utopia_cms_graphql.dart';
import 'package:utopia_cms_hasura/src/model/cms_hasura_naming_convention.dart';
import 'package:utopia_cms_hasura/src/model/cms_hasura_table.dart';

class CmsHasuraService {
  final CmsGraphQLService _graphQLService;
  final CmsHasuraNamingConvention namingConvention;

  const CmsHasuraService(this._graphQLService, {required this.namingConvention});

  Future<List<JsonMap>> query(
    GraphQLClient client, {
    required CmsHasuraTable table,
    required CmsGraphQLFields fields,
    CmsFunctionsPagingParams? paging,
    CmsFilter filter = const CmsFilter.all(),
    CmsFunctionsSortingParams? sorting,
  }) async {
    final result = await _graphQLService.query(
      client,
      name: table.name,
      fields: fields,
      arguments: {
        if (paging != null) 'limit': paging.limit.toValueNodeUnsafe(),
        if (paging != null) 'offset': paging.offset.toValueNodeUnsafe(),
        'where': buildFilter(filter),
        if (sorting != null) namingConvention.argument(['order', 'by']): _buildSorting(sorting),
      },
    );
    return (result! as List).cast<JsonMap>();
  }

  Future<List<JsonMap>> insert(
    GraphQLClient client, {
    required CmsHasuraTable table,
    required List<JsonMap> objects,
    CmsGraphQLFields fields = const {},
  }) async {
    return _mutateReturning(
      client,
      name: namingConvention.field(["insert", table.name]),
      fields: fields,
      arguments: {"objects": objects.toValueNodeUnsafe()},
    );
  }

  Future<JsonMap> insertOne(
    GraphQLClient client, {
    required CmsHasuraTable table,
    required JsonMap object,
    CmsGraphQLFields fields = const {},
  }) async =>
      (await insert(client, table: table, objects: [object], fields: fields)).first;

  Future<JsonMap> updateByPk(
    GraphQLClient client, {
    required CmsHasuraTable table,
    required JsonMap keys,
    required JsonMap object,
    CmsGraphQLFields fields = const {},
  }) async {
    final result = await _graphQLService.mutate(
      client,
      name: namingConvention.field(["update", table.name, "by", "pk"]),
      arguments: {
        namingConvention.argument(["pk", "columns"]): keys.toValueNodeUnsafe(),
        "_set": object.toValueNodeUnsafe(),
      },
      fields: fields,
    );
    return result! as JsonMap;
  }

  Future<JsonMap> updateById(
    GraphQLClient client, {
    required CmsHasuraDataTable table,
    required JsonMap object,
    CmsGraphQLFields fields = const {},
  }) async =>
      updateByPk(client, table: table, keys: {table.idKey: object[table.idKey]}, object: object, fields: fields);

  Future<List<JsonMap>> delete(
    GraphQLClient client, {
    required CmsHasuraTable table,
    required CmsFilter filter,
    CmsGraphQLFields fields = const {},
  }) async {
    return _mutateReturning(
      client,
      name: namingConvention.field(["delete", table.name]),
      fields: fields,
      arguments: {"where": buildFilter(filter)},
    );
  }

  Future<JsonMap> deleteByPk(
    GraphQLClient client, {
    required CmsHasuraTable table,
    required JsonMap keys,
    CmsGraphQLFields fields = const {},
  }) async {
    final result = await _graphQLService.mutate(
      client,
      name: namingConvention.field(["delete", table.name, "by", "pk"]),
      arguments: keys.map((key, value) => MapEntry(key, (value as Object).toValueNodeUnsafe())),
      fields: fields,
    );
    return result! as JsonMap;
  }

  ValueNode buildFilter(CmsFilter filter) {
    return filter.when(
      all: () => const ObjectValueNode(),
      equals: (field, value) => _buildNested(field, {"_eq": value.toValueNodeUnsafe()}.toValueNode()),
      notEquals: (field, value) => _buildNested(field, {"_neq": value.toValueNodeUnsafe()}.toValueNode()),
      containsString: (field, value, caseSensitive) =>
          _buildNested(field, {caseSensitive ? "_like" : "_ilike": "%$value%".toValueNode()}.toValueNode()),
      inList: (field, values) => _buildNested(field, {"_in": values.toValueNodeUnsafe()}.toValueNode()),
      and: (filters) => {"_and": filters.map(buildFilter).toValueNode()}.toValueNode(),
      or: (filters) => {"_or": filters.map(buildFilter).toValueNode()}.toValueNode(),
      not: (filter) => {"_not": buildFilter(filter)}.toValueNode(),
      greaterOrEq: (field, value) => _buildNested(field, {"_gte": value.toValueNodeUnsafe()}.toValueNode()),
      lesserOrEq: (field, value) => _buildNested(field, {"_lte": value.toValueNodeUnsafe()}.toValueNode()),
    );
  }

  Future<List<JsonMap>> _mutateReturning(
    GraphQLClient client, {
    required String name,
    required CmsGraphQLFields fields,
    required Map<String, ValueNode> arguments,
  }) async {
    final result = await _graphQLService.mutate(
      client,
      name: name,
      fields: {CmsGraphQLField("returning", fields)},
      arguments: arguments,
    );
    return ((result! as JsonMap)["returning"] as List).cast<JsonMap>();
  }

  ValueNode _buildSorting(CmsFunctionsSortingParams params) =>
      _buildNested(params.fieldKey, namingConvention.enumValue(_buildSortingDirection(params)).toEnumValueNode());

  List<String> _buildSortingDirection(CmsFunctionsSortingParams params) {
    return switch ((params.sortDesc, params.invertNulls)) {
      (false, false) => ['asc'],
      (false, true) => ['asc', 'nulls', 'first'],
      (true, false) => ['desc'],
      (true, true) => ['desc', 'nulls', 'last'],
    };
  }

  ObjectValueNode _buildNested(String path, ValueNode value) {
    final parts = path.split(".");
    final lastPart = parts.removeLast();
    var current = {lastPart: value}.toValueNode();
    for (final part in parts.reversed) {
      current = {part: current}.toValueNode();
    }
    return current;
  }
}
