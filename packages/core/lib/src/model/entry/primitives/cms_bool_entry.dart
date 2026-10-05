import 'package:flutter/material.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/entry/cms_entry_modifier.dart';
import 'package:utopia_cms/src/ui/widget/switch/cms_switch.dart';
import 'package:utopia_cms/src/ui/widget/switch/cms_switch_field.dart';
import 'package:utopia_cms/src/util/string_extensions.dart';

/// [CmsEntry] for handling boolean values
class CmsBoolEntry extends CmsEntry<bool> {
  CmsBoolEntry({required this.key, this.label, this.modifier = const CmsEntryModifier(), this.flex = 2, this.width});

  @override
  final String key;

  @override
  final int? flex;

  @override
  final double? width;

  @override
  final String? label;

  @override
  final CmsEntryModifier modifier;

  /// Reads every shape a backend realistically stores a boolean as: a real
  /// [bool], `"true"` / `"false"` in any letter case, or `1` / `0`.
  ///
  /// The inherited [CmsEntry.fromJson] is a raw cast, so a stringified value
  /// took the whole table down with a [TypeError] thrown from inside the row
  /// builder - far from the column that caused it. A value that is still not a
  /// boolean throws a described [FormatException] instead.
  @override
  bool? fromJson(Object? json) => switch (json) {
    null => null,
    final bool value => value,
    final String value => value.parseBool(),
    final num value when value == 1 => true,
    final num value when value == 0 => false,
    _ => throw FormatException('Expected a bool, "true"/"false" or 1/0', json),
  };

  @override
  Widget buildPreview(BuildContext context, bool? value) => CmsSwitch(readOnly: true, value: value ?? false);

  @override
  Widget buildEditField({
    required BuildContext context,
    required bool? value,
    // ignore: avoid_positional_boolean_parameters
    required void Function(bool value) onChanged,
  }) {
    return CmsSwitchField(value: value ?? false, onChanged: onChanged, title: fixedLabelRequired);
  }
}
