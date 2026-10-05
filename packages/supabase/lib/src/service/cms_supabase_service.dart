import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_supabase/src/model/cms_supabase_table.dart';
import 'package:utopia_cms_supabase/src/util/cms_supabase_guard.dart';

typedef _Query = PostgrestTransformBuilder<PostgrestList>;

class CmsSupabaseService {
  const CmsSupabaseService();

  Future<List<JsonMap>> query(
    SupabaseClient client, {
    required CmsSupabaseTable table,
    CmsFunctionsPagingParams? paging,
    CmsFilter filter = const CmsFilter.all(),
    CmsFunctionsSortingParams? sorting,
  }) async {
    final filtered = _applyFilter(_from(client, table).select(), filter);
    if (filtered == null) return [];

    _Query queryBuilder = filtered;

    // Apply sorting. Postgres puts NULLs last when ascending and first when
    // descending; `invertNulls` swaps both, and postgrest always serializes an
    // explicit `nullsfirst`/`nullslast`, so the flag has to be passed either way.
    if (sorting != null) {
      queryBuilder = queryBuilder.order(
        sorting.fieldKey,
        ascending: !sorting.sortDesc,
        nullsFirst: sorting.sortDesc != sorting.invertNulls,
      );
    }

    // Apply pagination. A null limit means "fetch everything" - the table stops
    // paging after such a call - so no range is requested at all.
    final limit = paging?.limit;
    if (paging != null && limit != null) {
      queryBuilder = queryBuilder.range(paging.offset, paging.offset + limit - 1);
    }

    return _asJsonMapList(await queryBuilder);
  }

  Future<List<JsonMap>> insert(
    SupabaseClient client, {
    required CmsSupabaseTable table,
    required List<JsonMap> objects,
  }) async {
    final response = await _from(client, table).insert(objects).select();
    return _asJsonMapList(response);
  }

  Future<JsonMap> insertOne(SupabaseClient client, {required CmsSupabaseTable table, required JsonMap object}) async {
    final response = await _from(client, table).insert(object).select();
    return _asFirstJsonMap(response);
  }

  Future<JsonMap> updateById(
    SupabaseClient client, {
    required CmsSupabaseDataTable table,
    required JsonMap object,
  }) async {
    final id = object[table.idKey] as Object;
    final updateData = JsonMap.from(object)..remove(table.idKey);
    final response = await _from(client, table).update(updateData).eq(table.idKey, id).select();
    return _asFirstJsonMap(response);
  }

  Future<List<JsonMap>> delete(
    SupabaseClient client, {
    required CmsSupabaseTable table,
    required CmsFilter filter,
  }) async {
    final queryBuilder = _applyFilter(_from(client, table).delete(), filter);
    if (queryBuilder == null) return [];
    final response = await queryBuilder.select();
    return _asJsonMapList(response);
  }

  Future<JsonMap> deleteById(SupabaseClient client, {required CmsSupabaseDataTable table, required Object id}) async {
    final response = await _from(client, table).delete().eq(table.idKey, id).select();
    return _asFirstJsonMap(response);
  }

  /// Targets [table], honouring its schema.
  ///
  /// A non-default schema is selected through `client.schema(...)`, which sends
  /// an `Accept-Profile`/`Content-Profile` header. Qualifying the table name
  /// instead would ask PostgREST for a relation literally called `schema.table`.
  SupabaseQueryBuilder _from(SupabaseClient client, CmsSupabaseTable table) {
    final schema = table.schema;
    return schema == null ? client.from(table.name) : client.schema(schema).from(table.name);
  }

  /// Narrows [query] by [filter], or returns `null` when [filter] can never
  /// match a row - PostgREST has no constant-false condition, so the caller has
  /// to skip the request instead of sending an unfiltered one.
  PostgrestFilterBuilder<T>? _applyFilter<T>(PostgrestFilterBuilder<T> query, CmsFilter filter) {
    return filter.when<PostgrestFilterBuilder<T>?>(
      all: () => query,
      equals: (field, value) {
        if (value == null) {
          return query.isFilter(field, null);
        }
        return query.eq(field, value);
      },
      notEquals: (field, value) {
        if (value == null) {
          return query.not(field, 'is', null);
        }
        return query.neq(field, value);
      },
      containsString: (field, value, caseSensitive) {
        final pattern = '%${_escapeLikeWildcards(value)}%';
        return caseSensitive ? query.like(field, pattern) : query.ilike(field, pattern);
      },
      inList: (field, values) => query.inFilter(field, values),
      and: (filters) {
        // For AND, we apply all filters sequentially (they are ANDed by default)
        var result = query;
        for (final f in filters) {
          final applied = _applyFilter(result, f);
          if (applied == null) return null;
          result = applied;
        }
        return result;
      },
      or: (filters) {
        final reduced = _reduceGroup(filters, isAnd: false);
        final constant = reduced.constant;
        if (constant != null) return _applyCondition(query, constant);
        // `query.or(...)` is itself the disjunction, so its terms go in bare.
        return query.or(reduced.parts.map((it) => it.text).join(','));
      },
      greaterOrEq: (field, value) => query.gte(field, value),
      lesserOrEq: (field, value) => query.lte(field, value),
      not: (filter) => _applyCondition(query, _negate(_buildCondition(filter))),
    );
  }

  PostgrestFilterBuilder<T>? _applyCondition<T>(PostgrestFilterBuilder<T> query, _Condition condition) {
    return switch (condition) {
      _AlwaysTrue() => query,
      _AlwaysFalse() => null,
      _Fragment(:final text) => query.or(text),
    };
  }

