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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

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
abstract class _$$CmsWidgetItemPageCopyWith<$Res> {
  factory _$$CmsWidgetItemPageCopyWith(
          _$CmsWidgetItemPage value, $Res Function(_$CmsWidgetItemPage) then) =
      __$$CmsWidgetItemPageCopyWithImpl<$Res>;
  @useResult
  $Res call({Widget icon, Widget title, String id, Widget content});
}

/// @nodoc
class __$$CmsWidgetItemPageCopyWithImpl<$Res>
    extends _$CmsWidgetItemCopyWithImpl<$Res, _$CmsWidgetItemPage>
    implements _$$CmsWidgetItemPageCopyWith<$Res> {
  __$$CmsWidgetItemPageCopyWithImpl(
      _$CmsWidgetItemPage _value, $Res Function(_$CmsWidgetItemPage) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? title = null,
    Object? id = null,
    Object? content = null,
  }) {
    return _then(_$CmsWidgetItemPage(
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

class _$CmsWidgetItemPage extends CmsWidgetItemPage {
  _$CmsWidgetItemPage(
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
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CmsWidgetItemPage &&
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
  _$$CmsWidgetItemPageCopyWith<_$CmsWidgetItemPage> get copyWith =>
      __$$CmsWidgetItemPageCopyWithImpl<_$CmsWidgetItemPage>(this, _$identity);

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
      required final Widget content}) = _$CmsWidgetItemPage;
  CmsWidgetItemPage._() : super._();

  Widget get icon;
  Widget get title;
  String get id;
  Widget get content;
  @JsonKey(ignore: true)
  _$$CmsWidgetItemPageCopyWith<_$CmsWidgetItemPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CmsWidgetItemActionCopyWith<$Res> {
  factory _$$CmsWidgetItemActionCopyWith(_$CmsWidgetItemAction value,
          $Res Function(_$CmsWidgetItemAction) then) =
      __$$CmsWidgetItemActionCopyWithImpl<$Res>;
  @useResult
  $Res call({Widget icon, Widget title, void Function() onPressed});
}

/// @nodoc
class __$$CmsWidgetItemActionCopyWithImpl<$Res>
    extends _$CmsWidgetItemCopyWithImpl<$Res, _$CmsWidgetItemAction>
    implements _$$CmsWidgetItemActionCopyWith<$Res> {
  __$$CmsWidgetItemActionCopyWithImpl(
      _$CmsWidgetItemAction _value, $Res Function(_$CmsWidgetItemAction) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? title = null,
    Object? onPressed = null,
  }) {
    return _then(_$CmsWidgetItemAction(
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

class _$CmsWidgetItemAction extends CmsWidgetItemAction {
  _$CmsWidgetItemAction(
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
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CmsWidgetItemAction &&
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
  _$$CmsWidgetItemActionCopyWith<_$CmsWidgetItemAction> get copyWith =>
      __$$CmsWidgetItemActionCopyWithImpl<_$CmsWidgetItemAction>(
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
      required final void Function() onPressed}) = _$CmsWidgetItemAction;
  CmsWidgetItemAction._() : super._();

  Widget get icon;
  Widget get title;
  void Function() get onPressed;
  @JsonKey(ignore: true)
  _$$CmsWidgetItemActionCopyWith<_$CmsWidgetItemAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CmsWidgetItemCustomCopyWith<$Res> {
  factory _$$CmsWidgetItemCustomCopyWith(_$CmsWidgetItemCustom value,
          $Res Function(_$CmsWidgetItemCustom) then) =
      __$$CmsWidgetItemCustomCopyWithImpl<$Res>;
  @useResult
  $Res call({int? flex, Widget child});
}

/// @nodoc
class __$$CmsWidgetItemCustomCopyWithImpl<$Res>
    extends _$CmsWidgetItemCopyWithImpl<$Res, _$CmsWidgetItemCustom>
    implements _$$CmsWidgetItemCustomCopyWith<$Res> {
  __$$CmsWidgetItemCustomCopyWithImpl(
      _$CmsWidgetItemCustom _value, $Res Function(_$CmsWidgetItemCustom) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? flex = freezed,
    Object? child = null,
  }) {
    return _then(_$CmsWidgetItemCustom(
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

class _$CmsWidgetItemCustom extends CmsWidgetItemCustom {
  _$CmsWidgetItemCustom({this.flex, this.child = const SizedBox()}) : super._();

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
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CmsWidgetItemCustom &&
            (identical(other.flex, flex) || other.flex == flex) &&
            (identical(other.child, child) || other.child == child));
  }

  @override
  int get hashCode => Object.hash(runtimeType, flex, child);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CmsWidgetItemCustomCopyWith<_$CmsWidgetItemCustom> get copyWith =>
      __$$CmsWidgetItemCustomCopyWithImpl<_$CmsWidgetItemCustom>(
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
      _$CmsWidgetItemCustom;
  CmsWidgetItemCustom._() : super._();

  int? get flex;
  Widget get child;
  @JsonKey(ignore: true)
  _$$CmsWidgetItemCustomCopyWith<_$CmsWidgetItemCustom> get copyWith =>
      throw _privateConstructorUsedError;
}
