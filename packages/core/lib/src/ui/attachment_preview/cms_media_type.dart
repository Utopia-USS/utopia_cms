import 'package:utopia_utils/utopia_utils.dart';

enum CmsMediaType {
  video(
    mimes: [
      'video/mp4',
      'video/webm',
      'video/quicktime',
      'video/x-m4v',
    ],
  ),
  image(
    mimes: [
      'image/jpeg',
      'image/png',
      'image/gif',
      'image/webp',
    ],
  ),
  doc(
    mimes: [
      'application/msword',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/pdf',
      'text/csv',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/epub+zip',
      'text/plain',
      'application/vnd.ms-powerpoint',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    ],
  ),
  unknown(mimes: []);

  const CmsMediaType({required this.mimes});

  final List<String> mimes;

  static CmsMediaType fromMime(String mime) {
    if (doc.mimes.contains(mime)) return doc;
    if (image.mimes.contains(mime)) return image;
    if (video.mimes.contains(mime)) return video;
    return unknown;
  }
}

extension CmsMediaTypeListExt on List<CmsMediaType> {
  List<String> get getMimes => expand((e) => e.mimes).toList().takeIf((e) => !contains(CmsMediaType.unknown)) ?? [];
}
