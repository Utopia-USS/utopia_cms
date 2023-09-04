import 'package:flutter/material.dart';
import 'package:utopia_cms/utopia_cms.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

export 'package:video_player/video_player.dart';

class CmsMediaFieldVideoPlayer extends HookWidget {
  final String url;
  final double size;

  const CmsMediaFieldVideoPlayer({super.key, required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return CmsVideoPlayer(
      previewOnly: true,
      url: url,
      playerBuilder: (controller, child) {
        return SizedBox.square(
          dimension: size,
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
