import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utopia_arch/utopia_arch.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/entry/cms_entry_modifier.dart';
import 'package:utopia_cms/src/ui/widget/table/cms_table_preview_text.dart';
import 'package:utopia_cms/src/ui/widget/text_field/cms_text_field.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

/// [CmsEntry] for handling basic num values
class CmsNumEntry extends CmsEntry<num?> {
  final bool isDecimal;
  final String Function(num?)? previewBuilder;
  late final List<FilteringTextInputFormatter> decimalInputFormatter;
  late final List<FilteringTextInputFormatter> nonDecimalInputFormatter;

  CmsNumEntry({
    required this.key,
    this.previewBuilder,
    this.label,
    this.modifier = const CmsEntryModifier(),
    this.isDecimal = false,
    this.flex = 2,
  }) {
    decimalInputFormatter = [
      FilteringTextInputFormatter.deny(',', replacementString: '.'),
      FilteringTextInputFormatter.allow(RegExp(r'^\d+[.,]?\d{0,4}')),
    ];
    nonDecimalInputFormatter = [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*')),
    ];
  }

  @override
  final String key;

  @override
  final int flex;

  @override
  final String? label;

  @override
  final CmsEntryModifier modifier;

  @override
  Widget buildPreview(BuildContext context, num? value) => CmsTablePreviewText(
        previewBuilder?.call(value) ?? value?.toString(),
      );

  @override
  Widget buildEditField({
    required BuildContext context,
    required num? value,
    required void Function(num? value) onChanged,
  }) {
    return HookBuilder(
      builder: (context) {
        final fieldState = useFieldState(initialValue: value?.toString() ?? '');
        return CmsTextField(
          key: Key(key),
          value: fieldState.value,
          onChanged: (value) {
            onChanged(num.tryParse(value));
            fieldState.value = value;
          },
          formatters: isDecimal ? decimalInputFormatter : nonDecimalInputFormatter,
          keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
          maxLength: 20,
          lines: 1,
          label: Text(fixedLabelRequired, overflow: TextOverflow.ellipsis),
        );
      },
    );
  }
}
