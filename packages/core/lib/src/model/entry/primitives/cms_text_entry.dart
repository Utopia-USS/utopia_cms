import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/entry/cms_entry_modifier.dart';
import 'package:utopia_cms/src/ui/common/table/cms_table_preview_text.dart';
import 'package:utopia_cms/src/ui/common/text_field/cms_text_field.dart';

/// [CmsEntry] for handling basic String values
class CmsTextEntry extends CmsEntry<String> {
  final int maxLength;
  final int maxLines;

  final List<TextInputFormatter>? formatters;
  final TextOverflow? overflow;

  CmsTextEntry({
    required this.key,
    this.label,
    this.modifier = const CmsEntryModifier(),
    this.maxLength = 500,
    this.formatters,
    this.maxLines = 1,
    this.overflow,
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
  Widget buildPreview(BuildContext context, String? value) => CmsTablePreviewText(value);

  @override
  Widget buildEditField({
    required BuildContext context,
    required FutureOr<String>? value,
    required void Function(String value) onChanged,
  }) {
    return CmsTextField(
      key: Key(key),
      value: value as String? ?? '',
      onChanged: onChanged,
      maxLength: maxLength,
      lines: maxLines,
      formatters: formatters,
      label: Text(fixedLabelRequired, overflow: overflow),
    );
  }
}
