import 'package:flutter/material.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/entry/cms_entry_modifier.dart';
import 'package:utopia_cms/src/ui/common/date_picker/cms_date_picker.dart';
import 'package:utopia_cms/src/ui/common/table/cms_table_preview_text.dart';
import 'package:utopia_cms/src/util/date_time_extension.dart';
import 'package:utopia_utils/utopia_utils.dart';

/// [CmsEntry] for handling basic dates
class CmsDateEntry extends CmsEntry<DateTime?> {
  CmsDateEntry({
    required this.key,
    this.label,
    this.modifier = const CmsEntryModifier(),
    this.flex = 2,
  });

  @override
  final String key;

  @override
  final int flex;

  @override
  final String? label;

  @override
  final CmsEntryModifier modifier;

  @override
  Widget buildPreview(BuildContext context, DateTime? value) {
    return CmsTablePreviewText(value?.toDisplayStringWithoutHours());
  }

  @override
  Widget buildEditField({
    required BuildContext context,
    required DateTime? value,
    required void Function(DateTime value) onChanged,
  }) {
    return CmsDatePicker(date: value, label: fixedLabelRequired, onDateChanged: onChanged);
  }

  @override
  String? toJson(DateTime? value) => value?.toString();

  @override
  DateTime? fromJson(Object? json) => json?.let((it) => DateTime.parse(it as String));
}
