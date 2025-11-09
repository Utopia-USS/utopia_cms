import 'package:flutter/material.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class CmsMediaFieldItemWrapper extends HookWidget {
  final Widget child;
  final double size;
  final bool hasShadow;
  final void Function()? onRemove;
  final void Function()? onOpen;
  final Color? color;

  const CmsMediaFieldItemWrapper({
    super.key,
    required this.size,
    required this.child,
    this.onRemove,
    this.onOpen,
    this.hasShadow = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final hoverState = useState<bool>(false);

    return MouseRegion(
      onEnter: (_) => hoverState.value = true,
      onExit: (_) => hoverState.value = false,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? context.colors.disabled,
          borderRadius: context.theme.borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
          ].takeIf((it) => hasShadow),
        ),
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: hoverState.value ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: _buildHover(context),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildHover(BuildContext context) {
    return HookBuilder(
      builder: (context) {
        final removeHoverState = useState<bool>(false);
        final openHoverState = useState<bool>(false);

        return Column(
          children: [
            if (onOpen != null)
              _buildHoverItem(
                title: 'Open',
                state: openHoverState,
                color: context.colors.primary,
                onPressed: onOpen!,
                context: context,
                flex: 2,
              ),
            if (onOpen != null)
              _buildHoverItem(
                title: 'Remove',
                state: removeHoverState,
                color: context.colors.error,
                onPressed: onRemove!,
                context: context,
                flex: 1,
              ),
          ],
        );
      },
    );
  }

  Widget _buildHoverItem({
    required String title,
    required MutableValue<bool> state,
    required Color color,
    required void Function() onPressed,
    required BuildContext context,
    required int flex,
  }) {
    const defaultBackground = Colors.black45;
    return Expanded(
      flex: flex,
      child: MouseRegion(
        onEnter: (_) => state.value = true,
        onExit: (_) => state.value = false,
        child: GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            width: size,
            duration: const Duration(milliseconds: 100),
            color: state.value ? Colors.white.withValues(alpha: 0.95) : defaultBackground,
            child: Center(
              child: Text(
                title,
                style: context.textStyles.button.copyWith(color: state.value ? Colors.black87 : Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
