class CmsFunctionsSortingParams {
  final bool sortDesc;
  final String fieldKey;

  CmsFunctionsSortingParams({
    required this.sortDesc,
    required this.fieldKey,
  });
}

class CmsFunctionsPagingParams {
  final int offset;
  final int? limit;

  CmsFunctionsPagingParams({
    required this.offset,
    required this.limit,
  });
}
