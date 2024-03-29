import 'package:flutter/cupertino.dart';
import 'package:utopia_arch/utopia_arch.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_utils/utopia_utils.dart';
import 'package:video_player/video_player.dart';
import 'package:utopia_hooks/src/hook/flutter/misc/use_focus_node.dart';

final _dummyController = ValueNotifier(VideoPlayerValue.uninitialized());

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

  final controllerValue = useValueListenable(controllerState.value ?? _dummyController);
  final focusNode = useFocusNode();
  final animationController = useAnimationController(duration: Duration(milliseconds: 300));
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
    if (controllerValue.position == controllerValue.duration) {
      isPlayingState.value = false;
      await controllerState.value!.seekTo(Duration.zero);
    }
  }, [controllerValue]);

  return CmsVideoPlayerState(
    controller: controllerState.value,
    animationController: animationController,
    isPlayingState: isPlayingState,
    focusNode: focusNode,
  );
}
