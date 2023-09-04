import 'package:flutter/material.dart';
import 'package:utopia_cms/src/ui/attachment_preview/cms_media_type.dart';
import 'package:utopia_cms/src/ui/widget/file/cms_media_field_video_player.dart';
import 'package:utopia_widgets/misc/multi_widget.dart';

class CmsMediaPreviewItem extends StatelessWidget {
  final CmsMediaType Function(dynamic object) mediaTypeBuilder;
  final String Function(dynamic object)? urlBuilder;
  final dynamic item;
  final double size;
  final void Function()? onPressed;

  const CmsMediaPreviewItem({
    required this.item,
    required this.mediaTypeBuilder,
    this.urlBuilder,
    this.onPressed,
    this.size = 48,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiWidget(
      [
        if (onPressed != null) (child) => GestureDetector(onTap: onPressed, child: child),
        if (onPressed != null) (child) => MouseRegion(cursor: SystemMouseCursors.click, child: child),
        (_) => _buildWrapper(child: _buildItem(item)),
      ],
    );
  }

  Widget _buildWrapper({required Widget child, EdgeInsets? padding}) {
    return Container(
      height: size,
      width: size,
      margin: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 4)],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: child,
    );
  }

  Widget _buildItem(dynamic item) {
    final url = urlBuilder?.call(item) ?? item as String;
    final type = mediaTypeBuilder(item);
    switch (type) {
      case CmsMediaType.video:
        return CmsMediaFieldVideoPlayer(url: url, size: size);
      case CmsMediaType.image:
        return Image.network(url, fit: BoxFit.cover);
      case CmsMediaType.doc:
        throw UnimplementedError();
      case CmsMediaType.unknown:
        throw UnimplementedError();
    }
  }
}
