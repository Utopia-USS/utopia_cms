import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:utopia_cms/src/ui/widget/button/cms_remove_icon_button.dart';
import 'package:utopia_cms/src/ui/widget/text_field/cms_text_field.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

export 'package:country_code_picker/country_code_picker.dart';

class CmsCountryField extends HookWidget {
  final dynamic value;
  final Widget? label, error, hint;
  final Widget? prefix, suffix;
  final String Function(dynamic object)? displayBuilder;
  final dynamic Function(CountryCode value)? valueBuilder;

  final void Function(dynamic value) onChanged;

  const CmsCountryField({
    super.key,
    required this.value,
    required this.onChanged,
    this.valueBuilder,
    this.displayBuilder,
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
          final fixedValue = valueBuilder?.call(value) ?? value.code!;
          if (value.name != null) onChanged(fixedValue);
        },
        dialogTextStyle: textStyles.text,
        showCountryOnly: true,
        showOnlyCountryWhenClosed: true,
        initialSelection: null,
        searchDecoration: _buildDecoration(context),
        dialogSize: Size(540, MediaQuery.of(context).size.width),
        favorite: const ['GB', 'DE', 'US', 'NL', 'FR', 'AT', 'SE', 'PL', 'PT', 'CA', 'DK', 'CH'],
        builder: (_) {
          return CmsTextField(
            value: displayBuilder?.call(value) ?? value?.toString() ?? '',
            onChanged: onChanged,
            label: label,
            readOnly: true,
            suffix: CmsRemoveIconButton(onPressed: () => onChanged(null)),
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
      suffixIconColor: colors.primary,
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
