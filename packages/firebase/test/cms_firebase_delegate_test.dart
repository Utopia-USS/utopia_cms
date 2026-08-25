// The Firestore query types are annotated @sealed for app code. Test doubles
// have to implement them anyway - the same exemption mocking packages take.
// ignore_for_file: subtype_of_sealed_class, avoid_implementing_value_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_firebase/utopia_cms_firebase.dart';

/// Canned page keyed by document id, in the order Firestore would return it.
Map<String, JsonMap> docs(int count) =>
    Map.fromEntries(List.generate(count, (i) => MapEntry('id$i', {'name': 'name$i'})));

void main() {
  ({CmsFirebaseDelegate delegate, _QueryRecorder recorder}) setUpDelegate(
    Map<String, JsonMap> page, {
    String idKey = 'id',
    Object? failure,
  }) {
    final recorder = _QueryRecorder(page, failure: failure);
    return (delegate: CmsFirebaseDelegate('users', idKey: idKey, firestore: _Firestore(recorder)), recorder: recorder);
  }

  test('page 1 asks the collection for exactly the first page', () async {
    final (delegate: delegate, recorder: recorder) = setUpDelegate(docs(30));

    final result = await delegate.get(paging: CmsFunctionsPagingParams(offset: 0, limit: 30));

    expect(recorder.calls, ['collection(users)', 'limit(30)', 'get']);
    expect(result, hasLength(30));
    expect(result.first, {'name': 'name0', 'id': 'id0'});
  });

  test('page 2 asks for offset + limit documents and drops the previous page', () async {
    // What Firestore returns for limit(60) on a collection of 60+ documents.
    final (delegate: delegate, recorder: recorder) = setUpDelegate(docs(60));

    final result = await delegate.get(paging: CmsFunctionsPagingParams(offset: 30, limit: 30));

    expect(recorder.calls, ['collection(users)', 'limit(60)', 'get']);
    expect(result, hasLength(30));
    expect(result.first['id'], 'id30');
    expect(result.last['id'], 'id59');
  });

  test('a null limit means fetch all and applies no limit to the query', () async {
    final (delegate: delegate, recorder: recorder) = setUpDelegate(docs(42));

    final result = await delegate.get(paging: CmsFunctionsPagingParams(offset: 0, limit: null));

    expect(recorder.calls, ['collection(users)', 'get']);
    expect(result, hasLength(42));
  });

  test('a page shorter than the limit stays short, so the table stops paging', () async {
    // Only 35 documents exist, so limit(60) comes back with 35.
    final (delegate: delegate, recorder: recorder) = setUpDelegate(docs(35));

    final result = await delegate.get(paging: CmsFunctionsPagingParams(offset: 30, limit: 30));

    expect(recorder.calls, ['collection(users)', 'limit(60)', 'get']);
    expect(result, hasLength(5));
    expect(result.first['id'], 'id30');
  });

  test('documents are mapped to rows carrying the document id under idKey', () async {
    final (delegate: delegate, recorder: _) = setUpDelegate({
      'abc': {'name': 'Ada'},
    }, idKey: 'uid');

    final result = await delegate.get(paging: CmsFunctionsPagingParams(offset: 0, limit: 10));

    expect(result, [
      {'name': 'Ada', 'uid': 'abc'},
    ]);
  });

  test('a non-String id fails with a message naming the collection, key and runtime type', () async {
    final (delegate: delegate, recorder: _) = setUpDelegate(docs(0));

    await expectLater(
      () => delegate.delete({'id': 42}),
      throwsA(
        isA<CmsDelegateException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('"id"'),
            contains('"users"'),
            contains('42 (int)'),
            // A malformed row is a programmer error, not a Firestore failure, so
            // it must not pick up the backend-failure prefix on its way out.
            isNot(startsWith('Failed to')),
          ),
        ),
      ),
    );
  });

  test('sorting and filter are ignored: no orderBy or where reaches the query', () async {
    // Characterization of a documented limitation; fails loudly if someone
    // half-implements sorting or filtering without covering it.
    final (delegate: delegate, recorder: recorder) = setUpDelegate(docs(1));

    await delegate.get(
      sorting: const CmsFunctionsSortingParams(fieldKey: 'name', sortDesc: true),
      filter: const CmsFilter.equals('name', 'Ada'),
      paging: CmsFunctionsPagingParams(offset: 0, limit: 10),
    );

    expect(recorder.calls, ['collection(users)', 'limit(10)', 'get']);
  });

  group('backend failures', () {
    Future<void> loadWith(Object failure) async {
      final (delegate: delegate, recorder: _) = setUpDelegate(docs(0), failure: failure);
      await delegate.get(paging: CmsFunctionsPagingParams(offset: 0, limit: 10));
    }

    test('a Firestore failure names the operation and the collection and carries the backend message', () async {
      await expectLater(
        () => loadWith(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
            message: 'Missing or insufficient permissions.',
          ),
        ),
        throwsA(
          isA<CmsDelegateException>().having(
            (e) => e.message,
            'message',
            'Failed to load "users": Missing or insufficient permissions.',
          ),
        ),
      );
    });

    test('a message-less Firestore failure falls back to the error code', () async {
      await expectLater(
        () => loadWith(FirebaseException(plugin: 'cloud_firestore', code: 'unavailable')),
        throwsA(isA<CmsDelegateException>().having((e) => e.message, 'message', 'Failed to load "users": unavailable')),
      );
    });

    test('an exception that is not a backend failure keeps its type', () async {
      await expectLater(() => loadWith(ArgumentError('asked for a malformed query')), throwsA(isA<ArgumentError>()));
    });
  });
}

/// Records the query the delegate builds and answers `get()` with a canned page,
/// as Firestore would for the recorded query. Any other call fails loudly.
class _Firestore implements FirebaseFirestore {
  final _QueryRecorder recorder;

  _Firestore(this.recorder);

  @override
  CollectionReference<JsonMap> collection(String path) {
    recorder.calls.add('collection($path)');
    return recorder;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError('unexpected: ${invocation.memberName}');
}

class _QueryRecorder implements CollectionReference<JsonMap> {
  final Map<String, JsonMap> page;

  /// Thrown from [get] instead of answering, the way Firestore rejects a query.
  final Object? failure;

  final List<String> calls = [];

  _QueryRecorder(this.page, {this.failure});

  @override
  Query<JsonMap> limit(int limit) {
    calls.add('limit($limit)');
    return this;
  }

  @override
  Future<QuerySnapshot<JsonMap>> get([GetOptions? options]) async {
    calls.add('get');
    final failure = this.failure;
    if (failure != null) throw failure;
    return _Snapshot(page);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError('unexpected: ${invocation.memberName}');
}

class _Snapshot implements QuerySnapshot<JsonMap> {
  final Map<String, JsonMap> page;

  _Snapshot(this.page);

  @override
  List<QueryDocumentSnapshot<JsonMap>> get docs => [for (final e in page.entries) _Doc(e.key, e.value)];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError('unexpected: ${invocation.memberName}');
}

class _Doc implements QueryDocumentSnapshot<JsonMap> {
  @override
  final String id;

  final JsonMap _data;

  _Doc(this.id, this._data);

  @override
  JsonMap data() => _data;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError('unexpected: ${invocation.memberName}');
}
