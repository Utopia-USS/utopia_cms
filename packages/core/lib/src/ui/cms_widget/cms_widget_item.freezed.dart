// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cms_widget_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CmsWidgetItem {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            Widget icon, Widget title, String id, Widget content)
        page,
    required TResult Function(
            Widget icon, Widget title, void Function() onPressed)
        action,
    required TResult Function(int? flex, Widget child) custom,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Widget icon, Widget title, String id, Widget content)?
        page,
    TResult? Function(Widget icon, Widget title, void Function() onPressed)?
        action,
    TResult? Function(int? flex, Widget child)? custom,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Widget icon, Widget title, String id, Widget content)?
        page,
    TResult Function(Widget icon, Widget title, void Function() onPressed)?
        action,
    TResult Function(int? flex, Widget child)? custom,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CmsWidgetItemPage value) page,
    required TResult Function(CmsWidgetItemAction value) action,
    required TResult Function(CmsWidgetItemCustom value) custom,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CmsWidgetItemPage value)? page,
    TResult? Function(CmsWidgetItemAction value)? action,
    TResult? Function(CmsWidgetItemCustom value)? custom,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CmsWidgetItemPage value)? page,
    TResult Function(CmsWidgetItemAction value)? action,
    TResult Function(CmsWidgetItemCustom value)? custom,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CmsWidgetItemCopyWith<$Res> {
  factory $CmsWidgetItemCopyWith(
          CmsWidgetItem value, $Res Function(CmsWidgetItem) then) =
      _$CmsWidgetItemCopyWithImpl<$Res, CmsWidgetItem>;
}

/// @nodoc
class _$CmsWidgetItemCopyWithImpl<$Res, $Val extends CmsWidgetItem>
    implements $CmsWidgetItemCopyWith<$Res> {
  _$CmsWidgetItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$CmsWidgetItemPageImplCopyWith<$Res> {
  factory _$$CmsWidgetItemPageImplCopyWith(_$CmsWidgetItemPageImpl value,
          $Res Function(_$CmsWidgetItemPageImpl) then) =
      __$$CmsWidgetItemPageImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Widget icon, Widget title, String id, Widget content});
}

/// @nodoc
class __$$CmsWidgetItemPageImplCopyWithImpl<$Res>
    extends _$CmsWidgetItemCopyWithImpl<$Res, _$CmsWidgetItemPageImpl>
    implements _$$CmsWidgetItemPageImplCopyWith<$Res> {
  __$$CmsWidgetItemPageImplCopyWithImpl(_$CmsWidgetItemPageImpl _value,
      $Res Function(_$CmsWidgetItemPageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? title = null,
    Object? id = null,
    Object? content = null,
  }) {
    return _then(_$CmsWidgetItemPageImpl(
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as Widget,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as Widget,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as Widget,
    ));
  }
}

/// @nodoc

class _$CmsWidgetItemPageImpl extends CmsWidgetItemPage {
  _$CmsWidgetItemPageImpl(
      {required this.icon,
      required this.title,
      required this.id,
      required this.content})
      : super._();

  @override
  final Widget icon;
  @override
  final Widget title;
  @override
  final String id;
  @override
  final Widget content;

  @override
  String toString() {
    return 'CmsWidgetItem.page(icon: $icon, title: $title, id: $id, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CmsWidgetItemPageImpl &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content));
  }

  @override
  int get hashCode => Object.hash(runtimeType, icon, title, id, content);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CmsWidgetItemPageImplCopyWith<_$CmsWidgetItemPageImpl> get copyWith =>
      __$$CmsWidgetItemPageImplCopyWithImpl<_$CmsWidgetItemPageImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            Widget icon, Widget title, String id, Widget content)
        page,
    required TResult Function(
            Widget icon, Widget title, void Function() onPressed)
        action,
    required TResult Function(int? flex, Widget child) custom,
  }) {
    return page(icon, title, id, content);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Widget icon, Widget title, String id, Widget content)?
        page,
    TResult? Function(Widget icon, Widget title, void Function() onPressed)?
        action,
    TResult? Function(int? flex, Widget child)? custom,
  }) {
    return page?.call(icon, title, id, content);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Widget icon, Widget title, String id, Widget content)?
        page,
    TResult Function(Widget icon, Widget title, void Function() onPressed)?
        action,
    TResult Function(int? flex, Widget child)? custom,
    required TResult orElse(),
  }) {
    if (page != null) {
      return page(icon, title, id, content);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CmsWidgetItemPage value) page,
    required TResult Function(CmsWidgetItemAction value) action,
    required TResult Function(CmsWidgetItemCustom value) custom,
  }) {
    return page(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CmsWidgetItemPage value)? page,
    TResult? Function(CmsWidgetItemAction value)? action,
    TResult? Function(CmsWidgetItemCustom value)? custom,
  }) {
    return page?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CmsWidgetItemPage value)? page,
    TResult Function(CmsWidgetItemAction value)? action,
    TResult Function(CmsWidgetItemCustom value)? custom,
    required TResult orElse(),
  }) {
    if (page != null) {
      return page(this);
    }
    return orElse();
  }
}

