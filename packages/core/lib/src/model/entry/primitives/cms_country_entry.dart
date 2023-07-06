import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/entry/cms_entry_modifier.dart';
import 'package:utopia_cms/src/ui/common/country_picker/cms_country_field.dart';
import 'package:utopia_cms/src/ui/common/table/cms_table_preview_text.dart';
import 'package:utopia_cms/src/ui/common/text_field/cms_text_field.dart';

/// [CmsEntry] for picking countries
class CmsCountryEntry extends CmsEntry<String> {

  final TextOverflow? overflow;

  CmsCountryEntry({
    required this.key,
    this.label,
    this.modifier = const CmsEntryModifier(),
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
    return CmsCountryField(
      key: Key(key),
      value: value as String? ?? '',
      onChanged: onChanged,
      label: Text(fixedLabelRequired, overflow: overflow),
    );
  }
}
