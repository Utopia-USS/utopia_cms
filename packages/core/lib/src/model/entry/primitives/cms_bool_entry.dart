import 'package:flutter/material.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/entry/cms_entry_modifier.dart';
import 'package:utopia_cms/src/ui/widget/switch/cms_switch.dart';
import 'package:utopia_cms/src/ui/widget/switch/cms_switch_field.dart';

/// [CmsEntry] for handling boolean values
class CmsBoolEntry extends CmsEntry<bool> {
  CmsBoolEntry({
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
  Widget buildPreview(BuildContext context, bool? value) {
    return CmsSwitch(
      readOnly: true,
      value: value ?? false,
    );
  }

  @override
  Widget buildEditField({
    required BuildContext context,
    required bool? value,
    required void Function(bool value) onChanged,
  }) {
    return CmsSwitchField(
      value: value ?? false,
      onChanged: onChanged,
      title: fixedLabelRequired,
    );
  }
}
