import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utopia_cms/utopia_cms.dart';

class CmsFirebaseDelegate implements CmsDelegate {
  final String collection;

  @override
  final String idKey;

  const CmsFirebaseDelegate(this.collection, {this.idKey = 'id'});

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
    final values = await FirebaseFirestore.instance.collection(collection).limit(30).get();
    return values.docs.map((e) => {...e.data(), idKey: e.id}).toList();
  }

  @override
  Future<JsonMap> update(JsonMap value) async {
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
