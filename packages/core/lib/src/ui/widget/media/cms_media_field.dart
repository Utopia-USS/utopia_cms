import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:utopia_arch/utopia_arch.dart';
import 'package:utopia_cms/src/ui/widget/media/cms_media_field_video_player.dart';
import 'package:utopia_cms/src/ui/widget/header/cms_title.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class CmsMediaField extends HookWidget {
  final String Function(dynamic object)? urlBuilder;
  final dynamic Function(CmsMediaUploadRes res, XFile file)? valueBuilder;
  final CmsMediaDelegate delegate;
  final String label;
  final void Function(Iterable<dynamic>?) onChanged;
  final Iterable<dynamic>? initialValues;
  final List<CmsMediaType> supportedMedia;
  final CmsMediaType Function(dynamic object) mediaTypeBuilder;

  const CmsMediaField({
    super.key,
    required this.label,
    required this.delegate,
    required this.onChanged,
    required this.initialValues,
    required this.urlBuilder,
    required this.valueBuilder,
    required this.supportedMedia,
    required this.mediaTypeBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final navigator = context.navigator;
    final state = useCmsMediaFieldState(
      delegate: delegate,
      initialValues: initialValues,
      onChanged: onChanged,
      supportedMedia: supportedMedia,
      urlBuilder: urlBuilder,
      mediaTypeBuilder: mediaTypeBuilder,
      navigator: navigator,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = context.theme.fieldContentPadding.left;
        final size = (constraints.maxWidth - spacing * 3) / 4;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CmsTitle(title: label),
            SizedBox(height: spacing),
            ReorderableWrap(
              enableReorder: !state.files.any((e) => e is XFile),
              needsLongPressDraggable: false,
              spacing: spacing,
              runSpacing: spacing,
              onReorder: state.onReorder,
              header: [CmsMediaFieldAddButton(state: state, size: size)],
              children: [
                for (int i = 0; i < state.files.length; i++)
                  if (state.files[i] is XFile)
                    CmsMediaFieldUpload(
                      size: size,
                      state: state,
                      delegate: delegate,
                      valueBuilder: valueBuilder,
                      file: state.files[i] as XFile,
                      index: i,
                    )
                  else
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: CmsFileFieldWrapper(
                        onOpen: () => state.onNavigateToPreview(i),
                        onRemove: () => state.onRemove(i),
                        size: size,
                        child: _buildUploadedItem(state.files[i], size),
                      ),
                    ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildUploadedItem(dynamic item, double size) {
    final url = urlBuilder?.call(item) ?? item as String;
    final type = mediaTypeBuilder(item);
    switch (type) {
      case CmsMediaType.video:
        return CmsMediaFieldVideoPlayer(url: url, size: size);
      case CmsMediaType.image:
        return CmsMediaFieldImage(url: url);
      case CmsMediaType.doc:
        throw UnimplementedError();
      case CmsMediaType.unknown:
        throw UnimplementedError();
    }
  }
}
