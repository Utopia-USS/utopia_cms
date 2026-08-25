import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_supabase/utopia_cms_supabase.dart';

/// Records what the delegate asks the service for, and answers with nothing.
class _ServiceRecorder extends CmsSupabaseService {
  CmsFilter? queriedFilter;
  Object? deletedId;

  @override
  Future<List<JsonMap>> query(
    SupabaseClient client, {
    required CmsSupabaseTable table,
    CmsFunctionsPagingParams? paging,
    CmsFilter filter = const CmsFilter.all(),
    CmsFunctionsSortingParams? sorting,
  }) async {
    queriedFilter = filter;
    return [];
  }

  @override
  Future<JsonMap> deleteById(SupabaseClient client, {required CmsSupabaseDataTable table, required Object id}) async {
    deletedId = id;
    return {};
  }
}

/// Answers every write with [failure], the way the backend would reject it.
class _FailingService extends CmsSupabaseService {
  final Object failure;

  _FailingService(this.failure);

  @override
  Future<JsonMap> updateById(
    SupabaseClient client, {
    required CmsSupabaseDataTable table,
    required JsonMap object,
  }) async => throw failure;
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
    client = SupabaseClient('https://project.supabase.co', 'anon-key');
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
    test('updates the archived flag instead of deleting', () async {
      final subject = delegate(archivedFilter: const CmsFilterNotEquals('archived', true));

      await subject.delete({'id': 7, 'archived': false});

      expect(service.deletedId, isNull);
      expect(subject.lastUpdate.$1, {'id': 7, 'archived': true});
    });

    test('passes the row as it was before archiving as the old value', () async {
      final subject = delegate(archivedFilter: const CmsFilterNotEquals('archived', true));

      await subject.delete({'id': 7, 'archived': false});

      expect(subject.lastUpdate.$2, {'id': 7, 'archived': false});
    });

    test('leaves the row the table passed in untouched', () async {
      final row = <String, dynamic>{'id': 7, 'archived': false};

      await delegate(archivedFilter: const CmsFilterNotEquals('archived', true)).delete(row);

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

    test('creates the missing parent of a dotted archived field', () async {
      final subject = delegate(archivedFilter: const CmsFilterNotEquals('meta.archived', true));

      await subject.delete({'id': 7});

      expect(subject.lastUpdate.$1, {
        'id': 7,
        'meta': {'archived': true},
      });
    });
  });

  group('backend failures', () {
    CmsSupabaseDelegate failing(Object failure) =>
        CmsSupabaseDelegate(_FailingService(failure), client: client, table: table);

    test('a Postgrest failure names the operation and the table and carries the backend message', () async {
      final subject = failing(
        const PostgrestException(message: 'duplicate key value violates unique constraint "users_pkey"'),
      );

      await expectLater(
        () => subject.update({'id': 7}, {}),
        throwsA(
          isA<CmsDelegateException>().having(
            (e) => e.message,
            'message',
            allOf(startsWith('Failed to update "users": '), contains('duplicate key value violates unique constraint')),
          ),
        ),
      );
    });

    test('an auth failure is reported the same way', () async {
      final subject = failing(const AuthException('JWT expired'));

      await expectLater(
        () => subject.update({'id': 7}, {}),
        throwsA(
          isA<CmsDelegateException>().having((e) => e.message, 'message', 'Failed to update "users": JWT expired'),
        ),
      );
    });

    test('an exception that is not a backend failure keeps its type', () async {
      final subject = failing(ArgumentError('called with a malformed row'));

      await expectLater(() => subject.update({'id': 7}, {}), throwsA(isA<ArgumentError>()));
    });
  });
}
