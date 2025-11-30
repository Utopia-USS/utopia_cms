import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utopia_arch/utopia_arch.dart';
import 'package:utopia_cms/src/model/cms_management_section_entry.dart';
import 'package:utopia_cms/src/model/cms_table_page_params.dart';
import 'package:utopia_cms/src/model/entry/cms_entry.dart';
import 'package:utopia_cms/src/ui/management/state/cms_management_state.dart';
import 'package:utopia_cms/src/ui/management/view/cms_management_view.dart';
import 'package:utopia_cms/src/util/json_map.dart';



class CmsManagementArgs {
  final JsonMap? initialValue;
  final List<CmsManagementSectionEntry> sectionEntries;
  final Future<JsonMap> Function(JsonMap newJson, JsonMap? oldJson) uploadChanges;
  final Future<void> Function()? deleteItem;
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

  const CmsManagementOverlay({super.key, required this.args, required this.animation});

  @override
  Widget build(BuildContext context) {
    final state = useCmsItemManagementState(
      args: args,
      moveBack: (value) => context.navigator.pop(value),
    );
    return Provider<CmsManagementBaseState>.value(
      value: state,
      child: CmsManagementView(
        state: state,
        animation: animation,
        sectionEntries: args.sectionEntries,
      ),
    );
  }
}
