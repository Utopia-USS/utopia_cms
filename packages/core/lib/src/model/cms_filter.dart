import 'package:freezed_annotation/freezed_annotation.dart';

part 'cms_filter.freezed.dart';

@freezed
class CmsFilter with _$CmsFilter {
  const factory CmsFilter.all() = CmsFilterAll;

  const factory CmsFilter.equals(String field, Object? value) = CmsFilterEquals;

  const factory CmsFilter.notEquals(String field, Object value) = CmsFilterNotEquals;

  const factory CmsFilter.containsString(String field, String value, {@Default(false) bool caseSensitive}) =
      CmsFilterContains;

  const factory CmsFilter.inList(String field, List<Object> values) = CmsFilterInList;

  const factory CmsFilter.and(List<CmsFilter> filters) = CmsFilterAnd;

  const factory CmsFilter.or(List<CmsFilter> filters) = CmsFilterOr;

  const factory CmsFilter.greaterOrEq(String field, Object value) = CmsFilterGreaterOrEq;

  const factory CmsFilter.greater(String field, Object value) = CmsFilterGreater;

  const factory CmsFilter.lesserOrEq(String field, Object value) = CmsFilterLesserOrEq;

  const factory CmsFilter.lesser(String field, Object value) = CmsFilterLesser;

  const factory CmsFilter.not(CmsFilter filter) = CmsFilterNot;
}

extension CmsFilterExtensions on CmsFilter {
  CmsFilter operator &(CmsFilter other) {
    final otherFilters = other is CmsFilterAnd ? other.filters : [other];
    return CmsFilterAnd(maybeWhen(and: (filters) => filters + otherFilters, orElse: () => [this, ...otherFilters]));
  }

  CmsFilter operator |(CmsFilter other) {
    final otherFilters = other is CmsFilterOr ? other.filters : [other];
    return CmsFilterOr(maybeWhen(or: (filters) => filters + otherFilters, orElse: () => [this, ...otherFilters]));
  }

  CmsFilter operator ~() {
    return maybeWhen(
      and: (filters) => CmsFilterOr([for (final filter in filters) ~filter]),
      or: (filters) => CmsFilterAnd([for (final filter in filters) ~filter]),
      orElse: () => CmsFilter.not(this),
    );
  }
}
