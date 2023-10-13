import 'package:cross_file/cross_file.dart';
import 'package:utopia_cms/src/delegate/media/cms_media_upload_res.dart';
import 'package:utopia_cms/utopia_cms.dart';

typedef CmsFileRef = String;

abstract class CmsMediaDelegate {
  Future<CmsMediaUploadRes> upload(XFile file);

  Future<void> delete(dynamic value);
}