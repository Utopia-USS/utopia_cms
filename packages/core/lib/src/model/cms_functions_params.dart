import 'package:freezed_annotation/freezed_annotation.dart';

part 'cms_functions_params.freezed.dart';

@freezed
class CmsFunctionsSortingParams with _$CmsFunctionsSortingParams {
  const factory CmsFunctionsSortingParams({
    required bool sortDesc,
    @Default(false) bool invertNulls,
    required String fieldKey,
  }) = _CmsFunctionsSortingParams;
}

class CmsFunctionsPagingParams {
  final int offset;
  final int? limit;

  CmsFunctionsPagingParams({
    required this.offset,
    required this.limit,
  });
}
