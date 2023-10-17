import 'package:flutter/material.dart';
import 'package:utopia_cms/src/model/cms_filter.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/filter_entry/cms_filter_entry.dart';
import 'package:utopia_cms/src/ui/widget/date_picker/cms_date_picker.dart';
import 'package:utopia_cms/src/util/json_map.dart';
import 'package:utopia_cms/src/util/map_extensions.dart';

enum CmsFilterDateEntryMode { lesser, greater }

enum CmsFilterDateEntryUnit { dateTime, secondsSinceEpoch, millisecondsSinceEpoch, microsecondsSinceEpoch }

/// [CmsEntry] for handling basic dates
class CmsFilterDateEntry extends CmsFilterEntry<DateTime?> {
  final CmsFilterDateEntryUnit unit;
  final CmsFilterDateEntryMode mode;

  CmsFilterDateEntry({
    required this.filterKeys,
    required this.entryKey,
    this.label,
    this.flex = 2,
    this.mode = CmsFilterDateEntryMode.greater,
    this.unit = CmsFilterDateEntryUnit.dateTime,
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
    required void Function(DateTime? value) onChanged,
  }) {
    return CmsDatePicker(date: value, label: fixedLabel, onDateChanged: onChanged);
  }

  @override
  Object? toJson(Object? value) {
    if (value == null) return null;
    switch (unit) {
      case CmsFilterDateEntryUnit.dateTime:
        return value.toString();
      case CmsFilterDateEntryUnit.secondsSinceEpoch:
        return (value as DateTime).millisecondsSinceEpoch / 1000;
      case CmsFilterDateEntryUnit.millisecondsSinceEpoch:
        return (value as DateTime).millisecondsSinceEpoch;
      case CmsFilterDateEntryUnit.microsecondsSinceEpoch:
        return (value as DateTime).microsecondsSinceEpoch;
    }
  }

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    switch (unit) {
      case CmsFilterDateEntryUnit.dateTime:
        return DateTime.parse(json as String);
      case CmsFilterDateEntryUnit.secondsSinceEpoch:
        return DateTime.fromMillisecondsSinceEpoch((json as int) * 1000);
      case CmsFilterDateEntryUnit.millisecondsSinceEpoch:
        return DateTime.fromMillisecondsSinceEpoch(json as int);
      case CmsFilterDateEntryUnit.microsecondsSinceEpoch:
        return DateTime.fromMicrosecondsSinceEpoch(json as int);
    }
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
