import 'package:flutter/material.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';

class CmsConfirmDialog extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const CmsConfirmDialog({
    super.key,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final texts = context.textStyles;
    return AlertDialog(
      title: Text(title ?? "Delete item", style: texts.header),
      buttonPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      content: SizedBox(
        width: 360,
        child: Text(
          subtitle ?? "Are you sure you want to delete this item? You cannot undo this action.",
          style: texts.text,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            "Cancel",
            style: texts.label.copyWith(color: colors.primary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            "Proceed",
            style: texts.label,
          ),
        ),
      ],
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    String? title,
    String? subtitle,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => CmsConfirmDialog(
        title: title,
        subtitle: subtitle,
      ),
    );
  }
}
