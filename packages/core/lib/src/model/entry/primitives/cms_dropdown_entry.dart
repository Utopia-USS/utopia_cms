import 'package:flutter/material.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/entry/cms_entry_modifier.dart';
import 'package:utopia_cms/src/ui/common/dropdown/cms_dropdown_field.dart';
import 'package:utopia_cms/src/ui/common/table/cms_table_preview_text.dart';

/// [CmsEntry] for handling offline items picker
class CmsDropdownEntry<T> extends CmsEntry<T> {
  final List<T> values;
  final T? defaultValue;
  final String Function(T? value) valueLabelBuilder;

  CmsDropdownEntry({
    required this.key,
    required this.values,
    required this.valueLabelBuilder,
    this.defaultValue,
    this.label,
    this.modifier = const CmsEntryModifier(),
    this.flex = 2,
  });

  CmsDropdownEntry.simple({
    required this.key,
    required this.values,
    required this.valueLabelBuilder,
    this.label,
    this.defaultValue,
    this.modifier = const CmsEntryModifier(),
    this.flex = 1,
  });

  @override
  final int flex;

  @override
  final String key;

  @override
  final String? label;

  @override
  final CmsEntryModifier modifier;

  @override
  Widget buildPreview(BuildContext context, T value) => CmsTablePreviewText(valueLabelBuilder(value));

  @override
  Widget buildEditField({
    required BuildContext context,
    required T? value,
    required void Function(T value) onChanged,
  }) {
    return IgnorePointer(
      ignoring: !modifier.editable,
      child: CmsDropdownField<T>(
        value: value ?? defaultValue,
        onChanged: onChanged,
        values: values,
        label: fixedLabelRequired,
        valueLabelBuilder: valueLabelBuilder,
      ),
    );
  }

}
