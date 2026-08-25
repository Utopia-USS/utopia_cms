import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_supabase/utopia_cms_supabase.dart';

/// Records every request postgrest builds and answers it with [body].
class _Recorder extends http.BaseClient {
  final requests = <http.BaseRequest>[];

  String body = '[]';

  http.BaseRequest? get last => requests.isEmpty ? null : requests.last;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    return http.StreamedResponse(
      Stream.value(utf8.encode(body)),
      200,
      request: request,
      headers: {'content-type': 'application/json'},
    );
  }
}

void main() {
  const service = CmsSupabaseService();
  const table = CmsSupabaseDataTable('users');

  late _Recorder recorder;
  late SupabaseClient client;

  setUp(() {
    recorder = _Recorder();
    client = SupabaseClient('https://project.supabase.co', 'anon-key', httpClient: recorder);
  });

  tearDown(() => client.dispose());

  /// The single query parameter named [key] of the last recorded request.
  String? param(String key) => recorder.last?.url.queryParameters[key];

  /// Every value sent under [key] - PostgREST takes a repeated key as a
  /// conjunction, so a single-value read would hide all but the first term.
  List<String>? params(String key) => recorder.last?.url.queryParametersAll[key];

  Future<void> get({
    CmsFilter filter = const CmsFilter.all(),
    CmsFunctionsSortingParams? sorting,
    CmsFunctionsPagingParams? paging,
    CmsSupabaseTable target = table,
  }) => service.query(client, table: target, filter: filter, sorting: sorting, paging: paging);

  group('target', () {
    test('a table without a schema hits the default endpoint', () async {
      await get();

      expect(recorder.last!.url.path, '/rest/v1/users');
      expect(recorder.last!.headers['Accept-Profile'], 'public');
    });

    test('a schema-qualified table keeps its plain name and selects the schema', () async {
      await get(target: const CmsSupabaseDataTable('users', schema: 'app'));

      expect(recorder.last!.url.path, '/rest/v1/users');
      expect(recorder.last!.headers['Accept-Profile'], 'app');
    });
  });

  group('paging', () {
    test('offset and limit are sent as an inclusive range', () async {
      await get(paging: CmsFunctionsPagingParams(offset: 20, limit: 10));

      expect(param('offset'), '20');
      expect(param('limit'), '10');
    });

    test('a null limit means fetch everything, so no limit is sent', () async {
      await get(paging: CmsFunctionsPagingParams(offset: 0, limit: null));

      expect(param('offset'), isNull);
      expect(param('limit'), isNull);
    });
  });

  group('sorting', () {
    test('ascending puts nulls last, inverted puts them first', () async {
      await get(sorting: const CmsFunctionsSortingParams(fieldKey: 'name', sortDesc: false));
      expect(param('order'), 'name.asc.nullslast');

      await get(sorting: const CmsFunctionsSortingParams(fieldKey: 'name', sortDesc: false, invertNulls: true));
      expect(param('order'), 'name.asc.nullsfirst');
    });

    test('descending puts nulls first, inverted puts them last', () async {
      await get(sorting: const CmsFunctionsSortingParams(fieldKey: 'name', sortDesc: true));
      expect(param('order'), 'name.desc.nullsfirst');

      await get(sorting: const CmsFunctionsSortingParams(fieldKey: 'name', sortDesc: true, invertNulls: true));
      expect(param('order'), 'name.desc.nullslast');
    });
  });

  group('filter', () {
    test('equals uses eq, and is.null for a null value', () async {
      await get(filter: const CmsFilter.equals('age', 30));
      expect(param('age'), 'eq.30');

      await get(filter: const CmsFilter.equals('age', null));
      expect(param('age'), 'is.null');
    });

    test('notEquals uses neq, and not.is.null for a null value', () async {
      await get(filter: const CmsFilter.notEquals('age', 30));
      expect(param('age'), 'neq.30');

      await get(filter: const CmsFilter.notEquals('age', null));
      expect(param('age'), 'not.is.null');
    });

    test('inList uses in', () async {
      await get(filter: const CmsFilter.inList('id', [1, 2]));

      expect(param('id'), 'in.(1,2)');
    });

    test('and applies each child as its own parameter', () async {
      await get(filter: const CmsFilter.equals('age', 30) & const CmsFilter.equals('name', 'a'));

      expect(param('age'), 'eq.30');
      expect(param('name'), 'eq.a');
    });

    test('or of two ands keeps the groups nested', () async {
      await get(
        filter: const CmsFilter.or([
          CmsFilter.and([CmsFilter.equals('a', 1), CmsFilter.equals('b', 2)]),
          CmsFilter.and([CmsFilter.equals('c', 3), CmsFilter.equals('d', 4)]),
        ]),
      );

      expect(param('or'), '(and(a.eq.1,b.eq.2),and(c.eq.3,d.eq.4))');
    });

    test('not of an and negates the whole group', () async {
      await get(filter: const CmsFilter.not(CmsFilter.and([CmsFilter.equals('a', 1), CmsFilter.equals('b', 2)])));

      expect(param('or'), '(not.and(a.eq.1,b.eq.2))');
    });

    test('and of two negations sends both, as two separate or parameters', () async {
      await get(
        filter: const CmsFilter.and([
          CmsFilter.not(CmsFilter.equals('a', 1)),
          CmsFilter.not(CmsFilter.equals('b', 2)),
        ]),
      );

      expect(params('or'), ['(a.not.eq.1)', '(b.not.eq.2)']);
    });

    test('double negation collapses to the plain condition', () async {
      await get(filter: const CmsFilter.not(CmsFilter.not(CmsFilter.equals('a', 1))));

      expect(param('or'), '(a.eq.1)');
    });

    test('string values are quoted and escaped inside groups', () async {
      await get(filter: const CmsFilter.or([CmsFilter.equals('a', r'say "hi"\ok')]));

      expect(param('or'), r'(a.eq."say \"hi\"\\ok")');
    });

    group('all() inside a group', () {
      test('widens an or to every row instead of narrowing it', () async {
        await get(filter: const CmsFilter.all() | const CmsFilter.equals('active', true));

        expect(recorder.last!.url.queryParameters.keys, ['select']);
      });

      test('is dropped from an and', () async {
        await get(filter: const CmsFilter.all() & const CmsFilter.equals('active', true));

        expect(param('active'), 'eq.true');
      });
    });

    group('an empty group', () {
      test('or([]) matches no row, so no request is sent at all', () async {
        expect(await service.query(client, table: table, filter: const CmsFilter.or([])), isEmpty);

        expect(recorder.requests, isEmpty);
      });

      test('and([]) matches every row, so the request goes out unfiltered', () async {
        await get(filter: const CmsFilter.and([]));

        expect(recorder.last!.url.queryParameters.keys, ['select']);
      });
    });

    group('~all()', () {
      test('matches no row, so no request is sent at all', () async {
        expect(await service.query(client, table: table, filter: ~const CmsFilter.all()), isEmpty);

        expect(recorder.requests, isEmpty);
      });

      test('is dropped from an or', () async {
        await get(filter: CmsFilter.or([~const CmsFilter.all(), const CmsFilter.equals('a', 1)]));

        expect(param('or'), '(a.eq.1)');
      });

      test('collapses an and, so no request is sent at all', () async {
        expect(
          await service.query(client, table: table, filter: ~const CmsFilter.all() & const CmsFilter.equals('a', 1)),
          isEmpty,
        );

        expect(recorder.requests, isEmpty);
      });
    });

    group('containsString', () {
      test('uses ilike, and like when case-sensitive', () async {
        await get(filter: const CmsFilter.containsString('name', 'ann'));
        expect(param('name'), 'ilike.%ann%');

        await get(filter: const CmsFilter.containsString('name', 'ann', caseSensitive: true));
        expect(param('name'), 'like.%ann%');
      });

      test('escapes the like wildcards in the search term', () async {
        await get(filter: const CmsFilter.containsString('name', '50%_off'));

        expect(param('name'), r'ilike.%50\%\_off%');
      });

      test('escapes the like wildcards inside a group too', () async {
        await get(filter: const CmsFilter.or([CmsFilter.containsString('name', '50%')]));

        expect(param('or'), r'(name.ilike."%50\\%%")');
      });
    });
  });

  group('write', () {
    setUp(() => recorder.body = '[{"id": 1}]');

    test('updateById strips the id from the payload and filters on it', () async {
      await service.updateById(client, table: table, object: {'id': 1, 'name': 'a'});

      expect(recorder.last!.method, 'PATCH');
      expect(param('id'), 'eq.1');
      expect((recorder.last! as http.Request).body, '{"name":"a"}');
    });

    test('deleteById filters on the id key', () async {
      await service.deleteById(
        client,
        table: const CmsSupabaseDataTable('users', idKey: 'uuid'),
        id: 'x',
      );

      expect(recorder.last!.method, 'DELETE');
      expect(param('uuid'), 'eq.x');
    });

    test('delete without a matching filter sends nothing', () async {
      expect(await service.delete(client, table: table, filter: ~const CmsFilter.all()), isEmpty);

      expect(recorder.requests, isEmpty);
    });
  });
}
