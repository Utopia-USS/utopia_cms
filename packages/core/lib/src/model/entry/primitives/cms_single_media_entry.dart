import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:utopia_cms/src/ui/widget/table/cms_table_preview_media.dart';
import 'package:utopia_cms/utopia_cms.dart';

/// Single-file variant of [CmsMediaEntry].
///
/// Stores a single object (typically the URL string returned by [valueBuilder])
/// directly in the [JsonMap] under [key], instead of a one-element list.
/// Useful for fields like a cover image where the storage shape is a scalar
/// and callers don't want to wrap / unwrap an iterable.
///
/// Internally renders a [CmsMediaField] capped at one file.
class CmsSingleMediaEntry extends CmsEntry<dynamic> {
  final CmsMediaDelegate delegate;
  final List<CmsMediaType> supportedMedia;

  /// Function that determines [CmsMediaType] based on object's JsonMap.
  final CmsMediaType Function(dynamic object) mediaTypeBuilder;

  /// Getter for url from object's JsonMap.
  final String Function(dynamic object)? urlBuilder;

  /// Optional custom object created from upload response and file.
  ///
  /// Entry stores `String` url under [key] if not provided.
  final dynamic Function(CmsMediaUploadRes res, XFile file)? valueBuilder;

  CmsSingleMediaEntry({
    required this.key,
    required this.delegate,
    required this.supportedMedia,
    required this.mediaTypeBuilder,
    this.urlBuilder,
    this.valueBuilder,
    this.label,
    this.modifier = const CmsEntryModifier(expanded: true),
    this.flex = 2,
    this.width,
  });

  @override
  final String key;

  @override
  final int? flex;

  @override
  final double? width;

  @override
  final String? label;

  @override
  final CmsEntryModifier modifier;

  @override
  Widget buildPreview(BuildContext context, dynamic value) {
    return CmsTablePreviewFile(
      media: value == null ? null : [value],
      urlBuilder: urlBuilder,
      mediaTypeBuilder: mediaTypeBuilder,
    );
  }

  @override
  Widget buildEditField({
    required BuildContext context,
    required dynamic value,
    required void Function(dynamic value) onChanged,
  }) {
    return CmsMediaField(
      label: fixedLabelRequired,
      delegate: delegate,
      onChanged: (values) {
        final list = values?.toList();
        onChanged(list == null || list.isEmpty ? null : list.first);
      },
      initialValues: value == null ? null : [value],
      urlBuilder: urlBuilder,
      valueBuilder: valueBuilder,
      supportedMedia: supportedMedia,
      mediaTypeBuilder: mediaTypeBuilder,
      maxFiles: 1,
    );
  }
}
