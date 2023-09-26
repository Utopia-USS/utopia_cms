import 'dart:async';
import 'dart:ui';

import 'package:cross_file/cross_file.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:utopia_arch/utopia_arch.dart';
import 'package:utopia_cms/src/delegate/cms_media_delegate.dart';
import 'package:utopia_cms/src/ui/attachment_preview/cms_media_preview_page.dart';
import 'package:utopia_cms/src/ui/attachment_preview/cms_media_type.dart';
import 'package:utopia_cms/src/ui/widget/dialog/cms_dialog.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';

class CmsMediaFieldState {
  final CmsMediaDelegate delegate;
  final IList<XFile> newFiles;
  final IList<dynamic> uploadedFiles;

  final MutableValue<bool> isHighlighted;

  final int itemCount;

  final void Function(int index, dynamic value) onUploaded;

  final void Function() setHighlightedTrue;
  final void Function() setHighlightedFalse;
  final void Function(DropzoneViewController) onCreated;
  final Future<void> Function(dynamic) onDropFile; //in flutter_dropzone docs this variable has to be dynamic
  final Future<void> Function() onSelectFilePressed;
  final void Function(int index) onNavigateToPreview;

  const CmsMediaFieldState({
    required this.isHighlighted,
    required this.delegate,
    required this.onDropFile,
    required this.onCreated,
    required this.onSelectFilePressed,
    required this.setHighlightedFalse,
    required this.setHighlightedTrue,
    required this.newFiles,
    required this.uploadedFiles,
    required this.onUploaded,
    required this.itemCount,
    required this.onNavigateToPreview,
  });
}

CmsMediaFieldState useCmsMediaFieldState({
  required CmsMediaDelegate delegate,
  required Iterable<dynamic>? initialValues,
  required List<CmsMediaType> supportedMedia,
  required void Function(Iterable<dynamic>? values) onChanged,
  required String Function(dynamic object)? urlBuilder,
  required CmsMediaType Function(dynamic object) mediaTypeBuilder,
  required NavigatorState navigator,
}) {
  final controller = useState<DropzoneViewController?>(null);
  final isHighlightedState = useState<bool>(false);

  final imagesState = useState<IList<XFile>>(<XFile>[].lock);
  final initialImagesState = useState<IList<dynamic>>(initialValues?.toIList() ?? IList());
  final uploadedImagesState = useState<IList<dynamic>>(IList());

  final context = useContext();

  Future<bool> checkMIME(dynamic event, DropzoneViewController controller) async {
    final mime = await controller.getFileMIME(event);

    final isCorrect = supportedMedia.getMimes.contains(mime);
    if (!isCorrect) {
      // ignore: use_build_context_synchronously
      unawaited(CmsDialog.show(
        context,
        title: "Incorrect file",
        subtitle: "Provided file has unsupported format",
        hasProceed: false,
      ));
    }
    return isCorrect;
  }

  Future<XFile> setUpXFile(dynamic file) async {
    final data = await controller.value!.getFileData(file);
    final mime = await controller.value!.getFileMIME(file);
    final size = await controller.value!.getFileSize(file);
    final name = await controller.value!.getFilename(file);
    return XFile.fromData(data, name: name, length: size, mimeType: mime);
  }

  Future<void> dropFile(dynamic file) async {
    if (controller.value != null) {
      final isImage = await checkMIME(file, controller.value!);
      isHighlightedState.value = false;
      if (isImage) {
        final xFile = await setUpXFile(file);
        imagesState.value = imagesState.value.add(xFile);
      } else {}
    }
  }

  Future<void> selectFiles() async {
    if (controller.value != null) {
      final files = await controller.value!.pickFiles(multiple: false, mime: supportedMedia.getMimes);
      final xFiles = await Future.wait(files.map((e) async => setUpXFile(e)));
      imagesState.value = imagesState.value.addAll(xFiles);
    }
  }

  useSimpleEffect(() {
    final values = uploadedImagesState.value + initialImagesState.value;
    onChanged(values.isEmpty ? null : values.unlock);
  }, [uploadedImagesState.value, initialImagesState.value]);

  final uploadedItems = initialImagesState.value + uploadedImagesState.value;

  Future<void> navigateToPreview(int index) async {
   await navigator.push<bool?>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, ___) => CmsMediaPreviewPage(
          args: CmsMediaPreviewPageArgs(
            items: uploadedItems,
            initialIndex: index,
            urlBuilder: urlBuilder,
              mediaTypeBuilder: mediaTypeBuilder,
          ),
          animation: animation,
        ),
      ),
    );
  }

  return CmsMediaFieldState(
    isHighlighted: isHighlightedState.asMutableValue(),
    setHighlightedTrue: () => isHighlightedState.value = true,
    setHighlightedFalse: () => isHighlightedState.value = false,
    onCreated: (value) => controller.value = value,
    onDropFile: dropFile,
    delegate: delegate,
    onSelectFilePressed: selectFiles,
    uploadedFiles: uploadedItems,
    newFiles: imagesState.value,
    onUploaded: (index, url) {
      uploadedImagesState.value = uploadedImagesState.value.add(url);
      imagesState.value = imagesState.value.removeAt(index);
    },
    itemCount: uploadedImagesState.value.length + initialImagesState.value.length,
    onNavigateToPreview: navigateToPreview,
  );
}
