import 'package:flutter/material.dart';
import 'package:utopia_cms/src/ui/widget/wrapper/cms_field_wrapper.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class CmsDropdownField<T> extends HookWidget {
  final T? value;
  final void Function(T) onChanged;
  final List<T> values;
  final String label;
  final String Function(T) valueLabelBuilder;

  const CmsDropdownField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.values,
    required this.label,
    required this.valueLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = context.textStyles.label;
    return CmsFieldWrapper(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: labelStyle),
        _buildDropDown(context),
      ],
    ));
  }

  Widget _buildDropDown(BuildContext context) {
    final style = context.textStyles.text;
    return DropdownButton<T>(
      value: value,
      elevation: 8,
      isDense: true,
      isExpanded: true,
      style: style,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      icon: Icon(Icons.arrow_downward, color: style.color, size: 14),
      underline: const SizedBox.shrink(),
      items: values.map<DropdownMenuItem<T>>(
        (value) {
          return DropdownMenuItem<T>(
            value: value,
            child: Text(
              valueLabelBuilder(value),
              style: style,
            ),
          );
        },
      ).toList(),
    );
  }
}
