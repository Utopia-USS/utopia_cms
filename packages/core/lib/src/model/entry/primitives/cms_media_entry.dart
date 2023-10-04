import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:utopia_cms/src/delegate/media/cms_media_upload_res.dart';
import 'package:utopia_cms/src/ui/widget/table/cms_table_preview_media.dart';
import 'package:utopia_cms/src/util/string_extensions.dart';
import 'package:utopia_cms/utopia_cms.dart';

/// [CmsEntry] for handling images
class CmsMediaEntry extends CmsEntry<Iterable<dynamic>?> {
  final CmsMediaDelegate delegate;
  final List<CmsMediaType> supportedMedia;

  /// Function that determines [CmsMediaType] based on object's JsonMap
  final CmsMediaType Function(dynamic object) mediaTypeBuilder;

  /// getter for url from object's JsonMap
  final String Function(dynamic object)? urlBuilder;

  /// Optional custom object created from upload response and file
  ///
  /// Entry returns String url if not provided
  final dynamic Function(CmsMediaUploadRes res, XFile file)? valueBuilder;

  CmsMediaEntry({
    required this.key,
    required this.delegate,
    required this.supportedMedia,
    required this.mediaTypeBuilder,
    this.urlBuilder,
    this.valueBuilder,
    this.label,
    this.modifier = const CmsEntryModifier(expanded: true),
    this.flex = 2,
  });

  @override
  final String key;

  @override
  final int flex;

  @override
  final String? label;

  @override
  final CmsEntryModifier modifier;

  @override
  Widget buildPreview(BuildContext context, Iterable<dynamic>? value) => CmsTablePreviewFile(
        media: value,
        urlBuilder: urlBuilder,
        mediaTypeBuilder: mediaTypeBuilder,
      );

  @override
  Widget buildEditField({
    required BuildContext context,
    required Iterable<dynamic>? value,
    required void Function(Iterable<dynamic>? value) onChanged,
  }) {
    return CmsMediaField(
      label: (label ?? key).modifyRequired(modifier.required),
      delegate: delegate,
      onChanged: onChanged,
      initialValues: value,
      urlBuilder: urlBuilder,
      valueBuilder: valueBuilder,
      supportedMedia: supportedMedia,
      mediaTypeBuilder: mediaTypeBuilder,
    );
  }
}
