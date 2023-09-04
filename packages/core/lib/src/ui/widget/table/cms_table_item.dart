import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_cms/src/util/json_map.dart';
import 'package:utopia_cms/src/util/map_extensions.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class CmsTableItem extends HookWidget {
  final JsonMap data;
  final IList<CmsEntry<dynamic>> entries;
  final Widget Function(JsonMap)? actionsBuilder;
  final double tileHeight;
  final double actionsWidth;
  final Color color;
  final EdgeInsets contentPadding;
  final EdgeInsets itemPadding;
  final void Function()? onManagePressed;

  const CmsTableItem({super.key, 
    required this.data,
    required this.entries,
    required this.actionsWidth,
    required this.tileHeight,
    required this.contentPadding,
    required this.itemPadding,
    required this.color,
    required this.onManagePressed,
    this.actionsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final hoveringState = useState<bool>(false);
    return MouseRegion(
      onEnter: (_) => hoveringState.value = true,
      onExit: (_) => hoveringState.value = false,
      cursor: onManagePressed != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: onManagePressed,
        child: Container(
          height: tileHeight,
          padding: contentPadding,
          decoration: BoxDecoration(
            color: hoveringState.value ? context.colors.accent : color,
            borderRadius: context.theme.borderRadius,
          ),
          child: Row(
            children: [
              ...entries.map(
                (e) => Expanded(
                  flex: e.flex,
                  child: Padding(
                    padding: itemPadding,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: e.buildPreview(
                        context,
                        e.fromJson(data.getAtPath(e.key)),
                      ),
                    ),
                  ),
                ),
              ),
              if (actionsBuilder != null)
                Padding(
                  padding: itemPadding,
                  child: SizedBox(width: actionsWidth, child: actionsBuilder!(data)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
