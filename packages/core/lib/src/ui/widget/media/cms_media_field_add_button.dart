import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:utopia_cms/src/ui/widget/media/cms_media_field_state.dart';
import 'package:utopia_cms/src/ui/widget/media/cms_media_field_item_wrapper.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';

class CmsMediaFieldAddButton extends StatelessWidget {
  final CmsMediaFieldState state;
  final double size;

  const CmsMediaFieldAddButton({
    super.key,
    required this.state,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: state.onSelectFilePressed,
        behavior: HitTestBehavior.opaque,
        child: CmsMediaFieldItemWrapper(
          size: size,
          hasShadow: false,
          color: state.isHighlighted.value ? context.colors.primary : context.colors.field,
          child: Stack(
            children: [
              DropzoneView(
                onCreated: state.onCreated,
                onDropFile: state.onDropFile,
                onHover: state.setHighlightedTrue,
                onLeave: state.setHighlightedFalse,
              ),
              Positioned.fill(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.upload, color: context.textStyles.text.color, size: 36),
                      SizedBox(height: 8),
                      SizedBox(
                        width: size / 3 * 2,
                        child: Text(
                          "Drag & drop\nor tap to select",
                          style: context.textStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