  /// Serializes a [CmsFilter] into a PostgREST condition fragment usable inside
  /// `or(...)` / `and(...)` groups and as the argument to `query.or(...)`.
  _Condition _buildCondition(CmsFilter filter) {
    return filter.when<_Condition>(
      all: () => const _AlwaysTrue(),
      equals: (field, value) => value == null
          ? _Fragment('$field.is.null', negated: '$field.not.is.null')
          : _column(field, 'eq', _formatValue(value)),
      notEquals: (field, value) => value == null
          ? _Fragment('$field.not.is.null', negated: '$field.is.null')
          : _Fragment('$field.neq.${_formatValue(value)}', negated: '$field.eq.${_formatValue(value)}'),
      containsString: (field, value, caseSensitive) =>
          _column(field, caseSensitive ? 'like' : 'ilike', _formatValue('%${_escapeLikeWildcards(value)}%')),
      inList: (field, values) => _column(field, 'in', '(${values.map(_formatValue).join(',')})'),
      and: (filters) => _buildGroup(filters, isAnd: true),
      or: (filters) => _buildGroup(filters, isAnd: false),
      greaterOrEq: (field, value) => _column(field, 'gte', _formatValue(value)),
      lesserOrEq: (field, value) => _column(field, 'lte', _formatValue(value)),
      not: (filter) => _negate(_buildCondition(filter)),
    );
  }

  /// A single-column condition. PostgREST negates those by splicing `not`
  /// between the column and the operator.
  _Fragment _column(String field, String operator, String value) =>
      _Fragment('$field.$operator.$value', negated: '$field.not.$operator.$value');

  /// Serializes an `and(...)` / `or(...)` group.
  ///
  /// A group of two or more terms MUST keep its wrapper so it survives nesting -
  /// a bare comma join collapses `and([a,b])` into two OR-ed terms once it sits
  /// inside another group - and PostgREST negates such a group by prefixing it
  /// with `not.`. A single-term group is left unwrapped.
  _Condition _buildGroup(List<CmsFilter> filters, {required bool isAnd}) {
    final reduced = _reduceGroup(filters, isAnd: isAnd);
    final constant = reduced.constant;
    if (constant != null) return constant;
    if (reduced.parts.length == 1) return reduced.parts.single;

    final group = '${isAnd ? 'and' : 'or'}(${reduced.parts.map((it) => it.text).join(',')})';
    return _Fragment(group, negated: 'not.$group');
  }

  /// Serializes the children of an `and` / `or` group, or reports the constant
  /// the whole group collapses to.
  ///
  /// `CmsFilter.all()` has no PostgREST spelling, so it is carried as a constant
  /// rather than an empty string: `all()` is the identity of `and` but absorbs
  /// `or`, and its negation is the other way round. Dropping it from an `or`
  /// would narrow the group to its remaining terms.
  ({_Condition? constant, List<_Fragment> parts}) _reduceGroup(List<CmsFilter> filters, {required bool isAnd}) {
    final parts = <_Fragment>[];
    for (final filter in filters) {
      switch (_buildCondition(filter)) {
        case final _Fragment fragment:
          parts.add(fragment);
        case _AlwaysTrue():
          if (!isAnd) return (constant: const _AlwaysTrue(), parts: parts);
        case _AlwaysFalse():
          if (isAnd) return (constant: const _AlwaysFalse(), parts: parts);
      }
    }
    if (parts.isEmpty) return (constant: isAnd ? const _AlwaysTrue() : const _AlwaysFalse(), parts: parts);
    return (constant: null, parts: parts);
  }

  /// Swaps a condition for its negation, so a double negation collapses back to
  /// the plain condition.
  _Condition _negate(_Condition condition) {
    return switch (condition) {
      _AlwaysTrue() => const _AlwaysFalse(),
      _AlwaysFalse() => const _AlwaysTrue(),
      _Fragment(:final text, :final negated) => _Fragment(negated, negated: text),
    };
  }

  List<JsonMap> _asJsonMapList(PostgrestList response) => response.cast<JsonMap>();

  JsonMap _asFirstJsonMap(PostgrestList response) {
    final list = _asJsonMapList(response);
    if (list.isEmpty) throw CmsSupabaseNoRowsError();
    return list.first;
  }

  /// Escapes the `LIKE`/`ILIKE` wildcards `%` and `_` so a search term matches
  /// literally. Postgres uses `\` as the default `LIKE` escape character, so the
  /// backslash itself has to be doubled first.
  // `*` is deliberately left alone: PostgREST may also read it as a pattern alias for `%`, pending verification
  // against the deployed PostgREST version.
  String _escapeLikeWildcards(String value) =>
      value.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');

  String _formatValue(Object? value) {
    if (value == null) return 'null';
    if (value is String) {
      // Escape quotes and backslashes, wrap in quotes
      return '"${value.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';
    }
    if (value is bool) return value.toString();
    if (value is num) return value.toString();
    // For other types, convert to string and quote
    return '"${value.toString().replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';
  }
}

/// A serialized PostgREST condition, or the constant it collapses to.
sealed class _Condition {
  const _Condition();
}

/// Matches every row: `CmsFilter.all()`, or a group that reduced to it.
final class _AlwaysTrue extends _Condition {
  const _AlwaysTrue();
}

/// Matches no row: `~CmsFilter.all()`, or a group that reduced to it.
final class _AlwaysFalse extends _Condition {
  const _AlwaysFalse();
}

/// A concrete PostgREST condition fragment, paired with its negation - PostgREST
/// spells that differently for a column (`a.not.eq.1`) and for a group
/// (`not.and(...)`).
final class _Fragment extends _Condition {
  final String text;
  final String negated;

  const _Fragment(this.text, {required this.negated});
}
