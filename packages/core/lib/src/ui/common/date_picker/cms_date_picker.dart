import 'package:flutter/material.dart';
import 'package:utopia_cms/src/ui/common/text_field/cms_text_field.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_cms/src/util/date_time_extension.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class CmsDatePicker extends HookWidget {
  final DateTime? date;
  final String label;
  final void Function(DateTime)? onDateChanged;

  const CmsDatePicker({
    super.key,
    required this.date,
    this.onDateChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return CmsTextField(
      value: date?.toDisplayStringWithoutHours() ?? '',
      readOnly: true,
      label: Text(label),
      onChanged: (_) {},
      onTap: () async {
        final result = await showDatePicker(
          context: context,
          initialDate: date ?? now,
          firstDate: now.copyWith(year: now.year - 50),
          lastDate: now.copyWith(year: now.year + 50),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                primaryColor: context.colors.primary,
                colorScheme: ColorScheme.light(primary: context.colors.primary).copyWith(
                  secondary: context.colors.accent,
                ),
              ),
              child: child!,
            );
          },
        );
        if (result != null) onDateChanged?.call(result);
      },
    );
  }
}
