import 'package:flutter/material.dart';
import 'package:utopia_cms/src/ui/attachment_preview/cms_media_preview_page_view.dart';
import 'package:utopia_cms/src/ui/attachment_preview/cms_media_type.dart';
import 'package:utopia_cms/src/ui/attachment_preview/state/cms_media_preview_page_state.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class CmsMediaPreviewPageArgs {
  final int initialIndex;
  final Iterable<dynamic> items;
  final String Function(dynamic object)? urlBuilder;
  final CmsMediaType Function(dynamic object) mediaTypeBuilder;

  const CmsMediaPreviewPageArgs({
    required this.items,
    required this.initialIndex,
    required this.urlBuilder,
    required this.mediaTypeBuilder,
  });
}

class CmsMediaPreviewPage extends HookWidget {
  final CmsMediaPreviewPageArgs args;
  final Animation<double> animation;

  const CmsMediaPreviewPage({super.key, required this.args, required this.animation});

  @override
  Widget build(BuildContext context) {
    final state = useCmsMediaPreviewPageState(
      initialIndex: args.initialIndex,
      items: args.items,
    );
    return CmsMediaPreviewPageView(
      state: state,
      urlBuilder: args.urlBuilder,
      mediaTypeBuilder: args.mediaTypeBuilder,
    );
  }
}
