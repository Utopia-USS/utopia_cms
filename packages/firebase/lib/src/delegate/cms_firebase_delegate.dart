import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_firebase/src/service/cms_firebase_service.dart';

class CmsFirebaseDelegate implements CmsDelegate {
  final CmsFirebaseService _firebaseService = CmsFirebaseService();
  final String collection;

  @override
  final String idKey;

  CmsFirebaseDelegate({required this.collection, this.idKey = 'id'});

  @override
  Future<void> delete(JsonMap value) async {
    final id = value[idKey]! as String;
    final userRef = FirebaseFirestore.instance.collection(collection).doc(id);
    await userRef.delete();
  }

  @override
  Future<List<JsonMap>> get({
    CmsFunctionsSortingParams? sorting,
    CmsFilter? filter,
    required CmsFunctionsPagingParams paging,
  }) async {
    return _firebaseService.query(
      collection: collection,
      idKey: idKey,
      filter: filter!,//TODO null check
      paging: paging,
      sorting: sorting,
    );
  }

  @override
  Future<JsonMap> update(JsonMap value, _) async {
    final id = value[idKey]! as String;
    final map = JsonMap.from(value)..remove(idKey);
    await FirebaseFirestore.instance.collection(collection).doc(id).update(map);
    return value;
  }

  @override
  Future<JsonMap> create(JsonMap value) async {
    final result = await FirebaseFirestore.instance.collection(collection).add(value);
    return {...value, idKey: result.id};
  }
}
