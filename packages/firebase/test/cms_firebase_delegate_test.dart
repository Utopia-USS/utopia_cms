// The Firestore query types are annotated @sealed for app code. Test doubles
// have to implement them anyway - the same exemption mocking packages take.
// ignore_for_file: subtype_of_sealed_class, avoid_implementing_value_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_firebase/utopia_cms_firebase.dart';

/// Canned page keyed by document id, in the order Firestore would return it.
Map<String, JsonMap> docs(int count, {int from = 0}) =>
    Map.fromEntries(List.generate(count, (i) => MapEntry('id${from + i}', {'name': 'name${from + i}'})));

void main() {
  ({CmsFirebaseDelegate delegate, _QueryRecorder recorder}) setUpDelegate(
    Map<String, JsonMap> page, {
    String idKey = 'id',
  }) {
    final recorder = _QueryRecorder(page);
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

  test('a non-String id fails with a message naming the collection and the key', () async {
    final (delegate: delegate, recorder: _) = setUpDelegate(docs(0));

    expect(
      () => delegate.delete({'id': 42}),
      throwsA(
        isA<CmsDelegateException>().having(
          (e) => e.message,
          'message',
          allOf(contains('"id"'), contains('"users"'), contains('42')),
        ),
      ),
    );
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
  final List<String> calls = [];

  _QueryRecorder(this.page);

  @override
  Query<JsonMap> limit(int limit) {
    calls.add('limit($limit)');
    return this;
  }

  @override
  Future<QuerySnapshot<JsonMap>> get([GetOptions? options]) async {
    calls.add('get');
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
