import 'package:cross_file/cross_file.dart';

typedef CmsFileRef = String;

abstract class CmsMediaDelegate {
  Future<({String downloadUrl, CmsFileRef ref})> upload(XFile file);

  Future<void> delete(CmsFileRef ref);
}