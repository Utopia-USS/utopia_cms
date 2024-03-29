import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class CmsMediaFieldUpload extends HookWidget {
  final CmsMediaFieldState state;
  final CmsMediaDelegate delegate;
  final double size;
  final XFile file;
  final int index;
  final dynamic Function(CmsMediaUploadRes res, XFile file)? valueBuilder;

  const CmsMediaFieldUpload({
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
      () async {
        final result = await delegate.upload(file);
        final enhancedResult = valueBuilder?.call(result, file);
        state.onUploaded(index, enhancedResult ?? result.downloadUrl);
        uploadingState.value = false;
      },
      keys: [],
    );
    return CmsMediaFieldItemWrapper(
      key: Key(file.path),
      size: size,
      child: ColoredBox(
        color: context.colors.primary,
        child: const CmsLoader(color: Colors.white),
      ),
    );
  }
}
