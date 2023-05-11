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
  Widget get icon => throw _privateConstructorUsedError;
  Widget get title => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            Widget icon, Widget title, String id, Widget content)
        page,
    required TResult Function(
            Widget icon, Widget title, void Function() onPressed)
        action,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Widget icon, Widget title, String id, Widget content)?
        page,
    TResult? Function(Widget icon, Widget title, void Function() onPressed)?
        action,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Widget icon, Widget title, String id, Widget content)?
        page,
    TResult Function(Widget icon, Widget title, void Function() onPressed)?
        action,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CmsWidgetItemPage value) page,
    required TResult Function(CmsWidgetItemAction value) action,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CmsWidgetItemPage value)? page,
    TResult? Function(CmsWidgetItemAction value)? action,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CmsWidgetItemPage value)? page,
    TResult Function(CmsWidgetItemAction value)? action,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CmsWidgetItemCopyWith<CmsWidgetItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CmsWidgetItemCopyWith<$Res> {
  factory $CmsWidgetItemCopyWith(
          CmsWidgetItem value, $Res Function(CmsWidgetItem) then) =
      _$CmsWidgetItemCopyWithImpl<$Res, CmsWidgetItem>;
  @useResult
  $Res call({Widget icon, Widget title});
}

/// @nodoc
class _$CmsWidgetItemCopyWithImpl<$Res, $Val extends CmsWidgetItem>
    implements $CmsWidgetItemCopyWith<$Res> {
  _$CmsWidgetItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? title = null,
  }) {
    return _then(_value.copyWith(
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as Widget,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as Widget,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CmsWidgetItemPageCopyWith<$Res>
    implements $CmsWidgetItemCopyWith<$Res> {
  factory _$$CmsWidgetItemPageCopyWith(
          _$CmsWidgetItemPage value, $Res Function(_$CmsWidgetItemPage) then) =
      __$$CmsWidgetItemPageCopyWithImpl<$Res>;
  @override
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

class _$CmsWidgetItemPage implements CmsWidgetItemPage {
  _$CmsWidgetItemPage(
      {required this.icon,
      required this.title,
      required this.id,
      required this.content});

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
  }) {
    return page(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CmsWidgetItemPage value)? page,
    TResult? Function(CmsWidgetItemAction value)? action,
  }) {
    return page?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CmsWidgetItemPage value)? page,
    TResult Function(CmsWidgetItemAction value)? action,
    required TResult orElse(),
  }) {
    if (page != null) {
      return page(this);
    }
    return orElse();
  }
}

abstract class CmsWidgetItemPage implements CmsWidgetItem {
  factory CmsWidgetItemPage(
      {required final Widget icon,
      required final Widget title,
      required final String id,
      required final Widget content}) = _$CmsWidgetItemPage;

  @override
  Widget get icon;
  @override
  Widget get title;
  String get id;
  Widget get content;
  @override
  @JsonKey(ignore: true)
  _$$CmsWidgetItemPageCopyWith<_$CmsWidgetItemPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CmsWidgetItemActionCopyWith<$Res>
    implements $CmsWidgetItemCopyWith<$Res> {
  factory _$$CmsWidgetItemActionCopyWith(_$CmsWidgetItemAction value,
          $Res Function(_$CmsWidgetItemAction) then) =
      __$$CmsWidgetItemActionCopyWithImpl<$Res>;
  @override
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

class _$CmsWidgetItemAction implements CmsWidgetItemAction {
  _$CmsWidgetItemAction(
      {required this.icon, required this.title, required this.onPressed});

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
  }) {
    return action(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CmsWidgetItemPage value)? page,
    TResult? Function(CmsWidgetItemAction value)? action,
  }) {
    return action?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CmsWidgetItemPage value)? page,
    TResult Function(CmsWidgetItemAction value)? action,
    required TResult orElse(),
  }) {
    if (action != null) {
      return action(this);
    }
    return orElse();
  }
}

abstract class CmsWidgetItemAction implements CmsWidgetItem {
  factory CmsWidgetItemAction(
      {required final Widget icon,
      required final Widget title,
      required final void Function() onPressed}) = _$CmsWidgetItemAction;

  @override
  Widget get icon;
  @override
  Widget get title;
  void Function() get onPressed;
  @override
  @JsonKey(ignore: true)
  _$$CmsWidgetItemActionCopyWith<_$CmsWidgetItemAction> get copyWith =>
      throw _privateConstructorUsedError;
}
