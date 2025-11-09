import 'package:flutter/animation.dart';
import 'package:loop_page_view/loop_page_view.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class CmsMediaPreviewPageState {
  final LoopPageController controller;
  final List<dynamic> items;
  final Future<void> Function( int index) animateTo;
  final int initialIndex;

  const CmsMediaPreviewPageState({
    required this.controller,
    required this.items,
    required this.animateTo,
    required this.initialIndex,
  });

  int get fixedIndex => !controller.hasClients ? initialIndex : controller.page.round();
}

CmsMediaPreviewPageState useCmsMediaPreviewPageState({
  required int initialIndex,
  required Iterable<dynamic> items,
}) {
  final controller = useMemoized(() => LoopPageController(initialPage: initialIndex));
  useListenable(controller);
  Future<void> animateTo( int index) async {
    await controller.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  return CmsMediaPreviewPageState(
    controller: controller,
    items: items.toList(),
    animateTo: animateTo,
    initialIndex: initialIndex,
  );
}
