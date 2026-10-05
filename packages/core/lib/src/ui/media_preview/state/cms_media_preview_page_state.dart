import 'package:flutter/widgets.dart';
import 'package:utopia_cms/src/util/foundation.dart';

class CmsMediaPreviewPageState {
  final PageController controller;
  final List<dynamic> items;
  final Future<void> Function(int index) animateTo;
  final int initialIndex;

  const CmsMediaPreviewPageState({
    required this.controller,
    required this.items,
    required this.animateTo,
    required this.initialIndex,
  });

  int get fixedIndex => controller.hasClients ? (controller.page?.round() ?? initialIndex) : initialIndex;
}

CmsMediaPreviewPageState useCmsMediaPreviewPageState({required int initialIndex, required Iterable<dynamic> items}) {
  final controller = useMemoized(() => PageController(initialPage: initialIndex), const [], (it) => it.dispose());
  useListenable(controller);
  Future<void> animateTo(int index) async {
    await controller.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  return CmsMediaPreviewPageState(
    controller: controller,
    items: items.toList(),
    animateTo: animateTo,
    initialIndex: initialIndex,
  );
}
