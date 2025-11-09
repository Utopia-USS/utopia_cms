import 'package:flutter/cupertino.dart';
import 'package:utopia_arch/utopia_arch.dart';
import 'package:video_player/video_player.dart';

class CmsVideoPlayerState {
  final VideoPlayerController? controller;
  final AnimationController animationController;
  final MutableValue<bool> isPlayingState;
  final FocusNode focusNode;

  const CmsVideoPlayerState({
    required this.controller,
    required this.animationController,
    required this.isPlayingState,
    required this.focusNode,
  });
}

CmsVideoPlayerState useCmsVidePlayerState({
  required String url,
}) {
  final controllerState = useState<VideoPlayerController?>(null);

  useEffect(() async {
    controllerState.value = null;
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize().then((_) => controllerState.value = controller);
  }, []);

  useEffect(() {
    return controllerState.value?.dispose;
  }, []);

  final controllerValue = useValueListenable(
      controllerState.value ?? ValueNotifier(const VideoPlayerValue.uninitialized()));
  final focusNode = useMemoized(FocusNode.new);
  final animationController = useAnimationController(duration: const Duration(milliseconds: 300));
  final isPlayingState = useState<bool>(false);

  useListenable(focusNode);

  useEffect(() {
    if (!focusNode.hasFocus) isPlayingState.value = false;
  }, [focusNode.hasFocus]);

  useEffect(() async {
    if (controllerState.value != null) {
      if (isPlayingState.value) {
        if (!focusNode.hasFocus) focusNode.requestFocus();
        await controllerState.value!.play();
        await animationController.forward();
      } else {
        await controllerState.value!.pause();
        await animationController.reverse();
      }
    }
  }, [isPlayingState.value]);

  useEffect(() async {
    if (controllerValue.duration != Duration.zero) {
      if (controllerValue.position == controllerValue.duration) {
        isPlayingState.value = false;
        await controllerState.value!.seekTo(Duration.zero);
      }
    }
  }, [controllerValue]);

  return CmsVideoPlayerState(
    controller: controllerState.value,
    animationController: animationController,
    isPlayingState: isPlayingState,
    focusNode: focusNode,
  );
}
