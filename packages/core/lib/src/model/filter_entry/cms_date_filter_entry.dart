import 'package:flutter/material.dart';
import 'package:utopia_cms/src/model/cms_filter.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/filter_entry/cms_filter_entry.dart';
import 'package:utopia_cms/src/ui/widget/date_picker/cms_date_picker.dart';
import 'package:utopia_cms/src/util/json_map.dart';
import 'package:utopia_cms/src/util/map_extensions.dart';
import 'package:utopia_utils/utopia_utils.dart';

enum CmsFilterDateEntryMode { lesser, greater }

/// [CmsEntry] for handling basic dates
class CmsFilterDateEntry extends CmsFilterEntry<DateTime?> {
  final bool isSecondsSinceEpoch;
  final CmsFilterDateEntryMode mode;

  CmsFilterDateEntry({
    required this.filterKeys,
    required this.entryKey,
    this.mode = CmsFilterDateEntryMode.greater,
    this.label,
    this.isSecondsSinceEpoch = false,
    this.flex = 2,
  });

  @override
  final List<String> filterKeys;

  @override
  final int flex;

  @override
  final String? label;

  @override
  final String entryKey;

  @override
  Widget buildField({
    required BuildContext context,
    required DateTime? value,
    required void Function(DateTime value) onChanged,
  }) {


    return CmsDatePicker(date: value, label: fixedLabel, onDateChanged: onChanged);
  }

  @override
  Object? toJson(Object? value) {
    if (isSecondsSinceEpoch && value != null) return (value as DateTime).millisecondsSinceEpoch / 1000;
    return value?.toString();
  }

  @override
  DateTime? fromJson(Object? json) {
    if (isSecondsSinceEpoch && json != null) return _fromSecondsSinceEpoch(json as int);
    return json?.let((it) => DateTime.parse(it as String));
  }

  DateTime? _fromSecondsSinceEpoch(int? value){
    if(value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(value * 1000);
  }

  @override
  CmsFilter filterFromValues(JsonMap value) {
    final date = value.getAtPath(entryKey);
    if (filterKeys.isEmpty || date == null) return const CmsFilterAll();

    if (filterKeys.length == 1) return _buildFilter(filterKeys.first, date! as Object);

    return CmsFilterOr(filterKeys.map((e) => _buildFilter(filterKeys.first, date! as Object)).toList());
  }

  CmsFilter _buildFilter(String key, Object value) {
    switch (mode) {
      case CmsFilterDateEntryMode.lesser:
        return CmsFilterLesserOrEq(key, value);
      case CmsFilterDateEntryMode.greater:
        return CmsFilterGreaterOrEq(key, value);
    }
  }
}
