import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utopia_cms/utopia_cms.dart';

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
    final id = value[idKey]! as String;
    final userRef = firestore.collection(collection).doc(id);
    await userRef.delete();
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
    final snapshot = await query.get();
    return snapshot.docs.skip(paging.offset).map((e) => {...e.data(), idKey: e.id}).toList();
  }

  @override
  Future<JsonMap> update(JsonMap value, _) async {
    final id = value[idKey]! as String;
    final map = JsonMap.from(value)..remove(idKey);
    await firestore.collection(collection).doc(id).update(map);
    return value;
  }

  @override
  Future<JsonMap> create(JsonMap value) async {
    final result = await firestore.collection(collection).add(value);
    return {...value, idKey: result.id};
  }
}
