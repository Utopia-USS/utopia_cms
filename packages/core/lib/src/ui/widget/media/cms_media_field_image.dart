import 'package:flutter/material.dart';
import 'package:utopia_cms/src/ui/widget/media/cms_media_field_wrapper.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class CmsMediaFieldImage extends StatelessWidget {
  final String url;

  const CmsMediaFieldImage({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
    );
  }
}
