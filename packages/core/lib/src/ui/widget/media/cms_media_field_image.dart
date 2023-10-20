import 'package:flutter/material.dart';

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
