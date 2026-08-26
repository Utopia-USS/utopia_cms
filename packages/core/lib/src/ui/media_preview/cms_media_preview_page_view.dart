import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:utopia_cms/src/ui/media_preview/cms_media_type.dart';
import 'package:utopia_cms/src/ui/media_preview/state/cms_media_preview_page_state.dart';
import 'package:utopia_cms/src/ui/widget/video/cms_video_player.dart';
import 'package:utopia_save_file/utopia_save_file.dart';

/// Saves the previewed media to disk.
///
/// Goes through the BYTES rather than handing the remote URL straight to the
/// browser. `UtopiaSaveFile.fromUrl` marks an anchor with the `download`
/// attribute, and browsers ignore that attribute for cross-origin URLs - so a
/// CMS asset served from a storage bucket (the usual setup) opened in a new
/// tab instead of downloading. Fetching first makes the data same-origin, so
/// the browser saves it and honours the filename.
///
/// The fetch needs the asset host to allow cross-origin GETs. When it fails
/// for any reason - CORS, offline, a 404 - we fall back to the previous
/// behaviour rather than leaving the button dead.
Future<void> _download(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode >= 400) throw http.ClientException('HTTP ${response.statusCode}', Uri.parse(url));
    await UtopiaSaveFile.fromBytes(
      response.bodyBytes,
      mime: response.headers['content-type'] ?? 'application/octet-stream',
      name: _fileNameFrom(url),
    );
  } catch (_) {
    await UtopiaSaveFile.fromUrl(url);
  }
}

/// Last path segment of [url], ignoring the query string (storage URLs carry
/// access tokens there). Falls back to a generic name for URLs that end in a
/// slash.
String _fileNameFrom(String url) {
  final segments = Uri.parse(url).pathSegments.where((it) => it.isNotEmpty);
  if (segments.isEmpty) return 'download';
  return segments.last.split('/').last;
}

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
    return PageView.builder(
      controller: state.controller,
      physics: state.items.length > 1 ? null : const NeverScrollableScrollPhysics(),
      itemCount: state.items.length,
      itemBuilder: (_, index) {
        return Center(child: _buildItem(state.items[index]));
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
                child: const Icon(Icons.clear, color: Colors.white),
                onTap: () => Navigator.pop(context),
              ),
            ),
            const Spacer(),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                child: const Icon(Icons.download, color: Colors.white),
                onTap: () => _download(url),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrows(BuildContext context) {
    final animate = state.animateTo;
    final lastIndex = state.items.length - 1;
    final index = state.fixedIndex;
    return Center(
      child: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 80),
        child: Row(
          children: [
            _buildArrow(
              onPressed: () async => index == 0 ? animate(lastIndex) : animate(index - 1),
              icon: Icons.arrow_back_ios_rounded,
            ),
            const Spacer(),
            _buildArrow(
              icon: Icons.arrow_forward_ios_rounded,
              onPressed: () async => index == lastIndex ? animate(0) : animate(index + 1),
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
            Positioned(left: 2.0, top: 3.0, child: Icon(icon, color: Colors.black12)),
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
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: SizedBox(
          height: height,
          width: width,
          child: FittedBox(fit: BoxFit.cover, child: _buildBackgroundItem(state.items[state.fixedIndex])),
        ),
      ),
    );
  }

  Widget _buildBackgroundItem(dynamic item) {
    final url = urlBuilder?.call(item) ?? item as String;
    final type = mediaTypeBuilder(item);
    switch (type) {
      case CmsMediaType.video:
        return const SizedBox.shrink();
      case CmsMediaType.image:
        return Image.network(url);
      case CmsMediaType.doc:
        throw UnimplementedError();
      case CmsMediaType.unknown:
        throw UnimplementedError();
    }
  }
}
