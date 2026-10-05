import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_supabase/utopia_cms_supabase.dart';

import 'http_recorder.dart';

/// Records what the delegate asks the service for and answers with nothing, or
/// with [failure] when set, the way the backend would reject the call.
class _ServiceRecorder extends CmsSupabaseService {
  final Object? failure;

  CmsFilter? queriedFilter;
  Object? deletedId;

  _ServiceRecorder({this.failure});

  @override
  Future<List<JsonMap>> query(
    SupabaseClient client, {
    required CmsSupabaseTable table,
    CmsFunctionsPagingParams? paging,
    CmsFilter filter = const CmsFilter.all(),
    CmsFunctionsSortingParams? sorting,
  }) {
    queriedFilter = filter;
    return _answer([]);
  }

  @override
  Future<JsonMap> insertOne(SupabaseClient client, {required CmsSupabaseTable table, required JsonMap object}) =>
      _answer(object);

  @override
  Future<JsonMap> deleteById(SupabaseClient client, {required CmsSupabaseDataTable table, required Object id}) {
    deletedId = id;
    return _answer({});
  }

  Future<T> _answer<T>(T value) async {
    if (failure case final failure?) throw failure;
    return value;
  }
}

/// A delegate that records the update `_archive` performs, the way a business
/// logic subclass would see it.
class _RecordingDelegate extends CmsSupabaseDelegate {
  final updates = <(JsonMap, JsonMap)>[];

  _RecordingDelegate(super.supabaseService, {required super.client, required super.table, super.archivedFilter});

  (JsonMap, JsonMap) get lastUpdate => updates.last;

  @override
  Future<JsonMap> update(JsonMap value, JsonMap oldValue) async {
    updates.add((value, oldValue));
    return value;
  }
}

void main() {
  const table = CmsSupabaseDataTable('users');

  late _ServiceRecorder service;
  late SupabaseClient client;

  setUp(() {
    service = _ServiceRecorder();
    // Anything that reaches the backend gets an empty answer.
    client = SupabaseClient('https://project.supabase.co', 'anon-key', httpClient: HttpRecorder());
  });

  tearDown(() => client.dispose());

  _RecordingDelegate delegate({CmsFilterNotEquals? archivedFilter}) =>
      _RecordingDelegate(service, client: client, table: table, archivedFilter: archivedFilter);

  test('get ands the archived filter into the caller filter', () async {
    await delegate(archivedFilter: const CmsFilterNotEquals('archived', true)).get(
      filter: const CmsFilter.equals('role', 'admin'),
      paging: CmsFunctionsPagingParams(offset: 0, limit: 10),
    );

    expect(
      service.queriedFilter,
      const CmsFilter.and([CmsFilter.notEquals('archived', true), CmsFilter.equals('role', 'admin')]),
    );
  });

  test('delete hard-deletes by id when there is no archived filter', () async {
    await delegate().delete({'id': 7});

    expect(service.deletedId, 7);
  });

  group('delete with an archived filter', () {
    test('updates the archived flag instead of deleting, leaving the row passed in untouched', () async {
      final subject = delegate(archivedFilter: const CmsFilterNotEquals('archived', true));
      final row = <String, dynamic>{'id': 7, 'archived': false};

      await subject.delete(row);

      expect(service.deletedId, isNull);
      expect(subject.lastUpdate.$1, {'id': 7, 'archived': true});
      expect(subject.lastUpdate.$2, {'id': 7, 'archived': false}, reason: 'the old value is the row before archiving');
      expect(row, {'id': 7, 'archived': false});
    });

    test('leaves a nested map of the row untouched for a dotted archived field', () async {
      final row = <String, dynamic>{
        'id': 7,
        'meta': {'archived': false},
      };

      await delegate(archivedFilter: const CmsFilterNotEquals('meta.archived', true)).delete(row);

      expect(row, {
        'id': 7,
        'meta': {'archived': false},
      });
    });
  });

  group('backend failures', () {
    test('are reported inline, naming the operation and the table and carrying the cause', () async {
      const noRows = 'Expected at least one row from Supabase, got none.';
      // One case per operation, so each of them is shown to go through the guard.
      final cases = <(CmsSupabaseService, Future<void> Function(CmsSupabaseDelegate), String)>[
        (
          _ServiceRecorder(failure: const AuthException('JWT expired')),
          (it) => it.get(paging: CmsFunctionsPagingParams(offset: 0, limit: 10)),
          'Failed to load "users": JWT expired',
        ),
        (
          _ServiceRecorder(
            failure: const PostgrestException(message: 'duplicate key value violates unique constraint'),
          ),
          (it) => it.create({'id': 7}),
          'Failed to create "users": duplicate key value violates unique constraint',
        ),
        // The real service over a backend answering `[]`, which is how row-level
        // security answers a write it silently filtered out.
        (const CmsSupabaseService(), (it) => it.update({'id': 7}, {}), 'Failed to update "users": $noRows'),
        (const CmsSupabaseService(), (it) => it.delete({'id': 7}), 'Failed to delete "users": $noRows'),
      ];

      for (final (backend, call, message) in cases) {
        await expectLater(
          () => call(CmsSupabaseDelegate(backend, client: client, table: table)),
          throwsA(isA<CmsDelegateException>().having((e) => e.message, 'message', message)),
        );
      }
    });

    test('an error that is not a backend failure keeps its type, even a StateError', () async {
      final bug = StateError('a bad state from a bug');
      service = _ServiceRecorder(failure: bug);

      await expectLater(() => delegate().delete({'id': 7}), throwsA(same(bug)));
    });
  });
}
