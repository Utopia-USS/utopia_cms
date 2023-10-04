import 'package:cross_file/cross_file.dart';
import 'package:utopia_cms/src/delegate/media/cms_media_upload_res.dart';

typedef CmsFileRef = String;

abstract class CmsMediaDelegate {
  Future<CmsMediaUploadRes> upload(XFile file);

  Future<void> delete(CmsFileRef ref);
}