abstract class CmsWidgetItemPage extends CmsWidgetItem {
  factory CmsWidgetItemPage(
      {required final Widget icon,
      required final Widget title,
      required final String id,
      required final Widget content}) = _$CmsWidgetItemPageImpl;
  CmsWidgetItemPage._() : super._();

  Widget get icon;
  Widget get title;
  String get id;
  Widget get content;
  @JsonKey(ignore: true)
  _$$CmsWidgetItemPageImplCopyWith<_$CmsWidgetItemPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CmsWidgetItemActionImplCopyWith<$Res> {
  factory _$$CmsWidgetItemActionImplCopyWith(_$CmsWidgetItemActionImpl value,
          $Res Function(_$CmsWidgetItemActionImpl) then) =
      __$$CmsWidgetItemActionImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Widget icon, Widget title, void Function() onPressed});
}

/// @nodoc
class __$$CmsWidgetItemActionImplCopyWithImpl<$Res>
    extends _$CmsWidgetItemCopyWithImpl<$Res, _$CmsWidgetItemActionImpl>
    implements _$$CmsWidgetItemActionImplCopyWith<$Res> {
  __$$CmsWidgetItemActionImplCopyWithImpl(_$CmsWidgetItemActionImpl _value,
      $Res Function(_$CmsWidgetItemActionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? title = null,
    Object? onPressed = null,
  }) {
    return _then(_$CmsWidgetItemActionImpl(
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as Widget,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as Widget,
      onPressed: null == onPressed
          ? _value.onPressed
          : onPressed // ignore: cast_nullable_to_non_nullable
              as void Function(),
    ));
  }
}

/// @nodoc

class _$CmsWidgetItemActionImpl extends CmsWidgetItemAction {
  _$CmsWidgetItemActionImpl(
      {required this.icon, required this.title, required this.onPressed})
      : super._();

  @override
  final Widget icon;
  @override
  final Widget title;
  @override
  final void Function() onPressed;

  @override
  String toString() {
    return 'CmsWidgetItem.action(icon: $icon, title: $title, onPressed: $onPressed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CmsWidgetItemActionImpl &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.onPressed, onPressed) ||
                other.onPressed == onPressed));
  }

  @override
  int get hashCode => Object.hash(runtimeType, icon, title, onPressed);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CmsWidgetItemActionImplCopyWith<_$CmsWidgetItemActionImpl> get copyWith =>
      __$$CmsWidgetItemActionImplCopyWithImpl<_$CmsWidgetItemActionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            Widget icon, Widget title, String id, Widget content)
        page,
    required TResult Function(
            Widget icon, Widget title, void Function() onPressed)
        action,
    required TResult Function(int? flex, Widget child) custom,
  }) {
    return action(icon, title, onPressed);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Widget icon, Widget title, String id, Widget content)?
        page,
    TResult? Function(Widget icon, Widget title, void Function() onPressed)?
        action,
    TResult? Function(int? flex, Widget child)? custom,
  }) {
    return action?.call(icon, title, onPressed);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Widget icon, Widget title, String id, Widget content)?
        page,
    TResult Function(Widget icon, Widget title, void Function() onPressed)?
        action,
    TResult Function(int? flex, Widget child)? custom,
    required TResult orElse(),
  }) {
    if (action != null) {
      return action(icon, title, onPressed);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CmsWidgetItemPage value) page,
    required TResult Function(CmsWidgetItemAction value) action,
    required TResult Function(CmsWidgetItemCustom value) custom,
  }) {
    return action(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CmsWidgetItemPage value)? page,
    TResult? Function(CmsWidgetItemAction value)? action,
    TResult? Function(CmsWidgetItemCustom value)? custom,
  }) {
    return action?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CmsWidgetItemPage value)? page,
    TResult Function(CmsWidgetItemAction value)? action,
    TResult Function(CmsWidgetItemCustom value)? custom,
    required TResult orElse(),
  }) {
    if (action != null) {
      return action(this);
    }
    return orElse();
  }
}

