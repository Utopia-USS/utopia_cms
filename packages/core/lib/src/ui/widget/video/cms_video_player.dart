import 'package:flutter/material.dart';
import 'package:utopia_cms/src/ui/widget/loading/cms_loader.dart';
import 'package:utopia_cms/src/ui/widget/video/cms_video_player_state.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:video_player/video_player.dart';

export 'package:video_player/video_player.dart';

class CmsVideoPlayer extends HookWidget {
  final String url;
  final Widget Function(VideoPlayerController controller, Widget player)? playerBuilder;
  final bool previewOnly;

  const CmsVideoPlayer({
    super.key,
    required this.url,
    this.playerBuilder,
    this.previewOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final state = useCmsVidePlayerState(url: url);

    return IgnorePointer(
      ignoring: previewOnly,
      child: Focus(
        focusNode: state.focusNode,
        child: state.controller != null ? _buildVideo(state: state) : const CmsLoader(color: Colors.white),
      ),
    );
  }

  Widget _buildVideo({required CmsVideoPlayerState state}) {
    final controller = state.controller!;
    return Stack(
      alignment: Alignment.center,
      children: [
        if (playerBuilder != null)
          playerBuilder!(
            controller,
            AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller)),
          ),
        if (playerBuilder == null)
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        if (!previewOnly) _buildPlayButton(state),
      ],
    );
  }

  Widget _buildPlayButton (CmsVideoPlayerState state) {
    return Center(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => state.isPlayingState.value = !state.isPlayingState.value,
          child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 1.0,
            top: 2.0,
            child:  AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: state.animationController,
                  color: Colors.black12,
                  size: 30,
                ),

          ),
          AnimatedIcon(
            icon: AnimatedIcons.play_pause,
            progress: state.animationController,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
        ),
      ),
    );
  }
}
