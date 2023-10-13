// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cms_functions_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$CmsFunctionsSortingParams {
  bool get sortDesc => throw _privateConstructorUsedError;
  bool get invertNulls => throw _privateConstructorUsedError;
  String get fieldKey => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CmsFunctionsSortingParamsCopyWith<CmsFunctionsSortingParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CmsFunctionsSortingParamsCopyWith<$Res> {
  factory $CmsFunctionsSortingParamsCopyWith(CmsFunctionsSortingParams value,
          $Res Function(CmsFunctionsSortingParams) then) =
      _$CmsFunctionsSortingParamsCopyWithImpl<$Res, CmsFunctionsSortingParams>;
  @useResult
  $Res call({bool sortDesc, bool invertNulls, String fieldKey});
}

/// @nodoc
class _$CmsFunctionsSortingParamsCopyWithImpl<$Res,
        $Val extends CmsFunctionsSortingParams>
    implements $CmsFunctionsSortingParamsCopyWith<$Res> {
  _$CmsFunctionsSortingParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sortDesc = null,
    Object? invertNulls = null,
    Object? fieldKey = null,
  }) {
    return _then(_value.copyWith(
      sortDesc: null == sortDesc
          ? _value.sortDesc
          : sortDesc // ignore: cast_nullable_to_non_nullable
              as bool,
      invertNulls: null == invertNulls
          ? _value.invertNulls
          : invertNulls // ignore: cast_nullable_to_non_nullable
              as bool,
      fieldKey: null == fieldKey
          ? _value.fieldKey
          : fieldKey // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CmsFunctionsSortingParamsCopyWith<$Res>
    implements $CmsFunctionsSortingParamsCopyWith<$Res> {
  factory _$$_CmsFunctionsSortingParamsCopyWith(
          _$_CmsFunctionsSortingParams value,
          $Res Function(_$_CmsFunctionsSortingParams) then) =
      __$$_CmsFunctionsSortingParamsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool sortDesc, bool invertNulls, String fieldKey});
}

/// @nodoc
class __$$_CmsFunctionsSortingParamsCopyWithImpl<$Res>
    extends _$CmsFunctionsSortingParamsCopyWithImpl<$Res,
        _$_CmsFunctionsSortingParams>
    implements _$$_CmsFunctionsSortingParamsCopyWith<$Res> {
  __$$_CmsFunctionsSortingParamsCopyWithImpl(
      _$_CmsFunctionsSortingParams _value,
      $Res Function(_$_CmsFunctionsSortingParams) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sortDesc = null,
    Object? invertNulls = null,
    Object? fieldKey = null,
  }) {
    return _then(_$_CmsFunctionsSortingParams(
      sortDesc: null == sortDesc
          ? _value.sortDesc
          : sortDesc // ignore: cast_nullable_to_non_nullable
              as bool,
      invertNulls: null == invertNulls
          ? _value.invertNulls
          : invertNulls // ignore: cast_nullable_to_non_nullable
              as bool,
      fieldKey: null == fieldKey
          ? _value.fieldKey
          : fieldKey // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_CmsFunctionsSortingParams implements _CmsFunctionsSortingParams {
  const _$_CmsFunctionsSortingParams(
      {required this.sortDesc,
      this.invertNulls = false,
      required this.fieldKey});

  @override
  final bool sortDesc;
  @override
  @JsonKey()
  final bool invertNulls;
  @override
  final String fieldKey;

  @override
  String toString() {
    return 'CmsFunctionsSortingParams(sortDesc: $sortDesc, invertNulls: $invertNulls, fieldKey: $fieldKey)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CmsFunctionsSortingParams &&
            (identical(other.sortDesc, sortDesc) ||
                other.sortDesc == sortDesc) &&
            (identical(other.invertNulls, invertNulls) ||
                other.invertNulls == invertNulls) &&
            (identical(other.fieldKey, fieldKey) ||
                other.fieldKey == fieldKey));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sortDesc, invertNulls, fieldKey);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CmsFunctionsSortingParamsCopyWith<_$_CmsFunctionsSortingParams>
      get copyWith => __$$_CmsFunctionsSortingParamsCopyWithImpl<
          _$_CmsFunctionsSortingParams>(this, _$identity);
}

abstract class _CmsFunctionsSortingParams implements CmsFunctionsSortingParams {
  const factory _CmsFunctionsSortingParams(
      {required final bool sortDesc,
      final bool invertNulls,
      required final String fieldKey}) = _$_CmsFunctionsSortingParams;

  @override
  bool get sortDesc;
  @override
  bool get invertNulls;
  @override
  String get fieldKey;
  @override
  @JsonKey(ignore: true)
  _$$_CmsFunctionsSortingParamsCopyWith<_$_CmsFunctionsSortingParams>
      get copyWith => throw _privateConstructorUsedError;
}
