import 'package:flutter/material.dart';
import 'package:utopia_cms/src/ui/widget/switch/cms_switch.dart';
import 'package:utopia_cms/src/ui/widget/wrapper/cms_field_wrapper.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';

class CmsSwitchField extends StatelessWidget {
  final bool value;
  final String title;
  final void Function(bool)? onChanged;
  final bool readOnly;

  const CmsSwitchField({
    super.key,
    required this.value,
    required this.title,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {

    return CmsFieldWrapper(
      child: Row(
        children: [
          Expanded(child: Text(title, style: context.textStyles.text)),
          CmsSwitch(value: value, onChanged: onChanged, readOnly: readOnly)
        ],
      ),
    );
  }
}
