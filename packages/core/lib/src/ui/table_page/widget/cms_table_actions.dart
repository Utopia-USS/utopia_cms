import 'package:flutter/material.dart';
import 'package:utopia_cms/src/model/table_action/cms_table_action.dart';
import 'package:utopia_cms/src/ui/widget/loading/cms_loader.dart';
import 'package:utopia_cms/src/util/context_extensions.dart';
import 'package:utopia_cms/src/util/json_map.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class CmsTableActionsButton extends HookWidget {
  final List<CmsTableAction> actions;
  final JsonMap value;
  final void Function(JsonMap) onUpdate;

  const CmsTableActionsButton({
    super.key,
    required this.value,
    required this.onUpdate,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final style = context.textStyles.label;
    final loadingState = useState<bool>(false);
    return IgnorePointer(
      ignoring: loadingState.value,
      child: PopupMenuButton<CmsTableAction>(
        padding: EdgeInsets.zero,
        icon: loadingState.value ? const CmsLoader() : null,
        iconColor: context.theme.colors.text,
        iconSize: 20,
        itemBuilder: (context) {
          return actions.map<PopupMenuEntry<CmsTableAction>>(
            (e) {
              return PopupMenuItem(
                onTap: () async {
                  loadingState.value = true;
                  final result = await e.onPressed(value);
                  if (result != null && e.shouldUpdateTable) onUpdate(result);
                  loadingState.value = false;
                },
                child: Text(e.label, style: style),
              );
            },
          ).toList();
        },
      ),
    );
  }
}
