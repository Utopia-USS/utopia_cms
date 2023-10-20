
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:loop_page_view/loop_page_view.dart';
import 'package:utopia_cms/src/ui/attachment_preview/cms_media_type.dart';
import 'package:utopia_cms/src/ui/attachment_preview/state/cms_media_preview_page_state.dart';
import 'package:utopia_cms/src/ui/widget/video/cms_video_player.dart';
import 'package:utopia_save_file/utopia_save_file.dart';

class CmsMediaPreviewPageView extends StatelessWidget {
  final CmsMediaPreviewPageState state;
  final String Function(dynamic object)? urlBuilder;
  final CmsMediaType Function(dynamic object) mediaTypeBuilder;

  const CmsMediaPreviewPageView({
    super.key,
    required this.state,
    required this.urlBuilder,
    required this.mediaTypeBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final items = state.items;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              _buildBackground(height, width),
              SizedBox(
                height: height,
                width: width,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildContent(context, height, width),
                    if (items.length > 1) _buildArrows(context),
                    _buildTopControls(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, double maxHeight, double maxWidth) {
    return Center(
      child: SizedBox(
        width: maxWidth - 320,
        height: maxHeight - 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _buildMedia()),
            //const SizedBox(width: 32),
            //_buildSelector(),
          ],
        ),
      ),
    );
  }

//todo debug
  // Widget _buildSelector() {
  //   const size = 64.0;
  //   final items = state.items;
  //   return ListView.separated(
  //     scrollDirection: Axis.horizontal,
  //     itemCount: items.length,
  //     shrinkWrap: true,
  //     separatorBuilder: (_, __) => const SizedBox(width: 12),
  //     itemBuilder: (context, index) {
  //       return CmsMediaPreviewItem(
  //         item: items[index],
  //         mediaTypeBuilder: mediaTypeBuilder,
  //         urlBuilder: urlBuilder,
  //         size: size,
  //         onPressed: () async => state.animateTo(index),
  //       );
  //     },
  //   );
  // }

  Widget _buildMedia() {
    return LoopPageView.builder(
      controller: state.controller,
      physics: state.items.length > 1 ? null : NeverScrollableScrollPhysics(),
      itemCount: state.items.length,
      itemBuilder: (_, index) {
        return Center(
          child: _buildItem(state.items[index]),
        );
      },
    );
  }

  Widget _buildTopControls(BuildContext context) {
    final currentItem = state.items[state.fixedIndex];
    final url = urlBuilder?.call(currentItem) ?? currentItem as String;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
        child: Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                child: const Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                onTap: () => Navigator.pop(context),
              ),
            ),
            const Spacer(),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                child: const Icon(
                  Icons.download,
                  color: Colors.white,
                ),
                onTap: () async => UtopiaSaveFile.fromUrl(url), //=> download(mediaItems[controller.page.toInt()].url),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrows(BuildContext context) {
    final animate = state.animateTo;
    final controller = state.controller;
    return Center(
      child: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 80),
        child: Row(
          children: [
            _buildArrow(
              onPressed: () async =>
                  controller.page.round() == 0 ? animate(state.items.length - 1) : animate(controller.page.toInt() - 1),
              icon: Icons.arrow_back_ios_rounded,
            ),
            const Spacer(),
            _buildArrow(
              icon: Icons.arrow_forward_ios_rounded,
              onPressed: () async =>
                  controller.page.round() == state.items.length - 1  ? animate(0) : animate(controller.page.toInt() + 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrow({required IconData icon, required void Function() onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 2.0,
              top: 3.0,
              child: Icon(icon, color: Colors.black12),
            ),
            Icon(icon, color: Colors.white),
          ],
        ),
      ),
    );
  }


  Widget _buildItem(dynamic item) {
    final url = urlBuilder?.call(item) ?? item as String;
    final type = mediaTypeBuilder(item);
    switch (type) {
      case CmsMediaType.video:
        return CmsVideoPlayer(url: url);
      case CmsMediaType.image:
        return Image.network(url);
      case CmsMediaType.doc:
        throw UnimplementedError();
      case CmsMediaType.unknown:
        throw UnimplementedError();
    }
  }

  Widget _buildBackground(double height, double width) {

    return Opacity(
      opacity: 0.85,
      child: Blur(
        blur: 50,
        blurColor: Colors.transparent,
        child: SizedBox(
          height: height,
          width: width,
          child: FittedBox(
            fit: BoxFit.cover,
            child: _buildBackgroundItem(state.items[state.fixedIndex]),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundItem(dynamic item) {
    final url = urlBuilder?.call(item) ?? item as String;
    final type = mediaTypeBuilder(item);
    switch (type) {
      case CmsMediaType.video:
        return SizedBox.shrink();
      case CmsMediaType.image:
        return Image.network(url);
      case CmsMediaType.doc:
        throw UnimplementedError();
      case CmsMediaType.unknown:
        throw UnimplementedError();
    }
  }
}
