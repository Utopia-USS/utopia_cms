import 'package:cross_file/cross_file.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:utopia_cms/src/ui/attachment_preview/cms_media_type.dart';
import 'package:utopia_cms/src/ui/widget/file/cms_media_field_state.dart';
import 'package:utopia_cms/src/ui/widget/file/cms_media_field_wrapper.dart';
import 'package:utopia_cms/src/ui/widget/header/cms_title.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

class CmsFiledFieldUpload extends HookWidget {
  final CmsMediaFieldState state;
  final CmsMediaDelegate delegate;
  final double size;
  final XFile file;
  final int index;
  final dynamic Function(String url, XFile file)? valueBuilder;

  const CmsFiledFieldUpload({
    super.key,
    required this.size,
    required this.state,
    required this.delegate,
    required this.valueBuilder,
    required this.file,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final uploadingState = useState<bool>(true);
    useAutoComputedState(
      compute: () async {
        final result = await delegate.upload(file);
        final enhancedResult = valueBuilder?.call(result.downloadUrl, file);
        state.onUploaded(index, enhancedResult ?? result);
        uploadingState.value = false;
      },
      keys: [],
    );
    return CmsFileFieldWrapper(
      key: Key(file.path),
      size: size,
      child: ColoredBox(
        color: context.colors.primary,
        child: const CmsLoader(color: Colors.white),
      ),
    );
  }
}