abstract class CmsWidgetItemAction extends CmsWidgetItem {
  factory CmsWidgetItemAction(
      {required final Widget icon,
      required final Widget title,
      required final void Function() onPressed}) = _$CmsWidgetItemActionImpl;
  CmsWidgetItemAction._() : super._();

  Widget get icon;
  Widget get title;
  void Function() get onPressed;
  @JsonKey(ignore: true)
  _$$CmsWidgetItemActionImplCopyWith<_$CmsWidgetItemActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CmsWidgetItemCustomImplCopyWith<$Res> {
  factory _$$CmsWidgetItemCustomImplCopyWith(_$CmsWidgetItemCustomImpl value,
          $Res Function(_$CmsWidgetItemCustomImpl) then) =
      __$$CmsWidgetItemCustomImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int? flex, Widget child});
}

/// @nodoc
class __$$CmsWidgetItemCustomImplCopyWithImpl<$Res>
    extends _$CmsWidgetItemCopyWithImpl<$Res, _$CmsWidgetItemCustomImpl>
    implements _$$CmsWidgetItemCustomImplCopyWith<$Res> {
  __$$CmsWidgetItemCustomImplCopyWithImpl(_$CmsWidgetItemCustomImpl _value,
      $Res Function(_$CmsWidgetItemCustomImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? flex = freezed,
    Object? child = null,
  }) {
    return _then(_$CmsWidgetItemCustomImpl(
      flex: freezed == flex
          ? _value.flex
          : flex // ignore: cast_nullable_to_non_nullable
              as int?,
      child: null == child
          ? _value.child
          : child // ignore: cast_nullable_to_non_nullable
              as Widget,
    ));
  }
}

/// @nodoc

class _$CmsWidgetItemCustomImpl extends CmsWidgetItemCustom {
  _$CmsWidgetItemCustomImpl({this.flex, this.child = const SizedBox()})
      : super._();

  @override
  final int? flex;
  @override
  @JsonKey()
  final Widget child;

  @override
  String toString() {
    return 'CmsWidgetItem.custom(flex: $flex, child: $child)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CmsWidgetItemCustomImpl &&
            (identical(other.flex, flex) || other.flex == flex) &&
            (identical(other.child, child) || other.child == child));
  }

  @override
  int get hashCode => Object.hash(runtimeType, flex, child);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CmsWidgetItemCustomImplCopyWith<_$CmsWidgetItemCustomImpl> get copyWith =>
      __$$CmsWidgetItemCustomImplCopyWithImpl<_$CmsWidgetItemCustomImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            Widget icon, Widget title, String id, Widget content)
        page,
    required TResult Function(
            Widget icon, Widget title, void Function() onPressed)
        action,
    required TResult Function(int? flex, Widget child) custom,
  }) {
    return custom(flex, child);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Widget icon, Widget title, String id, Widget content)?
        page,
    TResult? Function(Widget icon, Widget title, void Function() onPressed)?
        action,
    TResult? Function(int? flex, Widget child)? custom,
  }) {
    return custom?.call(flex, child);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Widget icon, Widget title, String id, Widget content)?
        page,
    TResult Function(Widget icon, Widget title, void Function() onPressed)?
        action,
    TResult Function(int? flex, Widget child)? custom,
    required TResult orElse(),
  }) {
    if (custom != null) {
      return custom(flex, child);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CmsWidgetItemPage value) page,
    required TResult Function(CmsWidgetItemAction value) action,
    required TResult Function(CmsWidgetItemCustom value) custom,
  }) {
    return custom(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CmsWidgetItemPage value)? page,
    TResult? Function(CmsWidgetItemAction value)? action,
    TResult? Function(CmsWidgetItemCustom value)? custom,
  }) {
    return custom?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CmsWidgetItemPage value)? page,
    TResult Function(CmsWidgetItemAction value)? action,
    TResult Function(CmsWidgetItemCustom value)? custom,
    required TResult orElse(),
  }) {
    if (custom != null) {
      return custom(this);
    }
    return orElse();
  }
}

abstract class CmsWidgetItemCustom extends CmsWidgetItem {
  factory CmsWidgetItemCustom({final int? flex, final Widget child}) =
      _$CmsWidgetItemCustomImpl;
  CmsWidgetItemCustom._() : super._();

  int? get flex;
  Widget get child;
  @JsonKey(ignore: true)
  _$$CmsWidgetItemCustomImplCopyWith<_$CmsWidgetItemCustomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
