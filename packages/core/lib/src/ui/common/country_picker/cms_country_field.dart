import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:utopia_cms/src/ui/common/text_field/cms_text_field.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class CmsCountryField extends HookWidget {
  final String value;
  final Widget? label, error, hint;
  final Widget? prefix, suffix;

  final void Function(String name) onChanged;

  const CmsCountryField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.error,
    this.hint,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Theme(
      data: ThemeData(
        iconTheme: IconThemeData(color: colors.primary),
      primaryColor: colors.primary,
      ),
      child: CountryCodePicker(
        onChanged: (value) {
          if (value.name != null) onChanged(value.name!);
        },
        dialogTextStyle: textStyles.text,
        showCountryOnly: true,
        showOnlyCountryWhenClosed: true,
        initialSelection: null,
        searchDecoration: _buildDecoration(context),
        dialogSize: Size(540, MediaQuery.of(context).size.width),
        favorite: const ['GB', 'US', 'NL', 'FR', 'AT', 'SE', 'PL', 'PT', 'CA', 'DK', 'CH'],
        builder: (_) {
          return IgnorePointer(
            ignoring: true,
            child: CmsTextField(
              value: value,
              onChanged: onChanged,
              label: label,
              readOnly: true,
            ),
          );
        },
      ),
    );
  }

  InputDecoration _buildDecoration(BuildContext context) {
    final decoration = context.fieldDecoration;
    final values = context.theme;
    final textStyles = context.textStyles;
    final colors = context.colors;
    return InputDecoration(
      filled: true,
      iconColor: colors.primary,
      suffixIconColor:  colors.primary,
      fillColor: decoration.color,
      label: const Text("Search"),
      isDense: false,
      floatingLabelStyle: textStyles.label.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      labelStyle: textStyles.label,
      contentPadding: values.fieldContentPadding,
      border: OutlineInputBorder(
        borderRadius: values.borderRadius,
        borderSide: BorderSide(color: decoration.color!, width: 8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: values.borderRadius,
        borderSide: BorderSide(color: decoration.color!, width: 8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: values.borderRadius,
        borderSide: BorderSide(color: decoration.color!, width: 8),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: values.borderRadius,
        borderSide: BorderSide(color: decoration.color!, width: 8),
      ),
    );
  }
}
