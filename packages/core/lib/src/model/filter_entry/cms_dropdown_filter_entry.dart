import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utopia_cms/src/model/cms_filter.dart';
import 'package:utopia_cms/src/model/filter_entry/cms_filter_entry.dart';
import 'package:utopia_cms/src/ui/widget/dropdown/cms_dropdown_field.dart';
import 'package:utopia_cms/src/util/json_map.dart';
import 'package:utopia_cms/src/util/map_extensions.dart';

/// [CmsFilterEntry] for handling basic dropdown search
class CmsFilterDropdownEntry<T> extends CmsFilterEntry {
  final List<TextInputFormatter>? formatters;
  @override
  final List<String> filterKeys;
  final List<T> values;

  CmsFilterDropdownEntry({
    required this.values,
    required this.filterKeys,
    required this.entryKey,
    this.label,
    this.formatters,
    this.flex = 4,
  });

  @override
  final String entryKey;

  @override
  final int flex;

  @override
  final String? label;

  @override
  Widget buildField({
    required BuildContext context,
    required FutureOr<dynamic>? value,
    required void Function(FutureOr<dynamic>? value) onChanged,
  }) {

    return CmsDropdownField(
      allowClear: true,
      value: value,
      onChanged: onChanged,
      values: values,
      label: label ?? '',
      valueLabelBuilder: (value) => value.toString(),
    );
  }

  @override
  CmsFilter filterFromValues(JsonMap value) {
    final searchValue = value.getAtPath(entryKey) as String?;
    if (filterKeys.isEmpty || searchValue == null || searchValue.isEmpty) return const CmsFilterAll();
    if (filterKeys.length == 1) {
      return CmsFilterContains(filterKeys.first, searchValue, caseSensitive: false);
    }
    return CmsFilterOr(
      filterKeys.map((e) => CmsFilterContains(e, searchValue, caseSensitive: false)).toList(),
    );
  }
}
