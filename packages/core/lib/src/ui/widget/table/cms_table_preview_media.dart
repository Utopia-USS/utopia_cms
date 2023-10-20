import 'dart:math';

import 'package:flutter/material.dart';
import 'package:utopia_cms/src/ui/attachment_preview/cms_media_type.dart';
import 'package:utopia_cms/src/ui/widget/media/cms_media_preview_item.dart';

class CmsTablePreviewFile extends StatelessWidget {
  final CmsMediaType Function(dynamic object) mediaTypeBuilder;
  final String Function(dynamic object)? urlBuilder;
  final Iterable<dynamic>? media;

  const CmsTablePreviewFile({
    required this.media,
    required this.mediaTypeBuilder,
    this.urlBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final fixedMedia = media?.toList() ?? [];
    if (fixedMedia.isEmpty) return const SizedBox.shrink();
    final count = min(4, fixedMedia.length);

    return Stack(
      alignment: Alignment.center,
      children: [
        for (int i = 0; i < count; i++)
          Positioned(
            left: 12.0 * i,
            child: Padding(
              padding: EdgeInsets.only(top: 4.0 * i, bottom: 4.0 * (count - i - 1)),
              child: CmsMediaPreviewItem(
                item: fixedMedia[i],
                mediaTypeBuilder: mediaTypeBuilder,
                urlBuilder: urlBuilder,
              ),
            ),
          ),
      ],
    );
  }
}
