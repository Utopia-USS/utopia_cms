import 'package:flutter/material.dart';
import 'package:utopia_arch/utopia_arch.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';

class CmsTitle extends StatelessWidget {
  final String title;

  const CmsTitle({
    super.key,
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textStyles.title,
    );
  }
}
