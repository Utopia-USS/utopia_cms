import 'dart:async';

import 'package:flutter/material.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/entry/cms_entry_modifier.dart';
import 'package:utopia_cms/src/ui/widget/country_picker/cms_country_field.dart';
import 'package:utopia_cms/src/ui/widget/table/cms_table_preview_text.dart';

/// [CmsEntry] for picking countries
class CmsCountryEntry extends CmsEntry<dynamic> {
  final TextOverflow? overflow;
  final String Function(dynamic object)? displayBuilder;
  final dynamic Function(CountryCode value)? valueBuilder;

  CmsCountryEntry({
    required this.key,
    this.valueBuilder,
    this.displayBuilder,
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
  Widget buildPreview(BuildContext context, dynamic value) => CmsTablePreviewText(
        displayBuilder?.call(value) ?? value?.toString() ?? '-',
      );

  @override
  Widget buildEditField({
    required BuildContext context,
    required FutureOr<dynamic>? value,
    required void Function(dynamic value) onChanged,
  }) {
    return CmsCountryField(
      key: Key(key),
      value: value,
      onChanged: onChanged,
      displayBuilder: displayBuilder,
      valueBuilder: valueBuilder,
      label: Text(fixedLabelRequired, overflow: overflow),
    );
  }
}
