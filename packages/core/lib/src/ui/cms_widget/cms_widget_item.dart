import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cms_widget_item.freezed.dart';

@freezed
class CmsWidgetItem with _$CmsWidgetItem {
  const CmsWidgetItem._();

  factory CmsWidgetItem.page({
    required Widget icon,
    required Widget title,
    required String id,
    required Widget content,
  }) = CmsWidgetItemPage;

  factory CmsWidgetItem.action({
    required Widget icon,
    required Widget title,
    required void Function() onPressed,
  }) = CmsWidgetItemAction;

  factory CmsWidgetItem.custom({
    int? flex,
    @Default(SizedBox()) Widget child,
  }) = CmsWidgetItemCustom;

  Widget get title => map(page: (it) => it.title, action: (it) => it.title, custom: (_) => const SizedBox.shrink());
  Widget get icon => map(page: (it) => it.icon, action: (it) => it.icon, custom: (_) => const SizedBox.shrink());

}
