import 'package:flutter/material.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';

class CmsSwitch extends StatelessWidget {
  final bool value;
  final void Function(bool)? onChanged;
  final bool readOnly;

  const CmsSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IgnorePointer(
      ignoring: readOnly,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Switch(
          activeTrackColor: colors.primary,
          inactiveTrackColor: colors.disabled,
          inactiveThumbColor: Colors.white,
          activeColor: Colors.white,
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
