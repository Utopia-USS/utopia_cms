import 'package:flutter/material.dart';
import 'package:utopia_cms/src/ui/widget/button/cms_remove_icon_button.dart';
import 'package:utopia_cms/src/ui/widget/text_field/cms_text_field.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_cms/src/util/date_time_extension.dart';
import 'package:utopia_cms/src/util/foundation.dart';

class CmsDatePicker extends HookWidget {
  final DateTime? date;
  final String label;
  final void Function(DateTime?)? onDateChanged;

  const CmsDatePicker({super.key, required this.date, this.onDateChanged, required this.label});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final result = await showDatePicker(
            context: context,
            initialDate: date?.toLocal() ?? now,
            firstDate: now.copyWith(year: now.year - 50),
            lastDate: now.copyWith(year: now.year + 50),
            builder: (context, child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  primaryColor: context.colors.primary,
                  colorScheme: ColorScheme.light(
                    primary: context.colors.primary,
                  ).copyWith(secondary: context.colors.accent),
                ),
                child: child!,
              );
            },
          );
          // Keep the stored flavor: a UTC-backed value stays UTC after re-picking.
          if (result != null) onDateChanged?.call(date?.isUtc ?? false ? result.toUtc() : result);
        },
        child: CmsTextField(
          value: date?.toDisplayStringWithoutHours() ?? '',
          readOnly: true,
          suffix: CmsRemoveIconButton(onPressed: () => onDateChanged?.call(null)),
          label: Text(label),
          onChanged: (_) {},
        ),
      ),
    );
  }
}
