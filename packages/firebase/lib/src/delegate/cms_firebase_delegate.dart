import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utopia_cms/utopia_cms.dart';

/// A minimal Firestore-backed [CmsDelegate].
///
/// Known limitations of [get]:
/// - [CmsFunctionsSortingParams] and [CmsFilter] are NOT applied: the table
///   pages through the whole collection in document-id order even when the UI
///   shows an active sort or filter. Override [get] to support either.
/// - Paging is offset-based on top of a cursor-less API, so page N costs
///   `offset + limit` document reads. For large collections override [get]
///   with `startAfterDocument` cursor paging.
class CmsFirebaseDelegate implements CmsDelegate {
  final String collection;

  @override
  final String idKey;

  final FirebaseFirestore? _firestore;

  /// Pass [firestore] to run against a non-default app or a test double.
  /// Defaults to [FirebaseFirestore.instance], resolved lazily so that the
  /// constructor stays `const`.
  const CmsFirebaseDelegate(this.collection, {this.idKey = 'id', FirebaseFirestore? firestore})
    : _firestore = firestore;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> delete(JsonMap value) async {
    await _guard('delete', () => firestore.collection(collection).doc(_idOf(value)).delete());
  }

  @override
  Future<List<JsonMap>> get({
    CmsFunctionsSortingParams? sorting,
    CmsFilter? filter,
    required CmsFunctionsPagingParams paging,
  }) async {
    Query<JsonMap> query = firestore.collection(collection);
    final limit = paging.limit;
    // Firestore has no offset queries, so fetch everything up to the end of the
    // requested page and drop the documents belonging to the previous ones.
    // A null limit means "fetch all", so no limit is applied at all.
    if (limit != null) query = query.limit(paging.offset + limit);
    final snapshot = await _guard('load', query.get);
    return snapshot.docs.skip(paging.offset).map((e) => {...e.data(), idKey: e.id}).toList();
  }

  @override
  Future<JsonMap> update(JsonMap value, _) async {
    final map = JsonMap.from(value)..remove(idKey);
    await _guard('update', () => firestore.collection(collection).doc(_idOf(value)).update(map));
    return value;
  }

  @override
  Future<JsonMap> create(JsonMap value) async {
    final result = await _guard('create', () => firestore.collection(collection).add(value));
    return {...value, idKey: result.id};
  }

  /// Runs [run], reporting a Firestore failure as a [CmsDelegateException] so
  /// the CMS can show it inline instead of crashing on an exception type it does
  /// not know.
  ///
  /// Only [FirebaseException] is caught, so a programmer error - including the
  /// [CmsDelegateException] [_idOf] raises for a malformed row - keeps its type
  /// and is never wrapped twice. [CmsDelegateException] has nowhere to carry a
  /// cause, so the Firestore message goes into the message and the original
  /// stack trace is rethrown as is.
  Future<T> _guard<T>(String action, Future<T> Function() run) async {
    try {
      return await run();
    } on FirebaseException catch (e, stackTrace) {
      Error.throwWithStackTrace(
        CmsDelegateException('Failed to $action "$collection": ${e.message ?? e.code}'),
        stackTrace,
      );
    }
  }

  String _idOf(JsonMap value) => switch (value[idKey]) {
    final String id => id,
    final other => throw CmsDelegateException(
      'Expected a String document id under "$idKey" in collection "$collection", got: $other (${other.runtimeType})',
    ),
  };
}
