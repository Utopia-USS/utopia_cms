import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utopia_cms/src/ui/widget/wrapper/cms_field_wrapper.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

class CmsTextField extends HookWidget {
  final String value;
  final TextInputType? keyboardType;
  final bool obscureText;
  final FocusNode? focusNode;
  final Widget? label, error, hint;
  final Widget? prefix, suffix;
  final List<TextInputFormatter>? formatters;
  final int? maxLength;
  final int lines;
  final bool readOnly;

  final void Function(String?) onChanged;
  final void Function()? onTap;

  const CmsTextField({
    super.key,
    required this.value,
    required this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.focusNode,
    this.label,
    this.error,
    this.hint,
    this.prefix,
    this.suffix,
    this.formatters,
    this.lines = 1,
    this.maxLength,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    return StatelessTextEditingControllerWrapper(
      value: value,
      onChanged: (value) => onChanged(value.isEmpty ? null : value),
      child: (controller) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (error != null) DefaultTextStyle(style: textStyles.caption.copyWith(color: colors.error), child: error!),
          _buildField(context, controller),
        ].separatedWith(const SizedBox(height: 6)),
      ),
    );
  }

  Widget _buildField(BuildContext context, TextEditingController controller) {
    return CmsFieldWrapper(
      includePadding: label == null,
      child: Row(
        children: [
          Flexible(child: _buildTextField(context, controller)),
          if(suffix != null) suffix!,
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller) {
    final textStyles = context.textStyles;
    return IgnorePointer(
      ignoring: readOnly,
      child: TextField(
        readOnly: readOnly,
        cursorColor: context.colors.primary,
        controller: controller,
        focusNode: focusNode,
        onTap: onTap,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textInputAction: TextInputAction.next,
        inputFormatters: formatters,
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          label: label,
          floatingLabelStyle: textStyles.label.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
          labelStyle: textStyles.label,
        ),
        style: textStyles.text,
      ),
    );
  }
}
