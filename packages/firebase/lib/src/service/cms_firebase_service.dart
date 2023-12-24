import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_cms_firebase/src/util/cms_firebase_filter_helper.dart';
import 'package:utopia_utils/utopia_utils.dart';

class CmsFirebaseService {
  const CmsFirebaseService();

  Future<List<JsonMap>> query({
    required String collection,
    required String idKey,
    CmsFunctionsPagingParams? paging,
    CmsFilter filter = const CmsFilter.all(),
    CmsFunctionsSortingParams? sorting,
  }) async {
    Query<Map<String, dynamic>> collectionReference = await FirebaseFirestore.instance.collection(collection);

    if (sorting != null) collectionReference = await collectionReference.orderBy(sorting.fieldKey, descending: sorting.sortDesc);
    if (paging != null && paging.limit != null) collectionReference = await collectionReference.limit(paging.limit! + paging.offset);
    //TODO add startAfter to optimize
    final firebaseFilter = _buildFilter(filter);
    if (firebaseFilter != null) collectionReference = collectionReference.where(firebaseFilter);

    final result = await collectionReference.get().then((value) => value.docs.map((e) => {...e.data(), idKey: e.id}).toList());
    return result;
  }

  Filter? _buildFilter(CmsFilter filter, {bool negate = false}) {
    return filter.when(
      all: () => negate ? Filter("notExist", isEqualTo: "") : null,
      //workaround to cover all possible cases
      equals: (field, value) => negate ? _buildFilter(CmsFilter.not(filter)) : Filter(field, isEqualTo: value),
      notEquals: (field, value) => negate ? _buildFilter(CmsFilter.not(filter)) : Filter(field, isNotEqualTo: value),
      and: (filters) => negate ? _buildOr(filters, negate) : _buildAnd(filters, negate),
      or: (filters) => negate ? _buildAnd(filters, negate) : _buildOr(filters, negate),
      not: (filter) => _buildFilter(filter, negate: !negate),
      //TODO not working with not
      greaterOrEq: (field, value) => negate ? _buildFilter(CmsFilter.not(filter)) : Filter(field, isGreaterThanOrEqualTo: value),
      lesserOrEq: (field, value) => negate ? _buildFilter(CmsFilter.not(filter)) : Filter(field, isLessThanOrEqualTo: value),
      inList: (field, values) => negate ? _buildFilter(CmsFilter.not(filter)) : Filter(field, whereIn: values),
      containsString: (field, value, caseSensitive) => negate
          ? Filter.or(Filter(field, isLessThan: value), Filter(field, isGreaterThanOrEqualTo: value + '\uf8ff'))
          : Filter.and(Filter(field, isGreaterThanOrEqualTo: value), Filter(field, isLessThan: value + '\uf8ff')),
    );
  }

  Filter? _buildOr(List<CmsFilter> filters, bool negate) {
    final firebaseFilters = filters.map((filter) => _buildFilter(filter, negate: negate)).toList();
    if (firebaseFilters.contains(null)) return null;
    return CmsFirebaseFilterHelper.buildOrFilter(firebaseFilters);
  }

  Filter? _buildAnd(List<CmsFilter> filters, bool negate) {
    final firebaseFilters = filters.map((filter) => _buildFilter(filter, negate: negate)).whereNotNull().toList();
    return CmsFirebaseFilterHelper.buildAndFilter(firebaseFilters);
  }
}
