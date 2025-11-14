import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_supabase/src/model/cms_supabase_table.dart';

class CmsSupabaseService {
  const CmsSupabaseService();

  Future<List<JsonMap>> query(
    SupabaseClient client, {
    required CmsSupabaseTable table,
    CmsFunctionsPagingParams? paging,
    CmsFilter filter = const CmsFilter.all(),
    CmsFunctionsSortingParams? sorting,
  }) async {
    dynamic queryBuilder = client.from(table.fullName).select();

    // Apply filter
    queryBuilder = _applyFilter(queryBuilder, filter);

    // Apply sorting
    if (sorting != null) {
      final orderColumn = sorting.fieldKey;
      final ascending = !sorting.sortDesc;
      if (sorting.invertNulls) {
        queryBuilder = queryBuilder.order(orderColumn, ascending: ascending, nullsFirst: ascending);
      } else {
        queryBuilder = queryBuilder.order(orderColumn, ascending: ascending);
      }
    }

    // Apply pagination
    if (paging != null) {
      final limit = paging.limit ?? 100;
      queryBuilder = queryBuilder.range(paging.offset, paging.offset + limit - 1);
    }

    final response = await queryBuilder;
    return (response as List).cast<JsonMap>();
  }

  Future<List<JsonMap>> insert(
    SupabaseClient client, {
    required CmsSupabaseTable table,
    required List<JsonMap> objects,
  }) async {
    final response = await client.from(table.fullName).insert(objects).select();
    return (response as List).cast<JsonMap>();
  }

  Future<JsonMap> insertOne(
    SupabaseClient client, {
    required CmsSupabaseTable table,
    required JsonMap object,
  }) async {
    final response = await client.from(table.fullName).insert(object).select();
    return (response as List).cast<JsonMap>().first;
  }

  Future<JsonMap> updateById(
    SupabaseClient client, {
    required CmsSupabaseDataTable table,
    required JsonMap object,
  }) async {
    final id = object[table.idKey] as Object;
    final updateData = JsonMap.from(object)..remove(table.idKey);
    final response = await client.from(table.fullName).update(updateData).eq(table.idKey, id).select();
    return (response as List).cast<JsonMap>().first;
  }

  Future<List<JsonMap>> delete(
    SupabaseClient client, {
    required CmsSupabaseTable table,
    required CmsFilter filter,
  }) async {
    dynamic queryBuilder = client.from(table.fullName).delete().select();
    queryBuilder = _applyFilter(queryBuilder, filter);
    final response = await queryBuilder;
    return (response as List).cast<JsonMap>();
  }

  Future<JsonMap> deleteById(
    SupabaseClient client, {
    required CmsSupabaseDataTable table,
    required Object id,
  }) async {
    final response = await client.from(table.fullName).delete().eq(table.idKey, id).select();
    return (response as List).cast<JsonMap>().first;
  }

  dynamic _applyFilter(dynamic query, CmsFilter filter) {
    return filter.when(
      all: () => query,
      equals: (field, value) {
        if (value == null) {
          return query.isFilter(field, 'is', null);
        }
        return query.eq(field, value);
      },
      notEquals: (field, value) => query.neq(field, value),
      containsString: (field, value, caseSensitive) {
        final pattern = '%$value%';
        return caseSensitive ? query.like(field, pattern) : query.ilike(field, pattern);
      },
      inList: (field, values) => query.inFilter(field, values),
      and: (filters) {
        // For AND, we apply all filters sequentially (they are ANDed by default)
        dynamic result = query;
        for (final f in filters) {
          result = _applyFilter(result, f);
        }
        return result;
      },
      or: (filters) {
        // Supabase supports OR using .or() method
        // We need to build OR conditions properly
        if (filters.isEmpty) return query;
        if (filters.length == 1) return _applyFilter(query, filters.first);

        // Build OR conditions: or('field1.eq.value1,field2.eq.value2')
        final orConditions = filters.map((f) => _buildOrCondition(f)).where((c) => c.isNotEmpty).join(',');
        if (orConditions.isNotEmpty) {
          return query.or(orConditions);
        }
        return query;
      },
      greaterOrEq: (field, value) => query.gte(field, value),
      lesserOrEq: (field, value) => query.lte(field, value),
      not: (filter) {
        // Supabase supports NOT using .not() method
        final condition = _buildNotCondition(filter);
        if (condition.isNotEmpty) {
          return query.not(condition);
        }
        return query;
      },
    );
  }

  String _buildOrCondition(CmsFilter filter) {
    return filter.when(
      all: () => '',
      equals: (field, value) {
        if (value == null) return '$field.is.null';
        return '$field.eq.${_formatValue(value)}';
      },
      notEquals: (field, value) => '$field.neq.${_formatValue(value)}',
      containsString: (field, value, caseSensitive) {
        final pattern = '%$value%';
        final formattedPattern = _formatValue(pattern);
        return caseSensitive ? '$field.like.$formattedPattern' : '$field.ilike.$formattedPattern';
      },
      inList: (field, values) => '$field.in.(${values.map(_formatValue).join(',')})',
      and: (filters) {
        // For AND within OR, we combine with comma
        return filters.map(_buildOrCondition).where((c) => c.isNotEmpty).join(',');
      },
      or: (filters) {
        // Nested OR - combine with comma
        return filters.map(_buildOrCondition).where((c) => c.isNotEmpty).join(',');
      },
      greaterOrEq: (field, value) => '$field.gte.${_formatValue(value)}',
      lesserOrEq: (field, value) => '$field.lte.${_formatValue(value)}',
      not: (filter) {
        final condition = _buildNotCondition(filter);
        return condition.isNotEmpty ? 'not.$condition' : '';
      },
    );
  }

  String _buildNotCondition(CmsFilter filter) {
    return filter.when(
      all: () => '',
      equals: (field, value) {
        if (value == null) return '$field.is.null';
        return '$field.eq.${_formatValue(value)}';
      },
      notEquals: (field, value) => '$field.neq.${_formatValue(value)}',
      containsString: (field, value, caseSensitive) {
        final pattern = '%$value%';
        final formattedPattern = _formatValue(pattern);
        return caseSensitive ? '$field.like.$formattedPattern' : '$field.ilike.$formattedPattern';
      },
      inList: (field, values) => '$field.in.(${values.map(_formatValue).join(',')})',
      and: (filters) {
        // For AND within NOT, we combine with comma
        return filters.map(_buildNotCondition).where((c) => c.isNotEmpty).join(',');
      },
      or: (filters) {
        // OR within NOT - combine with comma
        return filters.map(_buildNotCondition).where((c) => c.isNotEmpty).join(',');
      },
      greaterOrEq: (field, value) => '$field.gte.${_formatValue(value)}',
      lesserOrEq: (field, value) => '$field.lte.${_formatValue(value)}',
      not: (filter) {
        // Double NOT - return the inner condition
        return _buildNotCondition(filter);
      },
    );
  }

  String _formatValue(Object? value) {
    if (value == null) return 'null';
    if (value is String) {
      // Escape quotes and backslashes, wrap in quotes
      return '"${value.replaceAll('\\', '\\\\').replaceAll('"', '\\"')}"';
    }
    if (value is bool) return value.toString();
    if (value is num) return value.toString();
    // For other types, convert to string and quote
    return '"${value.toString().replaceAll('\\', '\\\\').replaceAll('"', '\\"')}"';
  }
}
