import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cms_widget_item.freezed.dart';

@freezed
class CmsWidgetItem with _$CmsWidgetItem {
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
}
