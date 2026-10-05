import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/model/item_management/cms_management_section_entry.dart';
import 'package:utopia_cms/src/model/table/cms_table_page_params.dart';
import 'package:utopia_cms/src/theme/cms_theme_data.dart';
import 'package:utopia_cms/src/ui/item_management/state/cms_management_state.dart';
import 'package:utopia_cms/src/ui/item_management/view/cms_management_view.dart';
import 'package:utopia_cms/src/util/foundation.dart';
import 'package:utopia_cms/src/util/json_map.dart';

class CmsManagementArgs {
  final JsonMap? initialValue;
  final List<CmsManagementSectionEntry> sectionEntries;
  final Future<JsonMap> Function(JsonMap newJson, JsonMap? oldJson) uploadChanges;

  /// Deletes the edited item, returning whether the deletion actually ran -
  /// `false` when the user dismissed the confirmation, so the overlay stays open.
  final Future<bool> Function()? deleteItem;
  final CmsTableParams params;
  final IList<CmsEntry<dynamic>> entries;

  const CmsManagementArgs({
    this.initialValue,
    required this.uploadChanges,
    this.deleteItem,
    required this.params,
    required this.entries,
    required this.sectionEntries,
  });
}

class CmsManagementOverlay extends HookWidget {
  final CmsManagementArgs args;
  final Animation<double> animation;

  /// The overlay is pushed onto the app Navigator, outside the `CmsWidget` theme
  /// provider, so the resolved theme is threaded in and re-provided here.
  final CmsThemeData theme;

  const CmsManagementOverlay({super.key, required this.args, required this.animation, required this.theme});

  @override
  Widget build(BuildContext context) {
    final state = useCmsItemManagementState(args: args, moveBack: (value) => Navigator.of(context).pop(value));
    // The overlay is itself a raised surface, so invert the shell's tones: the
    // panel takes the card colour (e.g. white) while fields take the canvas
    // tint - the reverse of the main screen (canvas backdrop, white cards).
    final panelTheme = theme.copyWith(
      colors: theme.colors.copyWith(canvas: theme.colors.surface, field: theme.colors.canvas),
    );
    return Provider.value(
      value: panelTheme,
      child: Provider<CmsManagementBaseState>.value(
        value: state,
        child: CmsManagementView(state: state, animation: animation, sectionEntries: args.sectionEntries),
      ),
    );
  }
}
