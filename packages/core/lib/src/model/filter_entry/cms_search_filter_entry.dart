import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utopia_cms/src/model/cms_filter.dart';
import 'package:utopia_cms/src/model/filter_entry/cms_filter_entry.dart';
import 'package:utopia_cms/src/ui/widget/text_field/cms_text_field.dart';
import 'package:utopia_cms/src/util/json_map.dart';
import 'package:utopia_cms/src/util/map_extensions.dart';

/// [CmsFilterEntry] for handling basic search
class CmsFilterSearchEntry extends CmsFilterEntry<String?> {
  final List<TextInputFormatter>? formatters;
  final List<String> filterKeys;

  CmsFilterSearchEntry({
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
    required FutureOr<String>? value,
    required void Function(String? value) onChanged,
  }) {
    return CmsTextField(
      key: Key(filterKeys.join()),
      value: value as String? ?? '',
      onChanged: onChanged,
      lines: 1,
      label: Text(fixedLabel, overflow: TextOverflow.ellipsis),
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
      filterKeys
          .map((e) => CmsFilterContains(e, searchValue, caseSensitive: false))
          .toList(),
    );
  }
}
